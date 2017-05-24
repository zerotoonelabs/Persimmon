//
//  ForgotPasswordViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/25/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Sugar
import Parse
import UIKit

final class ForgotPasswordViewController: BaseViewController {
  
  @IBOutlet private weak var logoImageView: UIImageView!
  @IBOutlet private weak var emailTextField: PersimmonTextField!
  @IBOutlet weak var sendPasswordButton: UIButton!
  private var sendPasswordInProcess = false {
    didSet {
      dispatch { self.view.userInteractionEnabled = !self.sendPasswordInProcess }
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
    emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:
      Constants.Authorization.placeholderAttributes)
    emailTextField.insets = Constants.Authorization.textFieldInsets
    
    sendPasswordButton.layer.cornerRadius = 6
    sendPasswordButton.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.16)
  }
  
  // MARK: Controls
  
  @IBAction func backButtonTouched() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func loginButtonTouched() {
    presentingViewController is SignInViewController ? backButtonTouched() :
      performSegueWithIdentifier("SignInSegue", sender: nil)
  }
  
  @IBAction func emailTextFieldKeyDoneTouched() {
    sendPassword()
  }
  
  @IBAction private func signUpButtonTouched() {
    sendPassword()
  }
  
  private func sendPassword() {
    if sendPasswordInProcess { return }
    
    guard let email = emailTextField.text?.lowercaseString else { return }
    
    if email.length < 1 {
      showError("Email is missing :/")
      return
    }
    
    sendPasswordInProcess = true
    showLoading()
    PFUser.requestPasswordResetForEmailInBackground(email) { succeded, error in
      self.hideLoading()
      if let error = error {
        self.sendPasswordInProcess = false
        guard let errorString = error.userInfo["error"] as? String else { return }
        log.error("error while requesting password: \(errorString)")
        self.showError(errorString)
      } else {
        log.verbose("request password succeded with email: \(email)")
        self.showSuccess("Password sent to your email.")
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
}