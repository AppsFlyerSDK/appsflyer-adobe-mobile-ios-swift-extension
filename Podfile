platform :ios, 10.0

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AppsFlyerAdobeBinary'
project 'AppsFlyerAdobeExtension/GenerateAdobeBinary.xcodeproj'


target 'GenerateAdobeBinary' do
  pod 'AppsFlyerAdobeAEPExtension', :path => 'AppsFlyerAdobeExtension/local.podspec'
end  



post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
        bc.build_settings['TVOS_DEPLOYMENT_TARGET'] = '10.0'
        bc.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator appletvos appletvsimulator'
        bc.build_settings['TARGETED_DEVICE_FAMILY'] = "1,2,3"
    end
  end
end
