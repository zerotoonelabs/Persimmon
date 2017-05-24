//
//  GoalEntry.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/19/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Foundation
import Parse
import Transporter
import ReactiveCocoa

enum UserGoalEntryState: Int {
  case DidCommit, DidNotCommit, Untouched
}

final class UserGoalEntry: PFObject, PFSubclassing {
  @NSManaged var date: NSDate
  @NSManaged var state: Int
  @NSManaged var comment: String
  @NSManaged var userGoal: UserGoal

  static func parseClassName() -> String {
    return "UserGoalEntry"
  }
}

extension UserGoalEntryState: CustomStringConvertible {
  var description: String {
    switch self {
    case .DidCommit: return "Did commit"
    case .DidNotCommit: return "Did not commit"
    case .Untouched: return "Untouched"
    }
  }
}

extension UserGoalEntry {
  class func getCompletedUserGoalEntries(forUserGoals userGoals: [UserGoal]) -> SignalProducer<[UserGoalEntry], DataError> {
    return SignalProducer { observer, _ in
      if let query = UserGoalEntry.query() {
        query.includeKey("userGoal")
        query.whereKey("userGoal", containedIn: userGoals)
        query.whereKey("state", equalTo: UserGoalEntryState.DidCommit.rawValue)
        query.cachePolicy = .NetworkElseCache
        query.findObjectsInBackgroundWithBlock({ userGoalEntries, error in
          guard let userGoalEntries = userGoalEntries as? [UserGoalEntry] else {
            observer.sendFailed(DataError.Parse(error: error))
            log.error("error fetching completed user goal entries")
            return
          }
          log.verbose("Fetched \(userGoalEntries.count) user goal entries")
          observer.sendNext(userGoalEntries)
          observer.sendCompleted()
        })
      }
    }
  }
}