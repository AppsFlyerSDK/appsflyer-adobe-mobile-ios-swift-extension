//
//  ViewController.swift
//  Adobe AEP Sample
//
//  Created by Paz Lavi  on 07/10/2021.
//

import UIKit
import AEPCore
import AppsFlyerLib
class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func onLogEventClicked(_ sender: Any) {
    MobileCore.track(action: "testAnalyticsAction", data: ["revenue":"200","currency":"ILS", "name":"AppsFlyer"])
  }
  
}

