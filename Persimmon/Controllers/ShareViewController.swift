//
//  ShareViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/16/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Parse
import SCLAlertView
import MessageUI
import Sugar

final class ShareViewController: BaseViewController {
  private let alertViewColor: UInt = 0xEC5800
  private let feedbackEmailAddress = "info@zerotoonelabs.com"
  private let appStoreURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=929209003&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8".url
  
  var userGoals: [UserGoal]!
  @IBOutlet private weak var backButton: UIButton!
  @IBOutlet private var categoryImageViews: [UIImageView]!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var rateButton: UIButton!
  @IBOutlet private weak var shareButton: UIButton!
  @IBOutlet private weak var loveLabel: UILabel!
  @IBOutlet private weak var logoutButton: UIButton!
  private lazy var documentController = UIDocumentInteractionController()
  private lazy var shareManager: ShareManager? = {
    guard let currentUser = PFUser.currentUser(),
      name = currentUser["name"] as? String else { return nil }
    let categoryImages = self.categoryImageViews.sort { $0.tag < $1.tag }.map { $0.image! }
    let shareImage = UIImage.shareImage(fromGoalImages: categoryImages, text: name)
    return ShareManager(withViewController: self, shareImage: UIImage.shareImage(fromGoalImages: categoryImages, text: name))
  }()
  private var logoutInProcess = false {
    didSet {
      dispatch { self.view.userInteractionEnabled = !self.logoutInProcess }
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setUpViews()
  }
  
  func setUpViews() {
    let orderedByCategoryCategoryImageViews = categoryImageViews.sort { $0.tag > $1.tag }
    let orderedByCategoryUserGoals = userGoals.map { $0.goal }.sort { $0.category > $1.category }
    for (idx, categoryImageView) in orderedByCategoryCategoryImageViews.enumerate() {
      orderedByCategoryUserGoals[idx].image.getDataInBackgroundWithBlock({ data, error in
        if error != nil {
          log.error("error fetching image for category in share view controller: \(error?.localizedDescription)")
        } else if let data = data {
          categoryImageView.image = UIImage(data: data)
        }
      })
      categoryImageView.layer.cornerRadius = categoryImageView.bounds.size.height / 2
      categoryImageView.layer.borderWidth = 2.6
      categoryImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    backButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 20, spread: 0, opacity: 0.5)
    logoutButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 20, spread: 0, opacity: 0.5)
    rateButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 40, spread: 2, opacity: 0.86)
    shareButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 40, spread: 2, opacity: 0.86)
    loveLabel.layer.shadowColor = UIColor.whiteColor().CGColor
    loveLabel.layer.shadowOpacity = 0.5
    loveLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    loveLabel.layer.shadowRadius = 3
    loveLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
    loveLabel.layer.shouldRasterize = true
  }
  
  // MARK: - Controls
  
  @IBAction func backButtonTouched() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func shareOnInstagramButtonTouched() {
    shareManager?.instagramShare(documentController)
  }
  
  @IBAction func logoutButtonTouched() {
    UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet).then {
      $0.addAction(UIAlertAction(title: "Logout", style: .Destructive) { _ in self.logout() })
      $0.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
      $0.popoverPresentationController?.sourceRect = self.logoutButton.frame
      $0.popoverPresentationController?.sourceView = self.view
      presentViewController($0, animated: true, completion: nil)
    }
  }
  
  func logout() {
    logoutInProcess = true
    showLoading()
    PFUser.logOutInBackgroundWithBlock { error in
      self.hideLoading()
      self.logoutInProcess = false
      if let error = error {
        self.showError("An error occured while trying to log out. Please try again later")
        log.error("error logging out a user: \(error.localizedDescription)")
      } else {
        if let appDelegate = UIApplication.sharedApplication().delegate,
          let welcomeVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            let navigationController = UINavigationController()
            navigationController.viewControllers = [welcomeVC]
            dispatch {
              UIView.transitionWithView(appDelegate.window!!, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                appDelegate.window!!.rootViewController = navigationController
                }, completion: nil)
            }
        }
      }
    }

  }
  
  @IBAction private func websiteLinkTouched(sender: UITapGestureRecognizer) {
    guard let websiteLabel = sender.view as? UILabel else { return }
    guard let text = websiteLabel.text else { return }
    do {
      let dataDetector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
      let matches = dataDetector.matchesInString(text, options: .WithoutAnchoringBounds, range: NSMakeRange(0, text.length))
      let application = UIApplication.sharedApplication()
      if let websiteURL = matches.first?.URL where application.canOpenURL(websiteURL) {
        UIApplication.sharedApplication().openURL(websiteURL)
      }
    } catch {}
  }
  
  @IBAction func showBegAlertView() {
    SCLAlertView().then {
      $0.showCloseButton = false
      $0.addButton("Definitely!") { self.showRateAlertView() }
      $0.addButton("Not really") { self.showFeebackAlertView() }
      $0.showNotice("Enjoying Persimmon?", subTitle: "", closeButtonTitle: nil, duration: 0,
        colorStyle: alertViewColor, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
  }
  
  func showErrorAlert(title: String, subTitle: String) {
    SCLAlertView().showError(title, subTitle: subTitle)
  }
}

// MARK: - Rate

extension ShareViewController {
  func showRateAlertView() {
    SCLAlertView().then {
      $0.showCloseButton = false
      $0.addButton("OK, sure") { self.redirectToAppStoreIfPossible() }
      $0.addButton("No, thanks") {}
      $0.showNotice("We like you too!", subTitle: "It would mean a ton if you left us a review in the App Store. Have a second?",
        closeButtonTitle: nil, duration: 0, colorStyle: alertViewColor, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
  }
  
  func redirectToAppStoreIfPossible() {
    let app = UIApplication.sharedApplication()
    if !(app.canOpenURL(appStoreURL) && app.openURL(appStoreURL)) {
      showErrorAlert("Uh-oh...", subTitle: "Something went wrong. Could not redirect to AppStore's \"Reviews\" page")
      return log.error("Could not redirect the user to AppStore's \"Reviews\" page")
    }
  }
}

// MARK: - Feedback, MFMailComposeViewControllerDelegate

extension ShareViewController: MFMailComposeViewControllerDelegate {
  func showFeebackAlertView() {
    SCLAlertView().then {
      $0.showCloseButton = false
      $0.addButton("OK, sure") { self.showMailComposeViewControllerIfPossible() }
      $0.addButton("No, thanks") {}
      $0.showNotice("Ha, interesting...", subTitle: "Would you mind telling us what's rong?",
        closeButtonTitle: nil, duration: 0, colorStyle: alertViewColor, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
  }
  
  func showMailComposeViewControllerIfPossible() {
    if MFMailComposeViewController.canSendMail() {
      let mailComposeVC = configuredMailComposeViewController(feedbackEmailAddress, subject: "Feedback on Persimmon", body: "")
      self.presentViewController(mailComposeVC, animated: true, completion: nil)
    } else {
      showErrorAlert("Uh-oh...", subTitle: "Your device could not send e-mail. Please check e-mail configuration and try again.")
    }
  }
  
  func configuredMailComposeViewController(reciepent: String, subject: String, body: String) -> MFMailComposeViewController {
    return MFMailComposeViewController().then {
      $0.mailComposeDelegate = self
      $0.setToRecipients([reciepent])
      $0.setSubject(subject)
      $0.setMessageBody(body, isHTML: false)
    }
  }

  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension UIImage {
  class func shareImage(fromGoalImages images: [UIImage], text: NSString?) -> UIImage {
    let categoriesOrigins = [CGPoint(x: 81, y: 297), CGPoint(x: 333, y: 152), CGPoint(x: 333, y: 297), CGPoint(x: 209, y: 225), CGPoint(x: 81, y: 151), CGPoint(x: 207, y: 80), CGPoint(x: 207, y: 370)]
    let baseImage = UIImage(asset: .ShareImageBase)
    let categoryImageSize = CGSize(width: 97, height: 97)
    let borderWidth: CGFloat = 3.665
    
    UIGraphicsBeginImageContextWithOptions(baseImage.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    baseImage.drawInRect(CGRect(origin: CGPointZero, size: baseImage.size))
    
    for (idx, image) in images.enumerate() {
      let rect = CGRect(origin: categoriesOrigins[idx], size: categoryImageSize)
      let circlePath = UIBezierPath(ovalInRect: rect)

      let backgroundRect = CGRect(x: rect.origin.x - borderWidth/2, y: rect.origin.y - borderWidth/2,
        width: rect.width + borderWidth, height: rect.height + borderWidth)
      CGContextSetFillColorWithColor(context!, UIColor.whiteColor().CGColor)
      CGContextFillEllipseInRect(context!, backgroundRect)
      
      CGContextSaveGState(context!)
      circlePath.addClip()
      image.drawInRect(rect, blendMode: .Normal, alpha: 1)
      CGContextRestoreGState(context!)
    }
    
    if var text = text {
      if text.length > 11 {
        text = text.stringByAppendingString("...")
      }
      text = NSString(string: "@").stringByAppendingString(text as String)
      text = text.uppercaseString
      
      let point = CGPoint(x: 10, y: 479)
      text.drawAtPoint(point, withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(16),
        NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    let shareImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return shareImage!
  }
  
  private class func drawText(text: String) {
    
  }
}
