//
//  Double+roundToPlaces.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/23/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

extension Double {
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
