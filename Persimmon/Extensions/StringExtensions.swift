//
//  StringExtensions.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/9/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Foundation

extension String {
  mutating func firstLetterUppercase() -> String {
    replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
    return self
  }
}