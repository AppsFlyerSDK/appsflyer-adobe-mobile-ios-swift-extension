//
//  AppsFlyerConstants.swift
//  AppsFlyerAdobeExtension
//
//  Created by Paz Lavi  on 05/10/2021.
//

import Foundation
enum AppsFlyerConstants {
  static let EXTENSION_NAME = "com.appsflyer.adobeextension" 
  static let FRIENDLY_NAME = "AppsFlyerAdobeExtension"
  static let EXTENSION_VERSION = "6.17.7"
  static let EVENT_GETTER_RESPONSE_DATA_KEY = "getterdata"
  static let EVENT_SETTER_REQUEST_DATA_KEY = "setterdata"
  static let AF_BRIDGE_SET = "bridge is set"
  static let AF_DEEPLINK_DELEGATE = "delegate_changed"
  static let AF_HAS_DEEPLINK_DELEGATE = "has_deeplink_delegate"
  static let IS_FIRST_LAUNCH = "is_first_launch"
  static let APPSFLYER_ID = "appsflyer_id"
  static let SDK_VERSION = "sdk_version"
  static let MEDIA_SOURCE = "media_source"
  static let ORGANIC = "organic"
  static let ECID = "ecid"
  static let LINK = "link"
  static let CALLBACK_TYPE = "callback_type"
  static let APPSFLYER_ATTRIBUTION_DATA = "AppsFlyer Attribution Data"
  static let APPSFLYER_ENGAGEMENT_DATA = "AppsFlyer Engagement Data"
  static let AF_REVENUE = "af_revenue"
  static let AF_CURRENCY = "af_currency"
  static let REVENUE_KEY = "revenue"
  static let CURRENCY_KEY = "currency"
  static let NONE = "none"
  static let ACTIONS = "actions"
  static let STATES = "states"
  static let ALL = "all"
  static let STATE_KEY = "state"
  static let CONTEXT_DATA_KEY = "contextdata"
  static let ACTION_KEY = "action"
  static let AF_DEV_KEY = "appsFlyerDevKey"
  static let AF_APP_ID = "appsFlyerAppId"
  static let AF_IAE_SETTINGS = "inAppEventSetting"
  static let AF_DEBUG_KEY = "appsFlyerIsDebug"
  static let AF_TRACK_ATTR_KEY = "appsFlyerTrackAttrData"
  static let AF_ECID_KEY = "appsFlyerWaitForECID"
  static let DEFAULT_CURRENCY = "USD"
  
  
  
  
  enum SharedStateKeys {
    static let CONFIGURATION = "com.adobe.module.configuration"
  }
}
