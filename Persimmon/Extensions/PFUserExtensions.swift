//
//  PFUser.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/9/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Parse

extension PFUser {
  convenience init(email: String?, password: String?, name: String?) {
    self.init()
    self["name"] = name
    self.email = email
    self.username = email
    self.password = password
  }
}