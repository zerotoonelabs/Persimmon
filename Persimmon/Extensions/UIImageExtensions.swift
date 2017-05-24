//
//  UIImageExtensions.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/10/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import UIKit

enum Asset: String {
  case PersimmonIcon = "Logo"
  case CalendarIcon = "CalendarIcon"
  case ReverseIcon = "ReverseIcon"
  case EditIcon = "EditIcon"
  case MoonIcon = "MoonIcon"
  case SunIcon = "SunIcon"
  
  case CheckUpIcon = "CheckUpIcon"
  case CheckDownIcon = "CheckDownIcon"
  
  case FamilyIcon = "FamilyIcon"
  case CareerIcon = "CareerIcon"
  case EducationIcon = "EducationIcon"
  case LoveIcon = "LoveIcon"
  case HealthIcon = "HealthIcon"
  case FinanceIcon = "FinanceIcon"
  case SpiritualityIcon = "SpiritualityIcon"
  
  case CareerBackground = "CareerBackground"
  case EducationBackground = "EducationBackground"
  case FamilyBackground = "FamilyBackground"
  case FinanceBackground = "FinanceBackground"
  case HealthBackground = "HealthBackground"
  case LoveBackground = "LoveBackground"
  case SpiritualityBackground = "SpiritualityBackground"
  
  case CareerGoalIcon = "CareerGoalIcon"
  case EducationGoalIcon = "EducationGoalIcon"
  case FamilyGoalIcon = "FamilyGoalIcon"
  case FinanceGoalIcon = "FinanceGoalIcon"
  case HealthGoalIcon = "HealthGoalIcon"
  case LoveGoalIcon = "LoveGoalIcon"
  case SpiritualityGoalIcon = "SpiritualityGoalIcon"

  case LaunchIcon = "LaunchIcon"
  case ShareImageBase = "ShareImageBase"
  
  var image: UIImage {
    return UIImage(asset: self)
  }
}

extension UIImage {
  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}

extension UIImage {
  class func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  func resizeImage(width: CGFloat) -> UIImage {
    var scale = width / size.width
    var newHeight = size.height * scale
    var newWidth = width
    
    if newHeight < newWidth {
      scale = newWidth / newHeight
      newHeight = newHeight * scale
      newWidth *= scale
    }
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    drawInRect(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func isEqualData(anotherImage secondImage: UIImage) -> Bool? {
    guard let firstImageData = UIImagePNGRepresentation(self),
      secondImageData = UIImagePNGRepresentation(secondImage) else { return nil }
    return firstImageData.isEqualToData(secondImageData)
  }
}
