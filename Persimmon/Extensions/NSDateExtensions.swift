//
//  NSDateExtensions.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/19/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Foundation

extension NSDate {
  static var today: NSDate {
    return NSCalendar.currentCalendar().startOfDayForDate(NSDate())
  }
  static var expectedSunset: NSDate? {
    return expectedSunsetSunriseDate()
  }
  static var expectedSunrise: NSDate? {
    return expectedSunsetSunriseDate(sunset: false)
  }
  static var currentHour: Int {
    return NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
  }
  
  static func expectedSunsetSunriseDate(sunset sunset: Bool = true) -> NSDate? {
    let calendar = NSCalendar.currentCalendar()
    calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
    let components = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
    components.hour = sunset ? Constants.Sunset.expectedSunsetHour : Constants.Sunset.expectedSunriseHour
    return calendar.dateFromComponents(components)
  }
  
  func timeInterval(tillDate tillDate: NSDate) -> NSTimeInterval {
    return tillDate.timeIntervalSince1970 - timeIntervalSince1970
  }
}

extension NSDate: Comparable {}
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
public func >(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}