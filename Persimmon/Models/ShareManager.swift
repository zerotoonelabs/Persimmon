//
//  ShareManager.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/9/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Foundation
import FBSDKShareKit
import VK_ios_sdk
import Sugar

final class ShareManager: NSObject, FBSDKSharingDelegate, UIDocumentInteractionControllerDelegate {
  private let instagramURL = "instagram://app".url
  private let whatsAppURL = "whatsapp://app".url
  private let vkAppID = "5283732"

  private let instagramExclusiveUTI = "com.instagram.exclusivegram"
  private let whatsAppExclusiveUTI = "net.whatsapp.image"
  private var vkSDKInitialized = false
  
  private var viewController: UIViewController
  private var shareImage: UIImage
  
  init(withViewController vc: UIViewController, shareImage: UIImage) {
    self.viewController = vc
    self.shareImage = shareImage
    super.init()
  }
  
  func facebookShare() {
    let photo = FBSDKSharePhoto(image: shareImage, userGenerated: false)
    let shareContent = FBSDKSharePhotoContent()
    shareContent.photos = [photo]
    dispatch {
      FBSDKShareDialog.showFromViewController(self.viewController, withContent: shareContent, delegate: self)
    }
  }
  
  func instagramShare(documentController: UIDocumentInteractionController) {
    if (UIApplication.sharedApplication().canOpenURL(instagramURL)) {
      let imageData = UIImageJPEGRepresentation(shareImage, 1)
      let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("instagram.igo")
      if imageData?.writeToFile(writePath, atomically: true) == false {
        return
      } else {
        documentController.URL = NSURL(fileURLWithPath: writePath)
        documentController.UTI = instagramExclusiveUTI
        documentController.presentOpenInMenuFromRect(viewController.view.frame, inView: viewController.view, animated: true)
      }
    } else {
      let alert = UIAlertController(title: "Error",
        message: "Instagram app is not installed on your device, unable to share", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      viewController.presentViewController(alert, animated: true, completion: nil)
      log.verbose("Instagram app isn't installed, failed to share.")
    }
  }
  
  func whatsAppShare(documentController: UIDocumentInteractionController) {
    if UIApplication.sharedApplication().canOpenURL(whatsAppURL) {
      let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("whatsapp.wai")
      let imageData = UIImageJPEGRepresentation(shareImage, 1)
      
      if imageData?.writeToFile(writePath, atomically: true) == false {
        return
      } else {
        documentController.URL = NSURL(fileURLWithPath: writePath)
        documentController.UTI = whatsAppExclusiveUTI
        documentController.presentOpenInMenuFromRect(viewController.view.frame, inView: viewController.view, animated: true)
      }
    }
  }
  
  func vkShare() {
    if !vkSDKInitialized {
      vkSDKInitialized = true
      VKSdk.initializeWithAppId(vkAppID)
    }
    let shareDialog = VKShareDialogController()
    shareDialog.uploadImages = [VKUploadImage(image: shareImage, andParams: nil)]
    shareDialog.completionHandler = { controller, result in
      self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    viewController.presentViewController(shareDialog, animated: true, completion: nil)
  }

  func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
    log.verbose("facebook share succeeded")
  }
  func sharerDidCancel(sharer: FBSDKSharing!) {
    log.verbose("facebook share cancelled")
  }
  func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
    log.verbose("facebook share failed with error: \(error)")
  }

}