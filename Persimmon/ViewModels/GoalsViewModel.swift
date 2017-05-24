//
//  GoalsViewModel.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/7/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Parse
import ReactiveCocoa
import enum Result.NoError
import EDSunriseSet
import UIKit

enum TimeOfDay: Int {
  case Day, Evening, Undefined
}

protocol GoalsViewLayoutDelegate {
  func goalsViewLayoutTimeDidChange(time: TimeOfDay,
    timeIntervalBetweenTimeOfDays: NSTimeInterval, timeIntervalToFollowingTimeOfDay: NSTimeInterval)
}

final class GoalsViewLayout: NSObject, CLLocationManagerDelegate {
  var delegate: GoalsViewLayoutDelegate? {
    didSet { minuteTimer.fire() }
  }
  private lazy var minuteTimer: NSTimer = {
    return NSTimer.scheduledTimerWithTimeInterval(60, target: self,
      selector: #selector(timeDidChange), userInfo: nil, repeats: true)
  }()
  private lazy var locationManager: CLLocationManager = {
    return CLLocationManager().then {
      $0.delegate = self
      $0.requestWhenInUseAuthorization()
    }
  }()
  private var sunriseSet: EDSunriseSet? {
    func sunriseSet(forCoordinate coordinate: CLLocationCoordinate2D) -> EDSunriseSet {
      return EDSunriseSet(timezone: .localTimeZone(),
        latitude: coordinate.latitude, longitude: coordinate.longitude).then {
          $0.calculateSunriseSunset(NSDate())
      }
    }
    
    if let userCoordinate = userCoordinate {
      return sunriseSet(forCoordinate: userCoordinate)
    } else if let lastKnownCoordinate = locationManager.location?.coordinate {
      return sunriseSet(forCoordinate: lastKnownCoordinate)
    }
    
    return nil
  }
  private var sunrise: NSDate? {
    return sunriseSet?.sunrise ?? .expectedSunrise
  }
  private var sunset: NSDate? {
    return sunriseSet?.sunset ?? .expectedSunset
  }
  private var userCoordinate: CLLocationCoordinate2D?
  
  var time: TimeOfDay {
    guard let sunriseSet = sunriseSet else {
      let currentHour = NSDate.currentHour
      return (currentHour >= Constants.Sunset.expectedSunsetHour ||
        currentHour < Constants.Sunset.expectedSunriseHour) ? .Evening : .Day
    }

    return NSDate().timeIntervalSince1970 >= sunriseSet.sunset.timeIntervalSince1970 ?
      .Evening : .Day
  }
  
  override init() {
    super.init()
    locationManager.requestLocation()
  }
  
  // called each time a minute passes, or time variables' value is changed
  func timeDidChange() {
    scheduleLocalPushNotifications()
    guard let delegate = delegate, sunsetDate = sunset,
      sunriseDate = sunrise  else { return }
    
    let timeInterval = time == .Day ? sunriseDate.timeInterval(tillDate: sunsetDate) :
      sunsetDate.timeInterval(tillDate: sunriseDate)
    let timeIntervalToFollowingTimeOfDay = time == .Day ?
      NSDate().timeInterval(tillDate: sunsetDate) : NSDate().timeInterval(tillDate: sunriseDate)
    
    delegate.goalsViewLayoutTimeDidChange(time, timeIntervalBetweenTimeOfDays: timeInterval,
      timeIntervalToFollowingTimeOfDay: timeIntervalToFollowingTimeOfDay)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let userLocation = locations.first else { return }
    log.verbose("location: \(userLocation)")
    userCoordinate = userLocation.coordinate
  }
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    log.error("location manager failed with error: \(error)")
  }
  
  func scheduleLocalPushNotifications() {
    guard let sunsetDate = sunset, sunriseDate = sunrise else { return }
    
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    UILocalNotification.scheduleDailyLocalNotification(sunriseDate,
      alertBody: "Bonjour! It’s time to review your goals and visualize your desired future.")
    UILocalNotification.scheduleDailyLocalNotification(sunsetDate,
      alertBody: "Bonsoir! Don’t bail out :) Reflect: what tiny step have you taken towards your goals?")
  }
}

class GoalsViewModel {
  var layout: SignalProducer<GoalsViewLayout, NoError> {
    return SignalProducer { observer, _ in
      observer.sendNext(GoalsViewLayout())
      NSNotificationCenter.defaultCenter().rac_notifications(UIApplicationDidBecomeActiveNotification, object: nil)
        .startWithNext { next in
          observer.sendNext(GoalsViewLayout())
        }
    }
  }
  var userGoals: SignalProducer<[UserGoal], DataError> {
    return UserGoal.getUserGoals()
  }
  
  func userGoalEntries(forUserGoals userGoals: [UserGoal]) -> SignalProducer<[UserGoalEntry], DataError> {
    return UserGoalEntry.getCompletedUserGoalEntries(forUserGoals: userGoals)
  }
  
  func saveUserGoals(userGoals: [UserGoal]) -> SignalProducer<Bool, DataError> {
    return Goal.saveUserGoals(userGoals)
  }
}