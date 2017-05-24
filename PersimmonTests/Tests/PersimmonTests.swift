//
//  PersimmonTests.swift
//  Persimmon
//
//  Created by Nurdaulet Bolatov on 5/24/17.
//  Copyright © 2017 Zero To One Labs. All rights reserved.
//

import XCTest
import Parse
@testable import Persimmon

class PersimmonTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testGoal() {
    let goal = Goal()
    goal.category = 0
    XCTAssert(goal.categoryDescription == "Spirituality")
  }

  func testStringExtensions() {
    var str = "test"
    XCTAssert(str.firstLetterUppercase() == "Test")
  }

  func testPFUserExtensions() {
    let user = PFUser(email: "test@t.kz", password: "pass", name: "name")
    XCTAssert(user.email == "test@t.kz")
    XCTAssert(user.username == "test@t.kz")
    XCTAssertNotNil(user["name"])
    XCTAssert(user["name"] as! String  == "name")
    XCTAssert(user.password == "pass")
  }

  func testNSDateExtensions() {
    let date1 = NSDate(timeIntervalSinceNow: 1000)
    let date2 = NSDate(timeIntervalSinceNow: 2000)
    XCTAssert(date1 == date1)
    XCTAssert(date1 < date2)
    XCTAssert(date2 > date1)
  }

}
