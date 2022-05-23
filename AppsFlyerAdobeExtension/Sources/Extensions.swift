//
//  Extensions.swift
//  AppsFlyerAdobeExtension
//
//  Created by Paz Lavi  on 07/10/2021.
//

import Foundation

extension Notification.Name{
  public static let appsflyerBridge = Notification.Name(AppsFlyerConstants.AF_BRIDGE_SET)
  public static let appsflyerDeepLinkDelegateSetter = Notification.Name(AppsFlyerConstants.AF_BRIDGE_SET)
  
  
}

extension URL {
  public var queryParameters: [String: String]? {
    guard
      let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
      let queryItems = urlComponents.queryItems else { return nil }
    return queryItems.reduce(into: [String:String]()){ (result, item) in
      result[item.name] = item.value
    }
  }
}
