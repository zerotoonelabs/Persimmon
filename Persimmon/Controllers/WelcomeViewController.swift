//
//  WelcomeViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/24/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Parse
import ParseFacebookUtilsV4
import Sugar

final class WelcomeViewController: BaseViewController {
  @IBOutlet private weak var logoImageView: UIImageView!
  @IBOutlet private weak var facebookButton: UIButton!
  @IBOutlet private weak var signInButton: UIButton!
  @IBOutlet private weak var signUpButton: UIButton!
  private var facebookConnectInProcess = false {
    didSet {
      dispatch {
        UIApplication.sharedApplication().statusBarStyle = self.facebookConnectInProcess ? .Default : .LightContent
        self.facebookButton.enabled = !self.facebookConnectInProcess
        self.signUpButton.enabled = !self.facebookConnectInProcess
      }
    }
  }
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  private func setUpViews() {
    signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
    signUpButton.layer.borderWidth = 1
    
    [facebookButton, signUpButton, signInButton].forEach {
      $0.layer.cornerRadius = 7
      $0.layer.masksToBounds = true
    }
    
//    logoImageView.enableGlow(true, glowColor: UIColor.whiteColor(), blur: 50, spread: 0, opacity: 0.5)
//    facebookButton.enableGlow(true, glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.17)
//    signUpButton.enableGlow(true, glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.17)
  }
  
  @IBAction private func facebookButtonTouched() {
    facebookConnectInProcess = true
    
    showLoading()
    PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"]) { user, error in
      self.hideLoading()
      self.facebookConnectInProcess = false
      
      guard let user = user else {
        log.info("The user cancelled Facebook login.")
        return
      }
    
      self.saveFacebookProfileName(user)
      
      if user.isNew {
        log.info("Logged in as facebook user.")
        dispatch {
          if let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") {
            self.presentViewController(tutorialVC, animated: true, completion: nil)
          }
        }
      } else {
        log.info("Signed up as facebook user.")
        guard let appDelegate = UIApplication.sharedApplication().delegate else { return }
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [GoalsViewController()]
        dispatch {
          UIView.transitionWithView(appDelegate.window!!, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            appDelegate.window!!.rootViewController = navigationController
            }, completion: nil)
        }
      }
    }
  }
  
  func saveFacebookProfileName(user: PFUser) {
    let facebookRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
    facebookRequest.startWithCompletionHandler({ connection, result, error in
      if let error = error {
        log.error("Could not retrieve user's name: \(error.localizedDescription)")
      } else {
        guard let profile = result as? [String: AnyObject],
          let firstName = profile["first_name"] ?? profile["last_name"] ??
            profile["middle_name"] ?? profile["name"] else { return }
        
        log.info("retrieved user's facebook name: \(firstName)")
        user["name"] = firstName
        user.saveEventually()
      }
    })

  }
}
