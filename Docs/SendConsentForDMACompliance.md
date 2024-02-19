## <a id="dma_support"> Send consent for DMA compliance
For a general introduction to DMA consent data, see [here](https://dev.appsflyer.com/hc/docs/send-consent-for-dma-compliance).<be>
The SDK offers two alternative methods for gathering consent data:<br>
- **Through a Consent Management Platform (CMP)**: If the app uses a CMP that complies with the [Transparency and Consent Framework (TCF) v2.2 protocol](https://iabeurope.eu/tcf-supporting-resources/), the SDK can automatically retrieve the consent details.<br>
<br>OR<br><br>
- **Through a dedicated SDK API**: Developers can pass Google's required consent data directly to the SDK using a specific API designed for this purpose.
### Use CMP to collect consent data
A CMP compatible with TCF v2.2 collects DMA consent data and stores it in <code>NSUserDefaults</code>. To enable the SDK to access this data and include it with every event, follow these steps:<br>
<ol>
  <li> Call <code>AppsFlyerLib.shared().enableTCFDataCollection(true)</code> to instruct the SDK to collect the TCF data from the device.
  <li> Set the extension to be on manual mode to <code>true</code>- meaning the developer will have the responsability to start the SDK.</br>
       This will allow us to delay the Conversion call in order to provide the SDK with the user consent.
  <li> Initialize <code>MobileCore</code>. 
  <li> In the <code>applicationDidBecomeActive</code> lifecycle method, use the CMP to decide if you need the consent dialog in the current session to acquire the consent data. If you need the consent dialog move to step 4; otherwise move to step 5.
  <li> Get confirmation from the CMP that the user has made their consent decision and the data is available in <code>NSUserDefaults</code>.
  <li> Call start() to the SDK and also set the manual mode to <code>false</code>.
</ol>


```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // For AppsFLyer debug logs uncomment the line below
    AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
    AppsFlyerLib.shared().enableTCFDataCollection(true)
    AppsFlyerAdobeExtension.manual = true
    MobileCore.setLogLevel(.debug)
    MobileCore.registerExtensions([Lifecycle.self, Identity.self, Signal.self,
                                   Analytics.self,
                                   AEPMobileServices.self, AppsFlyerAdobeExtension.self]) {
    }
    MobileCore.configureWith(appId: "<ADOBE-DEV-KEY>")
    if appState != .background {
        // only start lifecycle if the application is not in the background
        MobileCore.lifecycleStart(additionalContextData: nil)
    }
    return true
}
```

### Manually collect consent data
If your app does not use a CMP compatible with TCF v2.2, use the SDK API detailed below to provide the consent data directly to the SDK.
<ol>
  <li> Set the extension to be on manual mode to <code>true</code>- meaning the developer will have the responsability to start the SDK.</br>
       This will allow us to delay the Conversion call in order to provide the SDK with the user consent.
  <li> Initialize <code>MobileCore</code>.
  <li> In the <code>applicationDidBecomeActive</code> lifecycle method determine whether the GDPR applies or not to the user.<br>
  - If GDPR applies to the user, perform the following: 
      <ol>
        <li> Given that GDPR is applicable to the user, determine whether the consent data is already stored for this session.
            <ol>
              <li> If there is no consent data stored, show the consent dialog to capture the user consent decision.
              <li> If there is consent data stored continue to the next step.
            </ol>
        <li> To transfer the consent data to the SDK create an AppsFlyerConsent object with the following parameters:<br>
          - <code>forGDPRUserWithHasConsentForDataUsage</code>- Indicates whether the user has consented to use their data for advertising purposes.
          - <code>hasConsentForAdsPersonalization</code>- Indicates whether the user has consented to use their data for personalized advertising.
        <li> Call <code>AppsFlyerLib.shared().setConsentData(AppsFlyerConsent(forGDPRUserWithHasConsentForDataUsage: Bool, hasConsentForAdsPersonalization: Bool))</code>. 
        <li> Call start() to the SDK and also set the manual mode to <code>false</code>..
      </ol><br>
    - If GDPR doesn’t apply to the user perform the following:
      <ol>
        <li> Call <code>AppsFlyerLib.shared().setConsentData(AppsFlyerConsent(nonGDPRUser: ()))</code>.
        <li> Call start() to the SDK and also set the manual mode to <code>false</code>.
      </ol>
</ol>
