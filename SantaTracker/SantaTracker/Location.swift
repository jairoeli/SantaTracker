//
//  Location.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import CoreLocation
import RealmSwift

class Location: Object {
  dynamic var latitude: Double = 0.0
  dynamic var longitude: Double = 0.0
  
  convenience init(latitude: Double, longitude: Double) {
    self.init()
    self.latitude = latitude
    self.longitude = longitude
  }
}

