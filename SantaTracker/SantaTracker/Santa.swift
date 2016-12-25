//
//  Santa.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import RealmSwift

class Santa: Object {
  private dynamic var _currentLocation: Location?
  var currentLocation: Location {
    get {
      //If there's a value, return it, otherwise Santa's at the North Pole
      return _currentLocation ?? Location(latitude: 90, longitude: 180)
    }
    set {
      _currentLocation = newValue
    }
  }
  
  let route = List<Stop>()
  
  private dynamic var _activity: Int = 0
  var activity: Activity {
    get {
      return Activity(rawValue: _activity)!
    }
    set {
      _activity = newValue.rawValue
    }
  }
  
  dynamic var presentsRemaining: Int = 0
  override static func ignoredProperties() -> [String] {
    //Object properties must be optional, so 'currentLocation' should
    //be ignored.
    //Realm will ignore read-only properties, but currentLocation has a
    //setter
    return ["currentLocation", "activity"]
  }
  
  //KVO stuff
  //Map of Object to NotificationToken
  private var observerTokens = [NSObject: NotificationToken]()
  
  //Function to add KVO notifications for properties that we're interested in
  func addObserver(_ observer: NSObject) {
    //add KVO observer to all the properties
    addObserver(observer, forKeyPath: #keyPath(Santa._currentLocation), options: .initial, context: nil)
    //...including the lat and long
    addObserver(observer, forKeyPath: #keyPath(Santa._currentLocation.latitude), options: .initial, context: nil)
    addObserver(observer, forKeyPath: #keyPath(Santa._currentLocation.longitude), options: .initial, context: nil)
    addObserver(observer, forKeyPath: #keyPath(Santa._activity), options: .initial, context: nil)
    addObserver(observer, forKeyPath: #keyPath(Santa.presentsRemaining), options: .initial, context: nil)
    
    //what is going on here?
    //"brings route observation into the same code path by redirecting Realm collection notifications into KVO notifications."
    //https://realm.io/docs/swift/latest/api/Classes/Realm.html#/s:FC10RealmSwift5Realm20addNotificationBlockFFTOS0_12NotificationS0__T_CSo20RLMNotificationToken
    observerTokens[observer] = route.addNotificationBlock{
      [unowned self, weak observer] changes in
      switch changes {
      case .initial:
        observer?.observeValue(forKeyPath: "route", of: self, change: nil, context: nil)
      case .update:
        observer?.observeValue(forKeyPath: "route", of: self, change: nil, context: nil)
      case .error:
        fatalError("Couldn't update Santa's info")
      }
    }
  }
  
  //Functio to remove the Observer
  func removeObserver(_ observer: NSObject) {
    observerTokens[observer]?.stop()
    observerTokens.removeValue(forKey: observer)
    removeObserver(observer, forKeyPath: #keyPath(Santa._currentLocation))
    removeObserver(observer, forKeyPath: #keyPath(Santa._currentLocation.latitude))
    removeObserver(observer, forKeyPath: #keyPath(Santa._currentLocation.longitude))
    removeObserver(observer, forKeyPath: #keyPath(Santa._activity))
    removeObserver(observer, forKeyPath: #keyPath(Santa.presentsRemaining))
  }
}

extension Santa {
  //For convenience, we have a function that returns a sample Santa
  static func test() -> Santa {
    let santa = Santa()
    santa.currentLocation = Location(latitude: 49.282729, longitude: -123.120738)
    santa.activity = .deliveringPresents
    santa.presentsRemaining = 42
    return santa
  }
}
