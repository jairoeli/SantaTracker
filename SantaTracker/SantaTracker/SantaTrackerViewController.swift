//
//  SantaTrackerViewController.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class SantaTrackerViewController: UIViewController {
  
  @IBOutlet private weak var timeRemainingLabel: UILabel!
  @IBOutlet private weak var mapView: MKMapView!
  @IBOutlet private weak var activityLabel: UILabel!
  @IBOutlet private weak var temperatureLabel: UILabel!
  @IBOutlet private weak var presentsRemainingLabel: UILabel!
  @IBOutlet weak var conditionIconView: UIImageView!
  
  private var mapManager : MapManager!
  //Notification token that we use to get notified
  //when Santa data has been downloaded
  private var notificationToken: NotificationToken?
  //Keep a reference to Santa so that we can use KVO
  private var santa: Santa?
  private let realmManager = SantaRealmManager()
  private var weather: Weather?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //set up the map manager
    mapManager = MapManager(mapView: self.mapView)
    //log into Realm and find Santa
    realmManager.logIn {
      if let realm = self.realmManager.santaRealm() {
        let santas = realm.objects(Santa.self)
        //if we have a Santa data, just use it
        if let santa = santas.first {
          //register this controller as the Observer
          santa.addObserver(self)
        } else {
          //otherwise, get notified when Santa data
          //has been downloaded
          self.notificationToken = santas.addNotificationBlock{
            _ in
            let santas = realm.objects(Santa.self)
            if let santa = santas.first {
              self.notificationToken?.stop()
              self.notificationToken = nil
              self.santa = santa
              santa.addObserver(self)
            }
          }
        }
      }
    }
  }
  
  private func update(with santa:Santa) {
    mapManager.update(with: santa)
    let activity = santa.activity.description
    let presentsRemaining = "\(santa.presentsRemaining)"
    DispatchQueue.main.async {
      self.activityLabel.text = activity
      self.presentsRemainingLabel.text = presentsRemaining
    }
    
    guard let weatherRealm = realmManager.weatherRealm() else { return }
    weather?.removeObserver(self)
    let weatherLocation = Location(latitude: santa.currentLocation.longitude, longitude: santa.currentLocation.longitude)
    let newWeather = Weather(location: weatherLocation)
    try? weatherRealm.write {
      weatherRealm.add(newWeather)
    }
    newWeather.addObserver(self)
    weather = newWeather
  }
  
  private func update(with weather: Weather) {
    let temperatureText: String
    let conditionIcon: UIImage
    switch weather.loadingStatus {
    case .uploading:
      temperatureText = "??"
      conditionIcon = Weather.Condition.unknown.icon
    case .processing:
      temperatureText = "..."
      conditionIcon = Weather.Condition.unknown.icon
    case .complete(temperature: let temperature, condition: let condition):
      temperatureText = "\(temperature)°C"
      conditionIcon = condition.icon
    }
    DispatchQueue.main.async {
      self.temperatureLabel.text = temperatureText
      self.conditionIconView.image = conditionIcon
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //if we are notified of a value change, check to see if it's Santa
    if let santa = object as? Santa {
      update(with: santa)
    } else if let weather = object as? Weather {
      update(with: weather)
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  deinit {
    //If we're holding onto a Santa, unregister this view controller
    //as an Observer
    santa?.removeObserver(self)
  }
  
}
