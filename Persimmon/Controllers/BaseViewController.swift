//
//  BaseViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/24/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Sugar
import ReachabilitySwift
import Whisper
import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
  private lazy var reachability: Reachability? = {
    do {
      return try Reachability.reachabilityForInternetConnection()
    } catch {
      log.error("reachability could not be created")
      return nil
    }
  }()
//  private lazy var loader: LiquidLoader = {
//    let frame = CGRect(x: (self.view.width - 128) / 2, y: (self.view.height - 36) / 2, width: 128, height: 36)
//    return LiquidLoader(frame: frame, effect: .GrowLine(.persimmonColor(), 0, 0, .persimmonColor()))
//  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    hideLoading()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    startReachabilityNotifier()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidAppear(animated)
    defer { reachability?.stopNotifier() }
  }
  
  private func startReachabilityNotifier() {
    guard let reachability = reachability else { return }
    reachability.whenUnreachable = { _ in
      dispatch { self.showError("No interntet connection") }
    }
    
    do {
      try reachability.startNotifier()
    } catch {
      log.error("reachability could start its notifier")
    }
  }
  
  func showError(title: String) {
    var mutableTitle = title
    Whistle(Murmur(title: mutableTitle.firstLetterUppercase(), duration: 2,
      backgroundColor: .failColor(), titleColor: .whiteColor(),
      font: .systemFontOfSize(14, weight: UIFontWeightLight)))
  }
  func showSuccess(title: String) {
    Whistle(Murmur(title: title, duration: 2,
      backgroundColor: .successColor(), titleColor: .whiteColor(),
      font: .systemFontOfSize(14, weight: UIFontWeightLight)))
  }
  
  func showLoading() {
//    dispatch {
//      if self.loader.superview == nil {
//        self.view.addSubview(self.loader)
//      }
//      self.loader.show()
//    }
  }
  func hideLoading() {
//    dispatch {
//      self.loader.hide()
//    }
  }
}
