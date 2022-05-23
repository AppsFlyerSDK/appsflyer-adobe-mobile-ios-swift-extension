//
//  AppsFlyerAdobeExtensionTests.swift
//  AppsFlyerAdobeExtensionTests
//
//  Created by Paz Lavi  on 05/10/2021.
//

@testable import AEPCore
@testable import AppsFlyerAdobeAEPExtension
import AEPServices
import XCTest

class AppsFlyerAdobeExtensionTests: XCTestCase {
  var af: AppsFlyerAdobeExtension!
  var mockRuntime: TestableExtensionRuntime!
  
  override func setUp() {
    mockRuntime = TestableExtensionRuntime()
         af = AppsFlyerAdobeExtension(runtime: mockRuntime)
         af.onRegistered()
  }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//
//      let data =   [
//        "lifecycle.sessionTimeout" : 300,
//        "rules.url" : "https://assets.adobedtm.com/cc3f5fb64390/1c294e62d3a0/launch-68b377824e37-development-rules.zip",
//        "inAppEventSetting" : "all",
//        "property.id" : "PR730449e42f7e48e5b5b0edc579dd78e5",
//        "appsFlyerAppId" : "1534996322",
//        "appsFlyerWaitForECID" : true,
//        "appsFlyerDevKey" : "4ux8wjmC9qP6qc3UWZ5Ldh",
//        "global.privacy" : "optedin",
//        "build.environment" : "dev",
//        "appsFlyerIsDebug" : true,
//        "appsFlyerTrackAttrData" : true,
//        "experienceCloud.org" : "3A163DF75853DDEC0A495ECF@AdobeOrg"
//      ] as [String : Any]
//      let appendUrlEvent = Event(name: "Test Append URL Event", type: EventType.configuration, source: EventSource.requestContent, data: data)
//     // mockRuntime.simulateSharedState(extensionName: ConfigurationConstants.EXTENSION_NAME, event: appendUrlEvent, data: (["testKey":"testVal"], .set))
//      mockRuntime.simulateSharedState(for: (AppsFlyerConstants.SharedStateKeys.CONFIGURATION, appendUrlEvent), data: (["testKey":"testVal"], .set))
//      // Inspect any `Event`s the Identity extension has dispatched
//        let responseEvent = mockRuntime.dispatchedEvents.first(where: {$0.responseID == appendUrlEvent.id})
//        XCTAssertNotNil(responseEvent)
//      //  XCTAssertNotNil(responseEvent?.data?[IdentityConstants.EventDataKeys.UPDATED_URL])

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
