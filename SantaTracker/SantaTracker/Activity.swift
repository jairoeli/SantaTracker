//
//  Activity.swift
//  SantaTracker
//
//  Created by Jairo Eli de Leon on 12/24/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

//Enum to represent any activity Santa may be
//currently engaged in. Backed by an Int because
//Ints are representable in Realm

import Foundation
import UIKit

enum Activity: Int {
  case unknown = 0
  case flying
  case deliveringPresents
  case tendingToReindeer
  case eatingCookies
  case callingMrsClaus
}

extension Activity: CustomStringConvertible {
  var description: String {
    switch self {
    case .unknown:
      return "❔ We're not sure what Santa's up to right now…"
    case .callingMrsClaus:
      return "📞 Santa is talking to Mrs. Claus on the phone!"
    case .deliveringPresents:
      return "🎁 Santa is delivering presents right now!"
    case .eatingCookies:
      return "Santa is having a snack of 🥛 and 🍪"
    case .flying:
      return "🚀 Santa is flying next to the house"
    case .tendingToReindeer:
      return "🦌 Santa is taking care of his reindeer."
    }
  }
}
