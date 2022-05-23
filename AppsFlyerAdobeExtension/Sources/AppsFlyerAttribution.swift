//
//  AppsFlyerAttribution.swift
//  AppsFlyerAdobeExtension
//
//  Created by Paz Lavi  on 07/10/2021.
//

import Foundation


import Foundation
import UIKit
import AppsFlyerLib
public class AppsFlyerAttribution: NSObject {
  
  public static let shared = AppsFlyerAttribution()
  var bridgReady :Bool = false
  private var userActivity :NSUserActivity? = nil
  private var url: URL? = nil
  private var options: [UIApplication.OpenURLOptionsKey: Any]? = nil
  
  private override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(self.receiveBridgeReadyNotification),
                                           name: Notification.Name.appsflyerBridge, object: nil)
  }
  
  
  
  public func continueUserActivity(userActivity:NSUserActivity) {
    if(bridgReady) {
      AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    } else {
      self.userActivity = userActivity
    }
    
  }
  
  public func handleOpenUrl(open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
    if(bridgReady) {
      AppsFlyerLib.shared().handleOpen(url, options:options)
    } else {
      self.url = url
      self.options = options
    }
  }
  
  @objc func receiveBridgeReadyNotification() {
#if DEBUG
    NSLog("[AppsFlyer Adobe][Debug]: handle deep link")
#endif
    NotificationCenter.default.removeObserver(self, name: .appsflyerBridge, object: nil)
    if(userActivity != nil) {
      AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
      userActivity = nil
    } else if(url != nil) {
      AppsFlyerLib.shared().handleOpen(url, options:options)
      url = nil
      options = nil
    }
  }
  
}
