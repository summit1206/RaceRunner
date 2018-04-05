//
//  DarkSky.swift
//
//  Created by Josh Adams on 3/20/15.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//  This code is based on https://github.com/bfolder/Sweather .

import Foundation
import CoreLocation

open class DarkSky {
  private static let basePath = "https://api.forecast.io/forecast/"
  private static let apiKey = Config.darkSkyKey
  private static let noApiKey = "This app cannot query Dark Sky for current temperature and weather until you obtain an API key and put it in Config.swift. Here is the website to get an API key: https://developer.forecast.io/register You can ignore the following error message, which Dark Sky returned due to the empty API key."
  
  public enum Result {
    case success(URLResponse?, NSDictionary?)
    case error(URLResponse?, NSError?)
    
    public func data() -> NSDictionary? {
      switch self {
      case .success(_, let dictionary):
        return dictionary
      case .error(_, _):
        return nil
      }
    }
    
    public func response() -> URLResponse? {
      switch self {
      case .success(let response, _):
        return response
      case .error(let response, _):
        return response
      }
    }
    
    public func nSError() -> NSError? {
      switch self {
      case .success(_, _):
        return nil
      case .error(_, let error):
        return error
      }
    }
  }
  
  private var queue: OperationQueue;
  
  public init() {
    self.queue = OperationQueue()
  }
  
  open func currentWeather(_ coordinate: CLLocationCoordinate2D, callback: @escaping (Result) -> ()) {
    let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
    call(coordinateString, callback: callback);
  }
  
  private func call(_ method: String, callback: @escaping (Result) -> ()) {    
    if DarkSky.apiKey == "" {
      fatalError(DarkSky.noApiKey)
    }
    let currentQueue = OperationQueue.current;
    let url = URL(string: DarkSky.basePath + DarkSky.apiKey + "/" + method)
    URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
      let error: NSError? = error as NSError?
      var dictionary: NSDictionary?

      if let data = data {
        do {
          try dictionary = JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
        }
        catch let error as NSError {
          print(error.localizedDescription)
        }
      }
      currentQueue?.addOperation {
        var result = Result.success(response, dictionary)
        if error != nil {
          result = Result.error(response, error)
        }
        callback(result)
      }
    }).resume()
  }
}
