# Variables
CURR_DIR := ${CURDIR}
AEPRULESENGINE_TARGET_NAME = AppsFlyerAdobeAEPExtension

SIMULATOR_ARCHIVE_PATH = ./build/ios_simulator.xcarchive/Products/Library/Frameworks/
TVOS_SIMULATOR_ARCHIVE_PATH = ./build/tvos_simulator.xcarchive/Products/Library/Frameworks/
SIMULATOR_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/ios_simulator.xcarchive/dSYMs/
TVOS_SIMULATOR_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/tvos_simulator.xcarchive/dSYMs/
IOS_ARCHIVE_PATH = ./build/ios.xcarchive/Products/Library/Frameworks/
TVOS_ARCHIVE_PATH = ./build/tvos.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/ios.xcarchive/dSYMs/
TVOS_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/tvos.xcarchive/dSYMs/


clean:
	rm -rf ./build

archive: clean
	# iOS
	@find  $(CURDIR) -name "Podfile" -type f | xargs -L 1 sed -i '' '1 s/^.*$$/platform :ios, '10.0'/g'
	pod install 
	xcodebuild archive -workspace AppsFlyerAdobeBinary.xcworkspace -scheme AppsFlyerAdobeAEPExtension -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace AppsFlyerAdobeBinary.xcworkspace -scheme AppsFlyerAdobeAEPExtension -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	# tvOS
	@find  $(CURDIR) -name "Podfile" -type f | xargs -L 1 sed -i '' '1 s/^.*$$/platform :tvos, '10.0'/g'
	pod install 
	xcodebuild archive -workspace AppsFlyerAdobeBinary.xcworkspace -scheme AppsFlyerAdobeAEPExtension -archivePath "./build/tvos.xcarchive" -sdk appletvos -destination="tvOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES	
	xcodebuild archive -workspace AppsFlyerAdobeBinary.xcworkspace -scheme AppsFlyerAdobeAEPExtension -archivePath "./build/tvos_simulator.xcarchive" -sdk appletvsimulator -destination="tvOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	# Create
	xcodebuild -create-xcframework \
	-framework $(SIMULATOR_ARCHIVE_PATH)$(AEPRULESENGINE_TARGET_NAME).framework -debug-symbols $(SIMULATOR_ARCHIVE_DSYM_PATH)$(AEPRULESENGINE_TARGET_NAME).framework.dSYM \
	-framework $(TVOS_SIMULATOR_ARCHIVE_PATH)$(AEPRULESENGINE_TARGET_NAME).framework -debug-symbols $(TVOS_SIMULATOR_ARCHIVE_DSYM_PATH)$(AEPRULESENGINE_TARGET_NAME).framework.dSYM \
	-framework $(IOS_ARCHIVE_PATH)$(AEPRULESENGINE_TARGET_NAME).framework -debug-symbols $(IOS_ARCHIVE_DSYM_PATH)$(AEPRULESENGINE_TARGET_NAME).framework.dSYM \
	-framework $(TVOS_ARCHIVE_PATH)$(AEPRULESENGINE_TARGET_NAME).framework -debug-symbols $(TVOS_ARCHIVE_DSYM_PATH)$(AEPRULESENGINE_TARGET_NAME).framework.dSYM \
	-output ./build/$(AEPRULESENGINE_TARGET_NAME).xcframework

	# Restore Podfile
	@find  $(CURDIR) -name "Podfile" -type f | xargs -L 1 sed -i '' '1 s/^.*$$/platform :ios, '10.0'/g'

	# ISSUE: https://developer.apple.com/forums/thread/123253
	# https://github.com/apple/swift/issues/43510
	# WORKAROUND APPLIED:
	@find  $(CURDIR) -name "*.swiftinterface" -exec sed -i -e 's/AppsFlyerLib\.//g' {} \;