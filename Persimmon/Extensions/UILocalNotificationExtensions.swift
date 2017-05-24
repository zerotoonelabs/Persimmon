//
//  UILocalNotificationExtensions.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/9/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Sugar
import UIKit

extension UILocalNotification {
  static func scheduleDailyLocalNotification(fireDate: NSDate, alertBody: String) {
    UILocalNotification().then {
      $0.timeZone = NSTimeZone.localTimeZone()
      $0.repeatInterval = .Day
      $0.alertBody = alertBody
      $0.fireDate = fireDate > NSDate() ? fireDate :
        NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: fireDate, options: .WrapComponents)
      UIApplication.sharedApplication().scheduleLocalNotification($0)
    }
  }
}