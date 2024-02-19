## <a id="manual"> Manual mode
Starting version `6.13.0`, we support a manual mode to seperate the initialization of the AppsFlyer SDK and the start of the SDK.</br>
In this case, the AppsFlyer SDK won't start automatically, giving the developer more freedom when to start the AppsFlyer SDK.</br>
Please note that in manual mode, the developer is required to implement the API ``AppsFlyerLib.shared().start()`` in order to start the SDK.</br> 
You should set this mode before registering the `MobileCore` Extensions in `AppDelegate`.</br>
If you are using CMP to collect consent data this feature is needed. See explanation [here](/SendConsentForDMACompliance.md).
### Example:  
```swift
AppsFlyerAdobeExtension.manual = true;
``` 
Please look at the example below to see how to start SDK once you want.</br>Keep in mind you shouldn't put the `start()` on a lifecycle method.
To start the AppsFlyer SDK, use the `start()` API, like the following :  
```swift
AppsFlyerLib.shared().start()
AppsFlyerAdobeExtension.manual = false
```   
