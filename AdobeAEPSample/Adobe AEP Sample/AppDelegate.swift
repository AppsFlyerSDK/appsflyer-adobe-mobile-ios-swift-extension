//
//  AppDelegate.swift
//  Adobe AEP Sample
//
//  Created by Paz Lavi  on 07/10/2021.
//
//com.appsflyer.Adobe-AEP-Sample
import UIKit
import AEPCore
import AEPIdentity
import AEPLifecycle
import AEPSignal
import AppsFlyerAdobeAEPExtension
import AppsFlyerLib
import AEPAnalytics
import AEPMobileServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let appState = application.applicationState
    // For legacy deep links
    AppsFlyerAdobeExtension.delegate = self
    // For UDL
    AppsFlyerAdobeExtension.deepLinkDelegate = self
    MobileCore.setLogLevel(.debug)
    MobileCore.registerExtensions([Lifecycle.self, Identity.self, Signal.self,
                                   Analytics.self,
                                   AEPMobileServices.self, AppsFlyerAdobeExtension.self]) {
    }
    MobileCore.configureWith(appId: "REPLACE_WITH_YOUR_ADOBE_KEY")
    if appState != .background {
      // only start lifecycle if the application is not in the background
      MobileCore.lifecycleStart(additionalContextData: nil)
    }
    return true
  }
  

  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  // For Swift version < 4.2 replace function signature with the commented out code
  // func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool { // this line for Swift < 4.2
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    AppsFlyerAttribution.shared.continueUserActivity(userActivity: userActivity)
    return true
  }
  
  // Open URI-scheme for iOS 9 and above
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    AppsFlyerAttribution.shared.handleOpenUrl(open: url)
    return true
  }
  private func logger(_ msg: String){
    NSLog("AppsFlyerAdobeApp: \(msg)")
  }
}

extension AppDelegate : AppsFlyerLibDelegate {
  func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
    logger("onAppOpenAttribution")
  }
  
  func onAppOpenAttributionFailure(_ error: Error) {
    logger("onAppOpenAttributionFailure")
  }
  func onConversionDataFail(_ error: Error) {
    logger("onConversionDataFail")
  }
  func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
    logger("onConversionDataSuccess")
  }
}

extension AppDelegate : DeepLinkDelegate {
  func didResolveDeepLink(_ result: DeepLinkResult) {
    logger("didResolveDeepLink")
  }
}
