//
//  OnboardPageControllerCoordinatorViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/2/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Sugar
import UIKit

final class OnboardPageControllerCoordinatorViewController: BaseViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  private lazy var pageViewController: UIPageViewController = {
    return (self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController")
      as! UIPageViewController).then {
        $0.dataSource = self
        $0.delegate = self
        $0.view.backgroundColor = .blackColor()
        $0.view.frame = CGRect(x: 0, y: -20, width: self.view.width, height: self.view.height + 20)
    }
  }()
  private let pageTitles = ["Reach your medium-term goals in 7 areas of your life through the power of visualization and small daily steps.",
    "First, write down your 7 goals in the form of present tense affirmations.",
    "You use the app just twice a day: 2 minutes in the morning and 4 minutes in the evening.",
    "In the morning, you go through each of your 7 goals and visualize the desired outcome.",
    "In the evening, you reflect on what small daily step you took towards each of your goals."]
  private var backgroundImages = ["OnboardBackgroundFirst", "CareerBackground", "HealthBackground", "SpiritualityBackground", "OnboardBackgroundLast"]
  private var foregorundImages = ["OnboardCategoriesImage", "OnboardTutorialPhoneFirst", "OnboardTutorialPhoneSecond", "OnboardTutorialPhoneThird", "OnboardTutorialPhoneFourth"]
  private var count = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: .Forward,
      animated: true, completion: nil)
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    pageViewController.didMoveToParentViewController(self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  func pageViewController(pageViewController: UIPageViewController,
    viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    var index = (viewController as! OnboardContentViewController).pageIndex!
    index += 1
    if index >= backgroundImages.count + 1 { return nil }
    return viewControllerAtIndex(index)
  }
  
  func pageViewController(pageViewController: UIPageViewController,
    viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    var index = (viewController as! OnboardContentViewController).pageIndex!
    if index <= 0 { return nil }
    index -= 1
    return viewControllerAtIndex(index)
  }
  
  func viewControllerAtIndex(index : Int) -> OnboardContentViewController? {
    if pageTitles.count == 0 || index > pageTitles.count { return nil }
    
    if index == pageTitles.count {
      return (storyboard?.instantiateViewControllerWithIdentifier("OnboardContentViewController")
        as! OnboardContentViewController).then {
        $0.backgroundImageName = backgroundImages[index - 1]
        $0.foregroundImageName = foregorundImages[index - 1]
        $0.titleText = ""
        $0.pageIndex = pageTitles.count
      }
    }
    
    return (storyboard?.instantiateViewControllerWithIdentifier("OnboardContentViewController")
      as! OnboardContentViewController).then {
        $0.backgroundImageName = backgroundImages[index]
        $0.foregroundImageName = foregorundImages[index]
        $0.titleText = self.pageTitles[index]
        $0.pageIndex = index
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController,
    willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
      guard let pendingVC = pendingViewControllers.first as? OnboardContentViewController
        where pendingVC.pageIndex == pageTitles.count else { return }
      welcomeUser()
  }
  
  private func welcomeUser() {
    guard  let welcomeVC = storyboard?.instantiateInitialViewController() else { return }
    navigationController?.showViewController(welcomeVC, sender: self)
  }
}