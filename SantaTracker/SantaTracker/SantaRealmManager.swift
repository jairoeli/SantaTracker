//
//  SantaRealmManager.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

//  Note from tutorial: this is a class and not a stuct
//  because we will want to hold some state once we're
//  logged in so that we don't have to re-authenticate
//  repeatedly

import Foundation
import RealmSwift

class SantaRealmManager {
  private let username = "santatracker@realm.io"
  private let password = "h0h0h0"
  
  private let authServerURL = URL(string: "http://162.243.150.99:9080")!
  private let syncServerURL = URL(string: "realm://162.243.150.99:9080/santa")!
  
  //Properties
  private var user: SyncUser?
  
  //Log in.
  //Takes a completion function which, if defined will
  //be invoked upon successful log in (or if we're
  //already logged in)
  func logIn(completion:((Void)->Void)? = nil) {
    guard user == nil else {
      //already logged in, complete and return
      completion?()
      return
    }
    let credentials = SyncCredentials.usernamePassword(username: username, password: password)
    SyncUser.logIn(with: credentials, server: authServerURL) { user, error in
      if let user = user {
        //we're logged in, execute the callback on the main thread
        self.user = user
        DispatchQueue.main.async {
          completion?()
        }
      } else if let error = error {
        //otherwise if we have an error
        fatalError("Could not log in: \(error)")
      }
    }
  }
  
  //Get a Realm instance based on the logged in user.
  //If we're not logged in, return nil.
  func realm() -> Realm? {
    if let user = user {
      let syncConfig = SyncConfiguration(user: user, realmURL: syncServerURL)
      let config = Realm.Configuration(syncConfiguration: syncConfig)
      guard let realm = try? Realm(configuration:config) else {
        fatalError("Could not load Realm")
      }
      return realm
    } else {
      return nil
    }
  }
}
