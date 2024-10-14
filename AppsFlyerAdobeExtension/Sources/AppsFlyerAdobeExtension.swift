//
//  AppsFlyerAdobeExtension.swift
//  AppsFlyerAdobeExtension
//
//  Created by Paz Lavi  on 05/10/2021.
//

import Foundation
import AEPCore
import AEPIdentity
import AppsFlyerLib
import UIKit
import AEPEdge

@objc(AppsFlyerAdobeExtension)
public class AppsFlyerAdobeExtension: NSObject, Extension {
  // MARK: - Adobe Extension properties
  public static var manual = false
  public static var extensionVersion = AppsFlyerConstants.EXTENSION_VERSION
  public var name: String = AppsFlyerConstants.EXTENSION_NAME
    private var didInit = false
  // should send onConversionDataSuccess result
  // to Adobe Analytics
  private var logAttributionData = false
  private var ecid : String?
  // a flag that represents if we may call `start()`
  // set later to false if we should wait for ECID
  // until ECID is available
  private var mayStartSDK = true
  
  // MARK: AppsFlyer Delegates
    public var friendlyName: String = AppsFlyerConstants.FRIENDLY_NAME
      public var metadata: [String : String]?
      public var runtime: ExtensionRuntime
      
      // MARK: AppsFlyer properties
      private static var gcd : [AnyHashable : Any]?
      // types of event that should be sent to Adobe Analytics
      private var eventSettings : String?
      private var didReceiveConfigurations = false
  // GCD + OAOA
  public static var delegate : AppsFlyerLibDelegate? = nil
  // UDL
  public static var deepLinkDelegate : DeepLinkDelegate? = nil {
    didSet {
      // notify value chabged.
      NotificationCenter.default.post(name: .appsflyerDeepLinkDelegateSetter,
                                      object: self, userInfo: [AppsFlyerConstants.AF_HAS_DEEPLINK_DELEGATE : deepLinkDelegate != nil])
    }
  }
  
  // MARK: Adobe Extension protocol implementetion
  /// Invoked when the `EventHub` creates it's instance of the AppsFlyerAdobeExtension extension
  public required init?(runtime: ExtensionRuntime) {
    self.runtime = runtime
    super.init()
    // register for deepLinkDelegate changes notification
    NotificationCenter.default.addObserver(self, selector: #selector(self.onDeepLinkDelegateSetter(_:)), name: .appsflyerDeepLinkDelegateSetter, object: nil)
  }
  
  /// Invoked when the `EventHub` has successfully registered the AppsFlyerAdobeExtension extension.
  public func onRegistered() {
    // Listener for remote configuration
    // onConfigurationRecived is invoked whenever the `EventHub` dispatches an event with type configuration and source request content
    self.registerListener(type: EventType.configuration, source: EventSource.requestContent, listener: onConfigurationRecived(event:))
    // Listener for Analytics Event binding
    // requestContentListener is invoked whenever the `EventHub` dispatches an event with type genericTrack and source request content
    self.registerListener(type: EventType.genericTrack, source: EventSource.requestContent, listener: requestContentListener(event:))
    // Listener for Edge Events
    // requestContentListener is invoked whenever the `EventHub` dispatches an event with type Edge and source request content
    self.registerListener(type: EventType.edge, source: EventSource.requestContent, listener: requestContentListener(event:))
  }
  
  /// Invoked when the AppsFlyerAdobeExtension extension has been unregistered by the `EventHub`.
  public func onUnregistered() {
    self.unregisterExtension()
    // remove start
    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    logger("was unregistered")
  }
  
  /// AppsFlyerAdobeExtension is ready for an `Event` once configuration shared state is available
  /// - Parameter event: an `Event`
  public func readyForEvent(_ event: Event) -> Bool {
    return getSharedState(extensionName: AppsFlyerConstants.SharedStateKeys.CONFIGURATION, event: event)?.status == .set
  }
}

// MARK: - Event Listeners
extension AppsFlyerAdobeExtension {
  
  /// extract AppsFlyer settings from remote configuration
  /// Invoked when an event of type configuration and source request content is dispatched by the `EventHub`
  /// - Parameter event: the generic configuration event
  private func onConfigurationRecived(event: Event) {
    guard let configurationSharedState = getSharedState(extensionName: AppsFlyerConstants.SharedStateKeys.CONFIGURATION, event: event) else {
      logger("Waiting for valid configuration to process AppsFlyerAdobeExtension.")
      return
    }
    guard let configSharedState = configurationSharedState.value else {
      logger("Cannot initilalise AppsFlyer without settings")
      return
    }
    // String - extract devKey and AppId
    guard let appsFlyerDevKey = configSharedState[AppsFlyerConstants.AF_DEV_KEY] as? String,
            let appsFlyerAppId = configSharedState[AppsFlyerConstants.AF_APP_ID] as? String else {
      logger("Cannot initilalise AppsFlyer tracking without an appId or devKey")
      return
    }
    //String
    let eventSettings = configSharedState[AppsFlyerConstants.AF_IAE_SETTINGS] as? String ?? AppsFlyerConstants.NONE
    // Integers
    let appsFlyerIsDebug = configSharedState[AppsFlyerConstants.AF_DEBUG_KEY]
    let appsFlyerTrackAttrData = configSharedState[AppsFlyerConstants.AF_TRACK_ATTR_KEY]
    let appsFlyerWaitForECID = configSharedState[AppsFlyerConstants.AF_ECID_KEY]
    
    let isDebug = appsFlyerIsDebug is NSNumber && (appsFlyerIsDebug as! NSNumber).intValue == 1
    let logkAttrData = appsFlyerTrackAttrData is NSNumber && (appsFlyerTrackAttrData as! NSNumber).intValue == 1
    let waitForECID = appsFlyerWaitForECID is NSNumber && (appsFlyerWaitForECID as! NSNumber).intValue == 1
    
    // init the SDK
    setupAppsFlyerConfiguration(appId: appsFlyerAppId, devKey: appsFlyerDevKey,
                                isDebug: isDebug, logAttrData: logkAttrData, eventSettings: eventSettings, waitForECID: waitForECID)
  }
  
  /// Invoked when an event of type genericTrack and source request content is dispatched by the `EventHub`
  /// Handler for generic analytics track events. If the event is not sent by AppsFlyer (`AppsFlyer Attribution Data` or `AppsFlyer Engagement Data`)
  /// We'll convert this event to an AppsFlyer in-app event and log it.
  /// - Parameter event: an event containing track data for processing
  private func requestContentListener(event: Event) {
    if self.eventSettings == AppsFlyerConstants.NONE {
      logger("error retreiving event binding state")
      return
    }

    if event.type == EventType.edge{
        handleEdgeEvent(event: event)
        return
    } else {
        handleGenericEvent(event: event)
    }
  }
    
    private func handleGenericEvent(event: Event){
        // Bools
        var isRevenueEvent = false
        let bindActionEvents = (self.eventSettings == AppsFlyerConstants.ACTIONS || self.eventSettings == AppsFlyerConstants.ALL)
        let bindStateEvents = (self.eventSettings == AppsFlyerConstants.STATES || self.eventSettings == AppsFlyerConstants.ALL)
        
        print(event.description)
        guard let eventData = event.data else {
          logger("Couldn't extract event data")
          return
        }
        let nestedData = eventData[AppsFlyerConstants.CONTEXT_DATA_KEY] as? [String : Any]
        let eventState = eventData[AppsFlyerConstants.STATE_KEY] as? String
        let eventAction = eventData[AppsFlyerConstants.ACTION_KEY] as? String
        
        if eventAction == AppsFlyerConstants.APPSFLYER_ATTRIBUTION_DATA || eventAction == AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA {
          logger("Discarding event binding for AppsFlyer Attribution Data event")
          return
        }
        
        let revenue = extractRevenue(nestedData)
        let currency = extractCurrency(nestedData)
        
        var afPayloadProperties : [String : Any]? = nil
          
        if let revenue = revenue {
          afPayloadProperties = nestedData
          afPayloadProperties?[AppsFlyerConstants.AF_REVENUE] = revenue
          afPayloadProperties?[AppsFlyerConstants.AF_CURRENCY] = currency
          isRevenueEvent = true
        }
        if let eventAction = eventAction, bindActionEvents && eventAction.count != 0 {
          if isRevenueEvent && afPayloadProperties != nil {
            AppsFlyerLib.shared().logEvent(name: eventAction, values: afPayloadProperties!)
          } else {
            AppsFlyerLib.shared().logEvent(name: eventAction, values: nestedData)
          }
        }
        if let eventState = eventState, bindStateEvents && eventState.count != 0 {
          if isRevenueEvent && afPayloadProperties != nil {
            AppsFlyerLib.shared().logEvent(name: eventState, values: afPayloadProperties!)
          } else {
            AppsFlyerLib.shared().logEvent(name: eventState, values: nestedData)
          }
        }
    }
    
    private func handleEdgeEvent(event: Event){
        guard let eventData = event.data else {
            logger("Couldn't extract event data")
            return
        }
        var eventName = event.name
        if let dataDictionary = eventData["data"] as? [String: Any],
           let eventAction = dataDictionary[AppsFlyerConstants.ACTION_KEY] as? String {
            if eventAction == AppsFlyerConstants.APPSFLYER_ATTRIBUTION_DATA || eventAction == AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA {
                logger("Discarding event binding for AppsFlyer Attribution/Engagement Data event")
                return
            }
        }
        var eventNewData: [String: Any] = [:]
        if let dict = eventData["xdm"] as? [String: Any] {
            dictionaryManipulationForEdgeEvent(dict, &eventName, &eventNewData)
        }
        if let dict = eventData["data"] as? [String: Any] {
            dictionaryManipulationForEdgeEvent(dict, &eventName, &eventNewData)
        }
        AppsFlyerLib.shared().logEvent(eventName, withValues: eventNewData)
    }
    
    fileprivate func dictionaryManipulationForEdgeEvent(_ dict: [String : Any], _ eventName: inout String, _ eventNewData: inout [String : Any]) {
        for (key, value) in dict {
            if key == "eventName" {
                if let eventNameValue = value as? String{
                    eventName = eventNameValue
                }
            } else if key == AppsFlyerConstants.CURRENCY_KEY || key == AppsFlyerConstants.REVENUE_KEY {
                continue
            } else {
                eventNewData[key] = value
            }
        }
        
        let revenue = extractRevenue(dict)
        let currency = extractCurrency(dict)
          
        if let revenue = revenue {
            eventNewData[AppsFlyerConstants.AF_REVENUE] = revenue
            eventNewData[AppsFlyerConstants.AF_CURRENCY] = currency
        }
    }
}

// MARK: internal methods
extension AppsFlyerAdobeExtension {
  /// print AppsFlyer log messages
  /// - Parameter msg: a log message to print
  private func logger(_ msg:String) {
#if DEBUG
    NSLog("[AppsFlyer Adobe][Debug]: \(msg)")
#endif
  }
  
  /// init the SDK using remote configuration
  /// - Parameters:
  ///   - appId: apple app Id
  ///   - devKey: client's appsflyer dev key
  ///   - isDebug: should set the SDK to debug mode
  ///   - logAttrData: should send the conversion data to Adobe analytics
  ///   - eventSettings: the event types that should be sent to Adobe analytics
  ///   - waitForECID: should wait to ECID before `strat()` (send launch and event with `CUID`)
  private func setupAppsFlyerConfiguration(appId: String, devKey: String, isDebug: Bool, logAttrData:Bool, eventSettings: String, waitForECID: Bool) {
    // perform only once
    if !didReceiveConfigurations {
      if waitForECID{
        mayStartSDK = false
        logger("waiting for ECID")
      } else {
        mayStartSDK = true
        logger("not waiting for ECID")
      }
      let af = AppsFlyerLib.shared()
      af.setPluginInfo(plugin: .adobeSwiftAEP, version: AppsFlyerConstants.EXTENSION_VERSION, additionalParams: nil)
      af.appsFlyerDevKey = devKey
      af.appleAppID = appId
      af.isDebug = isDebug
      af.delegate = self
      if AppsFlyerAdobeExtension.deepLinkDelegate != nil {
        af.deepLinkDelegate = self
      }
      // get ECID
      Identity.getExperienceCloudId() { str , error in
        if error != nil {
          self.logger(error!.localizedDescription)
        } else if let ecid = str {
          self.ecid = ecid
          af.customerUserID = ecid
        } else {
          self.logger("ExperienceCloudId is null")
        }
        if waitForECID {
          self.mayStartSDK = true
          self.appDidBecomeActive()
        }
      }
      // register observer to send start()
      NotificationCenter.default.addObserver(self, selector: #selector(self.appDidBecomeActive),
                                             name: UIApplication.didBecomeActiveNotification, object: nil)
      
      logAttributionData = logAttrData
      self.eventSettings = eventSettings
      self.didReceiveConfigurations = true
      AppsFlyerAttribution.shared.bridgReady = true
      
      if !self.didInit {
        // notify bridge is ready. Now able to resolve onelinks
        NotificationCenter.default.post(name: Notification.Name.appsflyerBridge, object: self)
        self.appDidBecomeActive()
        self.didInit = true
      } else {
        logger("rejecting re-init of previously initialized tracker")
      }
    }
  }
  
  /// add data for adobe analytics to onConversionDataSuccess result.
  ///  - Parameter conversionInfo: the original  onConversionDataSuccess result
  ///  - Returns: [AnyHashable: Any] dictionary with additional data
  private func getSharedEventState(conversionInfo : [AnyHashable: Any]) -> [AnyHashable: Any] {
    var sharedEventState = conversionInfo
    let af = AppsFlyerLib.shared()
    sharedEventState[AppsFlyerConstants.APPSFLYER_ID] = af.getAppsFlyerUID()
    sharedEventState[AppsFlyerConstants.SDK_VERSION] = af.getSDKVersion()
    if sharedEventState[AppsFlyerConstants.MEDIA_SOURCE] == nil {
      sharedEventState[AppsFlyerConstants.MEDIA_SOURCE] = AppsFlyerConstants.ORGANIC
    }
    sharedEventState.removeValue(forKey: AppsFlyerConstants.IS_FIRST_LAUNCH)
    
    return sharedEventState
  }
  
  /// convert [AnyHashable: Any] dictionary to [String : Any] dictionary.
  /// - Parameter oldDictionary: the original  [AnyHashable: Any] dictionary
  /// - Returns: [String: Any] the original dictionary after convrting all the keys to String
  private func convertAnyHashableToStringDictionary(_ oldDictionary: [AnyHashable: Any]) -> [String : Any] {
    var newDic : [String : Any] = [:]
    for (k,v) in oldDictionary {
      if k is String {
        newDic[k as! String] = v
      } else {
        newDic["\(k)"] = v
      }
    }
    return newDic
  }
  /// convert [AnyHashable: Any] dictionary to [String : Any] dictionary with `appsflyer.` prefix for each key and value.
  /// - Parameter oldDictionary: the original  [AnyHashable: Any] dictionary
  /// - Returns: [String: Any] the original dictionary after convrting all the keys to String and adding `appsflyer.` prefix
  private func setKeyPrefix(oldDictionary: [AnyHashable : Any]) -> [String : Any] {
    var withPrefix : [String : Any] = [:]
    for (k,v) in oldDictionary {
      let newKey = "appsflyer.\(k)"
      let newVal = "\(v)"
      withPrefix[newKey] = newVal
    }
    return withPrefix
  }
  
  /// convert [AnyHashable: Any] dictionary to [String : Any] dictionary with `af_engagement_.` prefix for each key.
  /// - Parameter oldDictionary: the original  [AnyHashable: Any] dictionary
  /// - Returns: [String: Any] the original dictionary after convrting all the keys to String and adding `af_engagement_.` prefix
  private func setKeyPrefixDeepLinking(attributionData: [AnyHashable : Any]) -> [String : Any] {
    var withPrefix : [String : Any] = [:]
    for (k,v) in attributionData {
      let newKey = "af_engagement_\(k)"
      let newVal = "\(v)"
      withPrefix[newKey] = newVal
    }
    return withPrefix
  }
  
  /// When a given dictionary containsa single key - `link` >>  parse the link's query parameters and return thrm as a dictionary.
  ///  Else >> return the given dictionary without any change.
  /// - Parameter attributionData: the original dictionary
  /// - Returns: [AnyHashable : Any]? dictionary
  private func returnParsedAttribution(attributionData: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
    guard let attributionData = attributionData else {
      return attributionData
    }
    if attributionData.count == 1 && attributionData.keys.contains(AppsFlyerConstants.LINK) {
      guard let urlString = attributionData[AppsFlyerConstants.LINK] as? String,
            let url = URL(string: urlString) else {
              return attributionData
            }
      guard var dictionary = url.queryParameters else {
        return attributionData
      }
      dictionary[AppsFlyerConstants.LINK] = urlString
      return dictionary
    }
    return attributionData
  }
  
  /// Extract currency value from a given dictionary
  /// - Parameter dictionary: the  dictionary to extract from
  /// - Returns: String - the extracted currency value. If not exist return USD
  private func extractCurrency(_ dictionary: [String : Any]?) -> String {
    guard let str = dictionary?[AppsFlyerConstants.CURRENCY_KEY] as? String else {
      return AppsFlyerConstants.DEFAULT_CURRENCY
    }
    return str
  }
  
  /// Extract revenue value from a given dictionary
  /// - Parameter dictionary: the  dictionary to extract from
  /// - Returns: NSDecimalNumber - the extracted revenue value. If not exist return nil
  private func extractRevenue(_ dictionary: [String : Any]?) -> NSDecimalNumber? {
    guard let revenueProperty = dictionary?[AppsFlyerConstants.REVENUE_KEY] else {
      return nil
    }
    if revenueProperty is String {
      if let revenueProperty = revenueProperty as? String {
        return NSDecimalNumber(string: revenueProperty)
      }
    } else if revenueProperty is NSNumber {
      if let revenueProperty = revenueProperty as? NSDecimalNumber {
        return revenueProperty
      }
    }
    return nil
  }
}

// MARK: Notifications implementetions 
extension AppsFlyerAdobeExtension {
  /// Handle `UIApplication.didBecomeActiveNotification` notification.
  /// Send `start()` event
  @objc private func appDidBecomeActive() {
    logger("appDidBecomeActive")
    if didReceiveConfigurations && mayStartSDK {
      NotificationCenter.default.post(name: Notification.Name.appsflyerBridge, object: self)
        if !AppsFlyerAdobeExtension.manual{
            AppsFlyerLib.shared().start()
            logger("AF start")
        }
    }
  }
  
  /// Handle `appsflyerDeepLinkDelegateSetter` notification.
  /// set or remove `deepLinkDelegate` from the SDK.
  @objc private func onDeepLinkDelegateSetter(_ notification: Notification) {
    guard let hasDelegate = notification.userInfo?[AppsFlyerConstants.AF_HAS_DEEPLINK_DELEGATE] as? Bool else {
      return
    }
    AppsFlyerLib.shared().deepLinkDelegate = hasDelegate ? self : nil
  }
}

// MARK: UDL Delegate
extension AppsFlyerAdobeExtension : DeepLinkDelegate {
  
  public func didResolveDeepLink(_ result: DeepLinkResult) {
    logger("didResolveDeepLink")
    if result.status == .found {
      if let dic = result.deepLink?.clickEvent {
        createSharedState(data: convertAnyHashableToStringDictionary(dic), event: nil)
        // send `clickEvent` to Adobe Analytics
        MobileCore.track(action: AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA, data: setKeyPrefix(oldDictionary:
                                                                                                    setKeyPrefixDeepLinking(attributionData: dic)))
          let experienceEvent = ExperienceEvent(xdm: setKeyPrefix(oldDictionary:
                                                                    setKeyPrefixDeepLinking(attributionData: dic)), data: [AppsFlyerConstants.ACTION_KEY: AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA])
          Edge.sendEvent(experienceEvent: experienceEvent) { handle in
              print(handle.description)
          }
      }
    }
    AppsFlyerAdobeExtension.deepLinkDelegate?.didResolveDeepLink?(result)
  }
}

// MARK: GCD and OAOA Delegate
extension AppsFlyerAdobeExtension : AppsFlyerLibDelegate {
  
  public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
    logger("onConversionDataSuccess")
    var appendedInstallData = conversionInfo
    
    if logAttributionData {
      if let isFirst = conversionInfo[AppsFlyerConstants.IS_FIRST_LAUNCH], isFirst is NSNumber && (isFirst as! NSNumber).intValue == 1 {
        createSharedState(data: convertAnyHashableToStringDictionary(getSharedEventState(conversionInfo: conversionInfo)), event: nil)
        appendedInstallData[AppsFlyerConstants.APPSFLYER_ID] = AppsFlyerLib.shared().getAppsFlyerUID()
        if self.ecid != nil {
          appendedInstallData[AppsFlyerConstants.ECID] = self.ecid!
        }
        // send `conversionInfo` to Adobe Analytics
        MobileCore.track(action: AppsFlyerConstants.APPSFLYER_ATTRIBUTION_DATA , data: setKeyPrefix(oldDictionary: appendedInstallData))
          let experienceEvent = ExperienceEvent(xdm: setKeyPrefix(oldDictionary: appendedInstallData), data: [AppsFlyerConstants.ACTION_KEY: AppsFlyerConstants.APPSFLYER_ATTRIBUTION_DATA])
          Edge.sendEvent(experienceEvent: experienceEvent) { handle in
              print(handle.description)
          }
      }
    }
    AppsFlyerAdobeExtension.gcd = appendedInstallData
    AppsFlyerAdobeExtension.delegate?.onConversionDataSuccess(appendedInstallData)
  }
  
  public func onConversionDataFail(_ error: Error) {
    logger("onConversionDataFail")
    AppsFlyerAdobeExtension.delegate?.onConversionDataFail(error)
  }
  
  public func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
    logger("onAppOpenAttribution")
    var appendedAttributionData = attributionData
    if let newAttributionData = returnParsedAttribution(attributionData: attributionData)  {
      createSharedState(data: convertAnyHashableToStringDictionary(attributionData), event: nil)
      // send `attributionData` to Adobe Analytics
      MobileCore.track(action: AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA , data: setKeyPrefix(oldDictionary:
                                                                                                  setKeyPrefixDeepLinking(attributionData: newAttributionData)))
        let experienceEvent = ExperienceEvent(xdm: setKeyPrefix(oldDictionary:
                                                                    setKeyPrefixDeepLinking(attributionData: newAttributionData)), data: [AppsFlyerConstants.ACTION_KEY: AppsFlyerConstants.APPSFLYER_ENGAGEMENT_DATA])
        Edge.sendEvent(experienceEvent: experienceEvent) { handle in
            print(handle.description)
        }
    }
    if ecid != nil {
      appendedAttributionData[AppsFlyerConstants.ECID] = self.ecid!
    }
    AppsFlyerAdobeExtension.delegate?.onAppOpenAttribution?(appendedAttributionData)
    
  }
  
  public func onAppOpenAttributionFailure(_ error: Error) {
    logger("onAppOpenAttributionFailure")
    AppsFlyerAdobeExtension.delegate?.onAppOpenAttributionFailure?(error)
  }
  
}


