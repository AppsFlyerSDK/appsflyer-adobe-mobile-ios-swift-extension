#!/bin/bash

releaseVersion=$1

sed -r -i '' "s/version_plugin = \'[0-9]+\.[0-9]+\.[0-9]+.*\'/version_plugin = \'$releaseVersion\'/g" AppsFlyerAdobeAEPExtension-qa.podspec
sed -i '' "s/s.name             = \'AppsFlyerAdobeAEPExtension-qa\'/s.name             = \'AppsFlyerAdobeAEPExtension\'/g" AppsFlyerAdobeAEPExtension-qa.podspec
mv AppsFlyerAdobeAEPExtension-qa.podspec AppsFlyerAdobeAEPExtension.podspec

sed -r -i '' "s/(.*pod \'AppsFlyerAdobeAEPExtension)-qa\'(.*)/\1\',\'$releaseVersion\'/g" AdobeAEPSample/Podfile

sed -i '' 's/^/* /' "releasenotes.$releaseVersion"
NEW_VERSION_RELEASE_NOTES=$(cat "releasenotes.$releaseVersion")
NEW_VERSION_SECTION="### $releaseVersion\n$NEW_VERSION_RELEASE_NOTES\n\n"
echo -e "$NEW_VERSION_SECTION$(cat RELEASENOTES.md)" > RELEASENOTES.md

rm -r "releasenotes.$releaseVersion"