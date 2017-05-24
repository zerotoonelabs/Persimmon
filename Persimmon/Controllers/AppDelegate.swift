//
//  AppDelegate.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/3/15
//  Copyright (c) 2015 Zero To One Labs. All rights reserved.
//

import Parse
import ParseFacebookUtilsV4
import VK_ios_sdk
import XCGLogger
import Fabric
import Crashlytics
import SVProgressHUD
import Sugar
import FontBlaster
import UIKit

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    log.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true)
    Parse.initializeWithConfiguration(ParseClientConfiguration {
      $0.applicationId = Constants.Parse.applicationID
      $0.clientKey = Constants.Parse.clientKey
      $0.server = Constants.Parse.server
    })
    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
    Goal.registerSubclass()
    UserGoal.registerSubclass()
    UserGoalEntry.registerSubclass()
      
    Fabric.with([Crashlytics.self])
    FontBlaster.blast()

    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    application.registerUserNotificationSettings(settings)
      
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let navigationController = UINavigationController()
    let appCoordinator = AppCoordinator(navigationController: navigationController)
      
    if let window = window {
      window.rootViewController = navigationController
      appCoordinator.start()
//      animateSplashScreen(withNavigationController: navigationController)
      window.makeKeyAndVisible()
    }
     
    return true
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    VKSdk.processOpenURL(url, fromApplication: (options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String))
    return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url,  sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String,
      annotation: options[UIApplicationOpenURLOptionsOpenInPlaceKey]!)
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application,
      openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
}

// MARK: Animating splash screen

extension AppDelegate {
  private func animateSplashScreen(withNavigationController navigationController: UINavigationController) {
    guard let firstViewController = navigationController.viewControllers.first
      as? BaseViewController else { return }
    
    let firstView = firstViewController.view
    let backgroundView = UIView(frame: firstView.frame)
    backgroundView.backgroundColor = UIColor.persimmonColor()
    firstView.addSubview(backgroundView)
    
    let launchIconImageView = UIImageView(image: UIImage(asset: .LaunchIcon)!)
    launchIconImageView.enableGlow(glowColor: UIColor.whiteColor(), blur: 34, spread: 0, opacity: 0.34)
    launchIconImageView.center = backgroundView.center
    backgroundView.addSubview(launchIconImageView)
    
    dispatch {
      firstViewController.hideLoading()
      UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7,
        initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
          launchIconImageView.transform = CGAffineTransformMakeScale(0.75, 0.75)
        }) { _ in
          UIView.animateWithDuration(0.7, animations: {
            launchIconImageView.transform = CGAffineTransformMakeScale(10, 10)
            backgroundView.alpha = 0
            }) { _ in
              backgroundView.removeFromSuperview()
          }
      }
    }
  }
}
