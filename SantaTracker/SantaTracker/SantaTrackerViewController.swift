//
//  SantaTrackerViewController.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit

class SantaTrackerViewController: UIViewController {
  
  @IBOutlet private weak var timeRemainingLabel: UILabel!
  @IBOutlet private weak var mapView: MKMapView!
  @IBOutlet private weak var activityLabel: UILabel!
  @IBOutlet private weak var temperatureLabel: UILabel!
  @IBOutlet private weak var presentsRemainingLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
