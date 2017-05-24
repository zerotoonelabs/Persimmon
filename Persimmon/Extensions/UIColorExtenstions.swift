//
//  UIColorExtenstions.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/22/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

extension UIColor {
  class func successColor() -> UIColor {
    return UIColor(red: 21/255, green: 192/255, blue: 119/255, alpha: 1)
  }
  class func failColor() -> UIColor {
    return UIColor(red: 243/255, green: 0/255, blue: 29/255, alpha: 1)
  }
  class func persimmonColor() -> UIColor {
    return UIColor(red: 236/255, green: 88/255, blue: 0, alpha: 1)
  }
  class func persimmonLightColor() -> UIColor {
    return UIColor(red: 248/255, green: 123/255, blue: 49/255, alpha: 1)
  }
  class func authorizationTextFieldPlaceholderColor() -> UIColor {
    return UIColor(red: 236/255, green: 88/255, blue: 0, alpha: 1)
  }
}