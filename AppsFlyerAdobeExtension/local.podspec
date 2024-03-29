#
#  Be sure to run `pod spec lint AppsFlyerAdobeExtension.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

   
Pod::Spec.new do |s|
  s.name             = 'AppsFlyerAdobeAEPExtension'
  s.version          = '6.12.0'
  s.summary          = 'AppsFlyer iOS SDK Extension for Adobe Mobile SDK'
  s.description      = <<-DESC
AppsFlyer iOS SDK Extension for Adobe Mobile SDK.
                       DESC

  s.homepage         = 'https://github.com/AppsFlyerSDK/appsflyer-adobe-mobile-ios-swift-extension'
  s.license          = { :type => 'proprietary', :file => 'LICENSE' }
  s.author           = { 'AppsFlyer' => 'paz.lavi@appsflyer.com' }
  s.source           = { :git => 'https://github.com/AppsFlyerSDK/appsflyer-adobe-mobile-ios-swift-extension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'Sources/**/*.{swift,h,m}'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.swift_version = '5.1'
  s.vendored_frameworks = 'Vendor/AEPCore.xcframework', 'Vendor/AEPIdentity.xcframework', 'Vendor/AEPServices.xcframework', 'Vendor/AEPRulesEngine.xcframework', 'Vendor/AppsFlyerLib.xcframework'
end