//
//  Goal.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/7/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Parse
import ReactiveCocoa
import UIKit

enum GoalKey: String {
  case Category = "category", Text = "text", Image = "image"
}

enum GoalCategory: Int {
  case Spirituality, LoveRelationships, HealthFitness, CareerBusiness, FamilyFriends,
      Finance, LearningCreativitiy
  static let allValues = [Spirituality, LoveRelationships, HealthFitness, CareerBusiness, FamilyFriends,
                          Finance, LearningCreativitiy]
}

final class Goal: PFObject, PFSubclassing {
  @NSManaged var category: Int
  @NSManaged var text: String
  @NSManaged var isDefault: Bool
  @NSManaged var image: PFFile

  var color: UIColor {
    if let category = GoalCategory(rawValue: category) {
      return category.color
    } else {
      return GoalCategory.Spirituality.color
    }
  }
  var categoryDescription: String {
    if let category = GoalCategory(rawValue: category) {
      return category.description
    } else {
      return "undefined"
    }
  }
  var categoryBackgroundImage: UIImage {
    if let category = GoalCategory(rawValue: category) {
      return category.backgroundImage
    } else {
      return GoalCategory.Spirituality.backgroundImage
    }
  }
  var categoryIconImage: UIImage {
    if let category = GoalCategory(rawValue: category) {
      return category.icon
    } else {
      return GoalCategory.Spirituality.icon
    }
  }

  static func parseClassName() -> String {
    return "Goal"
  }
}

// MARK: - Equatable

func == (left: Goal, right: Goal) -> Bool {
  return (left.category == right.category) && (left.text == right.text)
}

// MARK: - Comparable

extension Goal: Comparable {}

func < (left: Goal, right: Goal) -> Bool {
  return left.category < right.category
}

// MARK: - GoalCategory

extension GoalCategory: CustomStringConvertible {
  var description: String {
    switch self {
    case .Spirituality: return "Spirituality"
    case .LoveRelationships: return "Love/Relationships"
    case .HealthFitness: return "Health"
    case .CareerBusiness: return "Career/Business"
    case .FamilyFriends: return "Family"
    case .Finance: return "Finance"
    case .LearningCreativitiy: return "Learning/Creativity"
    }
  }
  var color: UIColor {
    switch self {
    case .Spirituality: return UIColor(red:80/255, green:227/255, blue:194/255, alpha:1.0)
    case .LoveRelationships: return UIColor(red:73/255, green:198/255, blue:246/255, alpha:1.0)
    case .HealthFitness: return UIColor(red:245/255, green:166/255, blue:35/255, alpha:1.0)
    case .CareerBusiness: return UIColor(red:0.33, green:0.51, blue:0.90, alpha:1.0)
    case .FamilyFriends: return UIColor(red:238/255, green:155/255, blue:234/255, alpha:1.0)
    case .Finance: return UIColor(red:241/255, green:148/255, blue:28/255, alpha:1.0)
    case .LearningCreativitiy: return UIColor(red:205/255, green:120/255, blue:222/255, alpha:1.0)
    }
  }
  var defaultGoalEntryText: String {
    switch self {
    case .Spirituality: return "I meditated for 10 minutes right after the morning shower using Headspace.com."
    case .LoveRelationships: return "I went for a dinner date with a girl I met last week."
    case .HealthFitness: return "I jogged 5 miles (Nike running), stretched, did 15 pull-ups and 20 push-ups."
    case .CareerBusiness: return "I successfully presented my project to the clients."
    case .FamilyFriends: return "I called my mom and sent a coffee invitation to a good designer."
    case .Finance: return "I spent 30 minutes brainstorming new business ideas."
    case .LearningCreativitiy: return "I practiced 20 Japanese words at iknow.jp."
    }
  }
  var defaultText: String {
    switch self {
    case .Spirituality: return "I achieve inner harmony, peace and happiness."
    case .LoveRelationships: return "I’m dating a gorgeous, smart and easy-going woman."
    case .HealthFitness: return "I’m in great health, have 6-pack abs, strong arms and upper body."
    case .CareerBusiness: return "I get a promotion at my job."
    case .FamilyFriends: return "I’m surrounded by many friends and family members and meet new " +
      "interesting people every day."
    case .Finance: return "I make $10,000 a month."
    case .LearningCreativitiy: return "I’m fluent in Japanese."
    }
  }
  var defaultImage: UIImage {
    switch self {
    case .Spirituality: return UIImage(asset: .SpiritualityGoalIcon)
    case .LoveRelationships: return UIImage(asset: .LoveGoalIcon)
    case .HealthFitness: return UIImage(asset: .HealthGoalIcon)
    case .CareerBusiness: return UIImage(asset: .CareerGoalIcon)
    case .FamilyFriends: return UIImage(asset: .FamilyGoalIcon)
    case .LearningCreativitiy: return UIImage(asset: .EducationGoalIcon)
    case .Finance: return UIImage(asset: .FinanceGoalIcon)
    }
  }
  var backgroundImage: UIImage {
    switch self {
    case .Spirituality: return UIImage(asset: .SpiritualityBackground)
    case .LoveRelationships: return UIImage(asset: .LoveBackground)
    case .HealthFitness: return UIImage(asset: .HealthBackground)
    case .CareerBusiness: return UIImage(asset: .CareerBackground)
    case .FamilyFriends: return UIImage(asset: .FamilyBackground)
    case .LearningCreativitiy: return UIImage(asset: .EducationBackground)
    case .Finance: return UIImage(asset: .FinanceBackground)
    }
  }
  var icon: UIImage {
    switch self {
    case .Spirituality: return UIImage(asset: .SpiritualityIcon)
    case .LoveRelationships: return UIImage(asset: .LoveIcon)
    case .HealthFitness: return UIImage(asset: .HealthIcon)
    case .CareerBusiness: return UIImage(asset: .CareerIcon)
    case .FamilyFriends: return UIImage(asset: .FamilyIcon)
    case .LearningCreativitiy: return UIImage(asset: .EducationIcon)
    case .Finance: return UIImage(asset: .FinanceIcon)
    }
  }
}

extension UIColor {
  func inverse() -> UIColor {
    var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
    if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
      return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }
    return self
  }
}

// MARK: Helpers

extension Goal {
  class func getDefaultGoals() -> SignalProducer<[Goal], DataError> {
    return SignalProducer { observer, _ in
      if let query = Goal.query() {
        query.whereKey("isDefault", equalTo: true)
        query.findObjectsInBackgroundWithBlock { goals, error in
          guard var goals = goals as? [Goal] else {
            observer.sendFailed(DataError.Parse(error: error))
            return
          }
          if goals.isEmpty {
            goals = GoalCategory.allValues.map { category -> Goal in
              let goal = Goal()
              goal.category = category.rawValue
              goal.text = category.defaultText
              goal.isDefault = true
              if let data = UIImageJPEGRepresentation(category.defaultImage, 0.5),
                image = PFFile(name: "default\(category.rawValue)", data: data) {
                goal.image = image
              }
              return goal
            }
            PFObject.saveAllInBackground(goals, block: { succeded, error in
              if let error = error {
                log.error("could not generate default goals: \(error.localizedDescription)")
              } else if succeded {
                log.verbose("Generated \(goals.count) default goals")
              }
            })
          } else {
            log.verbose("Fetched \(goals.count) default goals")
          }
          observer.sendNext(goals)
          observer.sendCompleted()
        }
      }
    }
  }
  
  class func saveUserGoals(userGoals: [UserGoal]) -> SignalProducer<Bool, DataError> {
    return SignalProducer { observer, _ in
      if userGoals.count < 1 {
        observer.sendNext(true)
        observer.sendCompleted()
      }
      userGoals.forEach {
        if $0.goal.isDefault {
          let newGoal = Goal()
          newGoal.isDefault = false
          newGoal.category = $0.goal.category
          newGoal.text = $0.goal.text
          newGoal.image = $0.goal.image
          $0.goal = newGoal
        }
      }
      PFObject.saveAllInBackground(userGoals, block: { succeeded, error in
        if error != nil {
          observer.sendFailed(DataError.Parse(error: error))
        } else {
          observer.sendNext(succeeded)
          observer.sendCompleted()
        }
      })
    }
  }
}