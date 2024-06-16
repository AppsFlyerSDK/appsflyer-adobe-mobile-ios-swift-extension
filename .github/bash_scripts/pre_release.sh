#!/bin/bash

appsflyerLibVersion=$1
rcVersion=$2

sed -i '' "s/version_appsflyerLib = \'.*\'/version_appsflyerLib = \'$appsflyerLibVersion\'/g" AppsFlyerAdobeAEPExtension.podspec
sed -i '' "s/version_plugin = \'.*\'/version_plugin = \'$rcVersion\'/g" AppsFlyerAdobeAEPExtension.podspec
sed -i '' "s/s.name             = \'AppsFlyerAdobeAEPExtension\'/s.name             = \'AppsFlyerAdobeAEPExtension-qa\'/g" AppsFlyerAdobeAEPExtension.podspec
mv AppsFlyerAdobeAEPExtension.podspec AppsFlyerAdobeAEPExtension-qa.podspec

sed -r -i '' "s/(.*AppsFlyerLib.*)([0-9]+\.[0-9]+\.[0-9]+)(.*)/\1$appsflyerLibVersion\3/g" Package.swift

sed -r -i '' "s/(.*pod \'AppsFlyerAdobeAEPExtension)\'(.*\'[0-9]+\.[0-9]+\.[0-9]+\')/\1-qa\',\'$rcVersion\'/g" AdobeAEPSample/Podfile

sed -r -i '' "s/(- iOS AppsFlyer SDK .*)([0-9]+\.[0-9]+\\.[0-9]+)(.*)/\1$appsflyerLibVersion\3/g" README.md

sed -r -i '' "s/(.*EXTENSION_VERSION.*)([0-9]+\.[0-9]+\.[0-9]+)(.*)/\1$appsflyerLibVersion\3/g" AppsFlyerAdobeExtension/Sources/AppsFlyerConstants.swift

touch "releasenotes.$appsflyerLibVersion"
