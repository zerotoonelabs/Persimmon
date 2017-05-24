//
//  UIFontExtensions.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/9/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

extension UIFont {
  static func latoRegularOfSize(size: CGFloat) -> UIFont {
    return UIFont(name: "Lato-Regular", size: size)!
  }
  static func latoLightOfSize(size: CGFloat) -> UIFont {
    return UIFont(name: "Lato-Light", size: size)!
  }
  static func openSansRegularOfSize(size: CGFloat) -> UIFont {
    return UIFont(name: "OpenSans", size: size)!
  }
}