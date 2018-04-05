//
//  Converter.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class Converter {
  private static let feetInMeter: Double = 3.281
  private static let fahrenheitMultiplier: Float = 9.0 / 5.0
  private static let celsiusFraction: Float = 5.0 / 9.0
  private static let fahrenheitAmountToAdd: Float = 32.0
  private static let celsiusMultiplier: Float = 1.0
  private static let celsiusAmountToAdd: Float = 0.0
  private static let altitudeFudge: Double = 5.0
  private static let secondsPerMinute: Int = 60
  private static let minutesPerHour: Int = 60
  private static let secondsPerHour: Int = 3600
  private static let netCaloriesPerKiloPerMeter = 0.00086139598517
  private static let totalCaloriesPerKiloPerMeter = 0.00102547141092
  private static let fahrenheitAbbr: String = "F"
  private static let celsiusAbbr: String = "C"
  private static let mileAbbr: String = "mi"
  private static let kilometerAbbr: String = "km"
  private static let feetAbbr: String = "ft"
  private static let metersAbbr: String = "m"
  private static let feet: String = "feet"
  private static let meters: String = "meters"
  private static let mile: String = "mile"
  private static let kilometer: String = "kilometer"
  private static let miles: String = "miles"
  private static let kilometers: String = "kilometers"
  static let metersInMile: Double = 1609.344
  static let metersInKilometer: Double = 1000.0
  static let kilometersPerMile: Float = 1.609344
  static let poundsPerKilogram = 2.2
  
  class func netCaloriesAsString(_ distance: Double, weight: Double) -> String {
    return String(format: "%.0f Cal", weight * distance * netCaloriesPerKiloPerMeter)
  }
  
  class func totalCaloriesAsString(_ distance: Double, weight: Double) -> String {
    return String(format: "%.0f Cal", weight * distance * totalCaloriesPerKiloPerMeter)
  }
  
  class func announceProgress(_ totalSeconds: Int, lastSeconds: Int, totalDistance: Double, lastDistance: Double, newAltitude: Double, oldAltitude: Double) {
    let totalLongDistance = convertMetersToLongDistance(totalDistance)
    var roundedDistance = NSString(format: "%.2f", totalLongDistance) as String
    if roundedDistance.last! == "0" {
      roundedDistance = String(roundedDistance[..<roundedDistance.index(before: roundedDistance.endIndex)])
    }
    var progressString = "total distance \(roundedDistance) \(pluralizedCurrentLongUnit(totalLongDistance)), total time \(stringifySecondCount(totalSeconds, useLongFormat: true)), split pace"
    let distanceDelta = totalDistance - lastDistance
    let secondsDelta = totalSeconds - lastSeconds
    progressString += stringifyPace(distanceDelta, seconds: secondsDelta, forSpeaking: true)
    let altitudeDelta = newAltitude - oldAltitude
    if altitudeDelta > 0.0 + altitudeFudge {
      progressString += ", gained \(stringifyAltitude(altitudeDelta, unabbreviated: true))"
    }
    else if altitudeDelta < 0.0 - altitudeFudge {
      progressString += ", lost \(stringifyAltitude(-altitudeDelta, unabbreviated: true)))"
    }
    else {
      progressString += ", no altitude change"
    }
    Utterer.utter(progressString)
  }

  class func announceCurrentPace(_ pace: Double) {
    Utterer.utter(stringifyPace(pace, seconds: 1, forSpeaking: true))
  }
  
  class func pluralizedCurrentLongUnit(_ value: Double) -> String {
    switch SettingsManager.getUnitType() {
    case .imperial:
      if value <= 1.0 {
        return mile
      }
      else {
        return miles
      }
    case .metric:
      if value <= 1.0 {
        return kilometer
      }
      else {
        return kilometers
      }
    }
  }

  class func convertLongDistanceToMeters(_ longDistance: Double) -> Double {
    switch SettingsManager.getUnitType() {
    case .imperial:
      return longDistance * metersInMile
    case .metric:
      return longDistance * metersInKilometer
    }
  }

  class func convertMetersToLongDistance(_ meters: Double) -> Double {
    switch SettingsManager.getUnitType() {
    case .imperial:
      return meters / metersInMile
    case .metric:
      return meters / metersInKilometer
    }
  }
  
  class func stringifyKilometers(_ kilometers: Float, includeUnits: Bool = false) -> String {
    var number = kilometers
    var units = ""
    if SettingsManager.getUnitType() == .metric {
      units = Converter.kilometerAbbr
    }
    else {
      units = Converter.mileAbbr
      number /= kilometersPerMile
    }
    var output = String(format: "%.0f", number)
    if includeUnits {
      output += " " + units
    }
    return output
  }
  
  class func floatifyMileage(_ mileage: String) -> Float {
    if SettingsManager.getUnitType() == .metric {
      return Float(mileage)!
    }
    else {
      return Float(mileage)! * Converter.kilometersPerMile
    }
  }
  
  class func getCurrentLongUnitName() -> String {
    return SettingsManager.getUnitType() == .imperial ? "mile" : "kilometer"
  }

  class func getCurrentAbbreviatedLongUnitName() -> String {
    return SettingsManager.getUnitType() == .imperial ? "mile" : "km"
  }
  
  class func getCurrentPluralLongUnitName() -> String {
    return SettingsManager.getUnitType() == .imperial ? "miles" : "kms"
  }
  
  class func convertFahrenheitToCelsius(_ temperature: Float) -> Float {
    return celsiusFraction * (temperature - fahrenheitAmountToAdd)
  }
  
  class func stringifyDistance(_ meters: Double, format: NSString = "%.2f", omitUnits: Bool = false) -> String {
    var distance: NSString
    var unitDivider: Double
    var unitName: String
    if SettingsManager.getUnitType() == .metric {
      unitName = kilometerAbbr
      unitDivider = metersInKilometer
    }
    else {
      unitName = mileAbbr
      unitDivider = metersInMile
    }
    distance = NSString(format: format, meters / unitDivider)
    if !omitUnits {
      distance = NSString(format: "%@ %@", distance, unitName)
    }
    return distance as String
  }
  
  class func stringifySecondCount(_ seconds: Int, useLongFormat: Bool, useLongUnits: Bool = false) -> String {
    var remainingSeconds = seconds
    let hours = remainingSeconds / secondsPerHour
    remainingSeconds -= hours * secondsPerHour
    let minutes = remainingSeconds / secondsPerMinute
    remainingSeconds -= minutes * secondsPerMinute
    if useLongFormat {
      if useLongUnits {
        if hours > 0 {
          return NSString(format: "%d hour %d minutes %d seconds", hours, minutes, remainingSeconds) as String
        } else if minutes > 0 {
          return NSString(format: "%d minutes %d seconds", minutes, remainingSeconds) as String
        } else {
          return NSString(format: "%d seconds", remainingSeconds) as String
        }
      }
      else {
        if hours > 0 {
          return NSString(format: "%d hr %d min %d sec", hours, minutes, remainingSeconds) as String
        } else if minutes > 0 {
          return NSString(format: "%d min %d sec", minutes, remainingSeconds) as String
        } else {
          return NSString(format: "%d sec", remainingSeconds) as String
        }
      }
    }
    else {
      if hours > 0 {
        return NSString(format: "%d:%02d:%02d", hours, minutes, remainingSeconds) as String
      } else if minutes > 0 {
        return NSString(format: "%d:%02d", minutes, remainingSeconds) as String
      } else {
        return NSString(format: "%d", remainingSeconds) as String
      }
    }
  }
  
  class func stringifyPace(_ meters: Double, seconds:Int, forSpeaking:Bool = false, includeUnit: Bool = true) -> String {
    if seconds == 0 || meters == 0.0 {
      return "0"
    }
    
    let avgPaceSecMeters = Double(seconds) / meters
    var unitMultiplier: Double
    var unitName: String
    if forSpeaking {
      if SettingsManager.getUnitType() == .metric {
        unitName = getCurrentLongUnitName()
        unitMultiplier = metersInKilometer
      }
      else {
        unitName = getCurrentLongUnitName()
        unitMultiplier = metersInMile
      }
    }
    else {
      if SettingsManager.getUnitType() == .metric {
        unitName = "min/" + kilometerAbbr
        unitMultiplier = metersInKilometer
      }
      else {
        unitName = "min/" + mileAbbr
        unitMultiplier = metersInMile
      }
    }
    let paceMin = Int((avgPaceSecMeters * unitMultiplier) / Double(secondsPerMinute))
    let paceSec = Int(avgPaceSecMeters * unitMultiplier - Double((paceMin * secondsPerMinute)))
    if !includeUnit {
      unitName = ""
    }
    if forSpeaking {
      return NSString(format: "%d minutes %d seconds per %@", paceMin, paceSec, unitName) as String
    }
    else {
      return NSString(format: "%d:%02d %@", paceMin, paceSec, unitName) as String
    }
  }

  class func stringifyAltitude(_ meters: Double, unabbreviated: Bool = false, includeUnit: Bool = true) -> String {
    var unitMultiplier: Double
    var unitName: String
    if SettingsManager.getUnitType() == .metric {
      unitMultiplier = 1.0
      if !unabbreviated {
        unitName = metersAbbr
      }
      else {
        unitName = Converter.meters
      }
    }
    else {
      unitMultiplier = feetInMeter
      if !unabbreviated {
        unitName = feetAbbr
      }
      else {
        unitName = feet
      }
    }
    if !includeUnit {
      unitName = ""
    }
    return NSString(format: "%.0f %@", meters * unitMultiplier, unitName) as String
  }
  
  class func stringifyTemperature(_ temperature: Float) -> String {
    var unitName: String
    var multiplier: Float
    var amountToAdd: Float
    if SettingsManager.getUnitType() == .metric {
      unitName = celsiusAbbr
      multiplier = celsiusMultiplier
      amountToAdd = celsiusAmountToAdd
    }
    else {
      unitName = fahrenheitAbbr
      multiplier = fahrenheitMultiplier
      amountToAdd = fahrenheitAmountToAdd
    }
    return NSString(format: "%.0f° %@", temperature * multiplier + amountToAdd, unitName) as String
  }
}
