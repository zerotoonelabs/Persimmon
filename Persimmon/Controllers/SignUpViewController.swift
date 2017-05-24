//
//  SignUpViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/24/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Whisper
import Sugar
import Parse
import UIKit

final class SignUpViewController: BaseViewController {
  @IBOutlet private weak var logoImageView: UIImageView!
  @IBOutlet private weak var nameTextField: PersimmonTextField!
  @IBOutlet private weak var emailTextField: PersimmonTextField!
  @IBOutlet private weak var passwordTextField: PersimmonTextField!
  @IBOutlet weak var signUpButton: UIButton!
  var signUpInProcess = false {
    didSet {
      dispatch { self.signUpButton.enabled = !self.signUpInProcess }
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
    logoImageView.enableGlow(true, glowColor: .whiteColor(), blur: 25, spread: 0, opacity: 0.5)

    [nameTextField, emailTextField, passwordTextField].forEach {
      $0.attributedPlaceholder = NSAttributedString(string: $0.placeholder!,
        attributes: Constants.Authorization.placeholderAttributes)
      $0.insets = Constants.Authorization.textFieldInsets
    }
    [nameTextField, emailTextField].addBottomSeparators()
    
    signUpButton.layer.cornerRadius = 6
    signUpButton.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.16)
  }
  
  // MARK: Controls

  @IBAction func signInButtonTouched() {
    presentingViewController is SignInViewController ? backButtonTouched() :
      performSegueWithIdentifier("SignInSegue", sender: nil)
  }
  
  @IBAction func backButtonTouched() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction private func passwordDoneKeyTouched() {
    signUp()
  }
  
  @IBAction private func signUpButtonTouched() {
    signUp()
  }
  
  private func signUp() {
    if signUpInProcess { return }
    
    let name = nameTextField.text
    let email = emailTextField.text?.lowercaseString
    let password = passwordTextField.text
    
    if name?.length < 1 || email?.length < 1 || password?.length < 1 {
      showError("Name, email or password are missing :/")
      return
    }
    
    let user = PFUser(email: email, password: password, name: name)
    
    signUpInProcess = true
    showLoading()
    user.signUpInBackgroundWithBlock { succeeded, error in
      self.hideLoading()
      if let error = error {
        self.signUpInProcess = false
        guard let errorString = error.userInfo["error"] as? String else { return }
        
        log.error("error while signing up: \(errorString)")
        self.showError(errorString)
      } else {
        log.info("sign up succeded with email: \(email)\npassword: \(password)")
        self.showTutorial()
      }
    }
  }
  
  private func showTutorial() {
    dispatch {
      if let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") {
        self.presentViewController(tutorialVC, animated: true, completion: nil)
      }
    }
  }
}