//
//  UserGoal.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/19/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Foundation
import Parse
import ReactiveCocoa

final class UserGoal: PFObject, PFSubclassing {
  @NSManaged var user: PFUser
  @NSManaged var goal: Goal
  var userGoalEntry: UserGoalEntry?

  convenience init(user: PFUser, goal: Goal) {
    self.init()
    self.user = user
    self.goal = goal
  }
  
  static func parseClassName() -> String {
    return "UserGoal"
  }
  
  func updateState(state: UserGoalEntryState, comment: String?) -> SignalProducer <Bool, DataError> {
    return SignalProducer { observer, _ in
      self.getCurrentGoalEntry().start { event in
        switch event {
        case let .Next(userGoalEntry):
          if let comment = comment {
            userGoalEntry.comment = comment
          }
          userGoalEntry.state = state.rawValue
          userGoalEntry.date = NSDate.today
          
          userGoalEntry.saveInBackgroundWithBlock { userGoalEntry, error in
            if error != nil {
              log.error("Error occured while setting state for user goal entry \(userGoalEntry)")
              observer.sendFailed(DataError.Parse(error: error))
            } else {
              log.verbose("Set state \(state) for goal \(self.goal.categoryDescription)")
              observer.sendNext(true)
              observer.sendCompleted()
            }
          }
        case let .Failed(error):
          log.error("Failed to get user goal entry: \(error)")
          observer.sendFailed(error)
        default: ()
        }
      }
    }
  }

  func getCurrentGoalEntry() -> SignalProducer<UserGoalEntry, DataError> {
    if let userGoalEntry = userGoalEntry {
      return SignalProducer(value: userGoalEntry)
    }
    return SignalProducer { observer, _ in
      if let query = UserGoalEntry.query() {
        query.whereKey("userGoal", equalTo: self)
        query.whereKey("date", equalTo: NSDate.today)
        query.getFirstObjectInBackgroundWithBlock { userGoalEntry, error in
          if error != nil && error?.code != 101 {
            observer.sendFailed(DataError.Parse(error: error))
            return
          }
          guard let userGoalEntry = userGoalEntry as? UserGoalEntry else {
            let userGoalEntry = UserGoalEntry()
            userGoalEntry.userGoal = self
            userGoalEntry.state = UserGoalEntryState.Untouched.rawValue
            userGoalEntry.date = NSDate.today
            userGoalEntry.saveInBackgroundWithBlock { succeded, error in
              if succeded && error == nil {
                self.userGoalEntry = userGoalEntry
                observer.sendNext(userGoalEntry)
                observer.sendCompleted()
              } else {
                observer.sendFailed(DataError.Parse(error: error))
              }
            }
            return
          }
          self.userGoalEntry = userGoalEntry
          observer.sendNext(userGoalEntry)
          observer.sendCompleted()
        }
      }
    }
  }
}

// MARK: Helpers

extension UserGoal {
  class func getUserGoals() -> SignalProducer<[UserGoal], DataError> {
    return SignalProducer { observer, _ in
      guard let query = UserGoal.query(), user = PFUser.currentUser() else {
        log.error("error getting the current user or a usergoal query")
        return
      }
      query.whereKey("user", equalTo: user)
      query.includeKey("goal")
      query.cachePolicy = .NetworkElseCache
      query.findObjectsInBackgroundWithBlock { userGoals, error in
        guard var userGoals = userGoals as? [UserGoal] else {
          observer.sendFailed(DataError.Parse(error: error))
          return
        }
        if userGoals.isEmpty {
          Goal.getDefaultGoals().start { event in
            switch event {
            case let .Next(goals):
              userGoals = goals.map { goal -> UserGoal in return UserGoal(user: user, goal: goal) }
              PFObject.saveAllInBackground(userGoals, block: { succeded, error in
                if let error = error {
                  log.error("failed to generate usergoals: \(error)")
                } else if succeded {
                  log.verbose("Generated \(userGoals.count) user goals for default goals")
                }
              })
              observer.sendNext(userGoals.sort { $0.goal.category < $1.goal.category })
              observer.sendCompleted()
            case let .Failed(error):
              observer.sendFailed(error)
            default: ()
            }
          }
        } else {
          log.verbose("Fetched \(userGoals.count) user goals")
          observer.sendNext(userGoals.sort { return $0.goal.category < $1.goal.category })
          observer.sendCompleted()
        }
      }
    }
  }
  
  func getCompletedUserGoalEntries() -> SignalProducer<[UserGoalEntry], DataError> {
    return SignalProducer { observer, _ in
      guard let query = UserGoalEntry.query() else { return }
      query.whereKey("userGoal", equalTo: self)
      query.whereKey("state", equalTo: UserGoalEntryState.DidCommit.rawValue)
      query.cachePolicy = .CacheThenNetwork
      query.findObjectsInBackgroundWithBlock({ userGoalEntries, error in
        guard let userGoalEntries = userGoalEntries as? [UserGoalEntry] else {
          observer.sendFailed(DataError.Parse(error: error))
          return
        }
        log.verbose("Fetched \(userGoalEntries.count) user goal entries")
        observer.sendNext(userGoalEntries)
        observer.sendCompleted()
      })
    }
  }
}