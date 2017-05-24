//
//  AppCoordinator.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/19/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import ReactiveCocoa
import class Parse.PFUser
import UIKit

enum AuthenticationError: ErrorType {
  case ParseError(error: NSError?), BundleError
}

class AppCoordinator {
  private let storyboard = UIStoryboard(name: "Main", bundle: nil)
  let navigationController: UINavigationController
  var seenOnboarding: Bool {
    get {
      let userDefaults = NSUserDefaults.standardUserDefaults()
      return userDefaults.boolForKey("SeenOnboarding")
    } set {
      let userDefaults = NSUserDefaults.standardUserDefaults()
      userDefaults.setBool(newValue, forKey: "SeenOnboarding")
      userDefaults.synchronize()
    }
  }
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func start() {
    if !seenOnboarding {
      seenOnboarding = true
      showOnboarding()
    } else if let user = PFUser.currentUser() {
      log.info("Logged in: \(user)")
      showGoals()
    } else {
      welcomeUser()
    }
  }
  
  func showGoals() {
    navigationController.viewControllers = [GoalsViewController()]
  }
  
  func showTutorial() {
    let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("TutorialViewController")
    navigationController.showViewController(tutorialVC, sender: self)
  }
  
  func welcomeUser() {
    let welcomeVC = storyboard.instantiateInitialViewController()!
    navigationController.showViewController(welcomeVC, sender: self)
  }
  
  func showOnboarding() {
    let onboardVC = storyboard.instantiateViewControllerWithIdentifier("OnboardPageControllerCoordinatorViewController")
    navigationController.showViewController(onboardVC, sender: self)
  }
}
