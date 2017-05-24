//
//  DictionaryExtensions.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/10/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Foundation

extension Dictionary {
  public init(keys: [Key], values: [Value]) {
    precondition(keys.count == values.count)
    self.init()
    
    for (index, key) in keys.enumerate() {
      self[key] = values[index]
    }
  }
}