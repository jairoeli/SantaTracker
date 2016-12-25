//
//  MapManager.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import MapKit
import UIKit

class MapManager: NSObject {
  private let mapView:MKMapView
  private let santaAnnotation = MKPointAnnotation()
  //overlay for plotting Santa's route
  private var routeOverlay: MKPolyline
  
  init(mapView: MKMapView) {
    self.mapView = mapView
    santaAnnotation.title = "🎅🏼"
    //initialize the route overlay
    routeOverlay = MKPolyline(coordinates:[], count: 0)
    super.init()
    mapView.addAnnotation(self.santaAnnotation)
    //set the delegate
    self.mapView.delegate = self
  }
  
  func update(with santa:Santa) {
    //Update the mape to show Santa's location
    //but we need to make sure we do the UI update
    //on the main thread
    let santaLocation = santa.currentLocation.clLocationCoordinate2D
    //get list of coordinates that Santa has been to on his route
    let coordinates: [CLLocationCoordinate2D] = santa.route.flatMap({$0.location?.clLocationCoordinate2D})
    DispatchQueue.main.async {
      self.santaAnnotation.coordinate = santaLocation
      self.mapView.remove(self.routeOverlay)
      self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
      self.mapView.add(self.routeOverlay)
    }
    
  }
}

extension MapManager: MKMapViewDelegate {
  //get the overlay renderer for a give mapview and overlay
  func mapView(_ mapView:MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard overlay is MKPolyline else {
      //if the overlay isn't an MKPolyline, return
      //a default overlay renderer
      return MKOverlayRenderer(overlay: overlay)
    }
    //Otherwise, construt and return an MKPolylineRendere
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .black
    renderer.lineWidth = 3
    renderer.lineDashPattern = [3,6]
    return renderer
  }
}
private extension Location {
  //convert the Location's lat and long to CoreLocation coordinates
  //so that we can use them with MK
  var clLocationCoordinate2D: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
