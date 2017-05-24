//
//  Constants.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/5/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

struct Constants {
  static let goalCharactersMaxCount = 100
  static let commentCharactersMaxCount = 140
  
  struct Authorization {
    static let placeholderAttributes = [NSFontAttributeName: UIFont.openSansRegularOfSize(17),
      NSForegroundColorAttributeName: UIColor.authorizationTextFieldPlaceholderColor()]
    static let textFieldInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
  
  struct Sunset {
    static let expectedSunsetHour = 18
    static let expectedSunriseHour = 7
  }
  
  struct Parse {
    static let applicationID = "9Ug7M3TseZ0r5MAu3ELzFOxWVMEGQvuN9Mv5AeIUD7A"
    static let clientKey = "ZdodK9EVRPCF89tfqb8o/Ro07KbpkZuv1CUlF2ZWkx8"
    static let server = "http://ec2-34-205-155-234.compute-1.amazonaws.com/parse-dev"
  }
}

enum DataError: ErrorType {
  case Parse(error: NSError?)
}
