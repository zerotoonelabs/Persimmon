//
//  OnboardContentViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/2/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

final class OnboardContentViewController: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var imageView: UIImageView!
  
  var pageIndex: Int?
  var titleText: String!
  var backgroundImageName: String!
  var foregroundImageName: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundImageView.image = UIImage(named: backgroundImageName)
    imageView.image = UIImage(named: foregroundImageName)
    titleLabel.text = titleText
    titleLabel.alpha = 0.1
    UIView.animateWithDuration(1) {
      self.titleLabel.alpha = 1
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    titleLabel.enableGlow(glowColor: .whiteColor(), blur: 9, spread: 0, opacity: 0.5)
  }
}
