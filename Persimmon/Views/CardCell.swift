//
//  CardCell.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/10/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Reusable
import Sugar
import Cartography
import UIKit

@IBDesignable
class CardCell: UICollectionViewCell, Reusable {
  private var glowsEnabled = false
  private let sideViewHeight: CGFloat = 2
  private lazy var sideViews = [UIView(), UIView(), UIView(), UIView()]
  
  @IBInspectable var cornerRadius: CGFloat = 20 {
    didSet {
      dispatch {
        self.layer.cornerRadius = self.cornerRadius
      }
    }
  }
  @IBInspectable var borderWidth: CGFloat = 2 {
    didSet {
      dispatch {
        self.layer.borderWidth = self.borderWidth
      }
    }
  }
  @IBInspectable var cellColor: UIColor = UIColor.lightGrayColor() {
    didSet {
      dispatch {
        self.layer.backgroundColor = self.cellColor.colorWithAlphaComponent(0.67).CGColor
        self.layer.borderColor = self.cellColor.CGColor
      }
    }
  }
  
  // MARK: Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    sideViews.forEach { contentView.addSubview($0) }
    setUpConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
    sideViews.forEach { contentView.addSubview($0) }
    setUpConstraints()
  }
  
  // MARK: UICollectionReusableView
  
  override func prepareForReuse() {
    super.prepareForReuse()
    enableGlows(false, sideViewsColor: cellColor)
  }
  
  // MARK: UIView
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if !glowsEnabled { enableGlows(sideViewsColor: cellColor) }
  }
  
  // MARK: Public
  
  func setup() {
    tintColor = .whiteColor()
    layer.rasterizationScale = UIScreen.mainScreen().scale
    layer.shouldRasterize = true
  }
  
  func enableGlows(enable: Bool = true, sideViewsColor: UIColor) {
    let sideViewsGlowColor = sideViewsColor.saturatedColor()
    sideViews.forEach {
      $0.enableGlow(enable, glowColor: sideViewsGlowColor, blur: 6, spread: 10, opacity: 0.4)
    }
    glowsEnabled = enable
  }
  
  // MARK: Private
  
  private func setUpConstraints() {
    constrain(sideViews[0], sideViews[1], sideViews[2], sideViews[3], self) {
      (topView, rightView, bottomView, leftView, view) in
      topView.top == view.top
      topView.width == view.width
      topView.height == sideViewHeight
      rightView.right == view.right
      rightView.height == view.height
      rightView.width == sideViewHeight
      bottomView.bottom == view.bottom
      bottomView.height == sideViewHeight
      bottomView.width == view.width
      leftView.left == view.left
      leftView.width == sideViewHeight
      leftView.height == view.height
    }
  }
}