//
//  SignInViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/24/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Sugar
import Parse
import UIKit

final class SignInViewController: BaseViewController {
  @IBOutlet private weak var logoImageView: UIImageView!
  @IBOutlet private weak var emailTextField: PersimmonTextField!
  @IBOutlet private weak var passwordTextField: PersimmonTextField!
  @IBOutlet weak var forgotPasswordButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  var signInInProcess = false {
    didSet {
      dispatch {
        self.signInButton.enabled = !self.signInInProcess
        self.forgotPasswordButton.enabled = !self.signInInProcess
      }
    }
  }
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  private func setUpViews() {
    logoImageView.enableGlow(true, glowColor: .whiteColor(), blur: 25, spread: 0, opacity: 0.5)
    
    [emailTextField, passwordTextField].forEach {
      $0.attributedPlaceholder = NSAttributedString(string: $0.placeholder!,
        attributes: Constants.Authorization.placeholderAttributes)
      $0.insets = Constants.Authorization.textFieldInsets
    }
    emailTextField.addBottomSeparator()
    
    signInButton.layer.cornerRadius = 6
    signInButton.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.16)
  }
  
  // MARK: Controls
  
  @IBAction func signUpButtonTouched() {
    presentingViewController is SignUpViewController ? backButtonTouched() :
      performSegueWithIdentifier("SignUpSegue", sender: nil)
  }
  
  @IBAction func forgotPasswordButtonTouched() {
    presentingViewController is ForgotPasswordViewController ? backButtonTouched() :
      performSegueWithIdentifier("ForgotPasswordSegue", sender: nil)
  }
  
  @IBAction func backButtonTouched() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction private func passwordDoneKeyTouched() {
    signIn()
  }
  
  @IBAction private func signInButtonTouched() {
    signIn()
  }
  
  private func signIn() {
    if signInInProcess { return }
    guard let email = emailTextField.text?.lowercaseString, password = passwordTextField.text else { return }
    
    if email.length < 1 || password.length < 1 {
      showError("Email or password are missing :/")
      return
    }
    
    signInInProcess = true
    showLoading()
    PFUser.logInWithUsernameInBackground(email, password: password) { user, error in
      self.hideLoading()
      if let error = error {
        self.signInInProcess = false
        guard let errorString = error.userInfo["error"] as? String else { return }
        log.error("error while signing in: \(errorString)")
        self.showError(errorString)
      } else {
        log.info("sign in succeded with email: \(email)\npassword: \(password)")
        self.showGoals()
      }
    }
  }
  
  private func showGoals() {
    if let appDelegate = UIApplication.sharedApplication().delegate {
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