//
//  ProgressView.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/15/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Cartography
import UIKit

final class ProgressView: UIView {
  private let gradientStartAlpha: CGFloat = 0.65
  private let gradientEndAlpha: CGFloat = 0
  
  private lazy var progressViewShapeLayer = CAShapeLayer().then {
    $0.masksToBounds = true
  }
  private lazy var gradientLayer = CAGradientLayer().then {
    $0.startPoint = .zero
    $0.endPoint = CGPoint(x: 1, y: 1)
  }
  lazy var progressDot = UIView().then {
    $0.layer.masksToBounds = true
  }
  
  override var tintColor: UIColor! {
    didSet {
      progressDot.backgroundColor = tintColor
      gradientLayer.colors = [tintColor.colorWithAlphaComponent(gradientStartAlpha).CGColor,
        tintColor.colorWithAlphaComponent(gradientEndAlpha).CGColor]
    }
  }
  private let progressDotConstraintGroup = ConstraintGroup()
  
  var progressDotOffset: CGFloat = 0.25 {
    didSet {
      if abs(progressDotOffset) > 0 && abs(progressDotOffset) <= 1 {
        updateProgressDotOffsetConstraints()
        UIView.animateWithDuration(0.1, animations: layoutIfNeeded)
      }
    }
  }
  private var progressViewBezierPath: UIBezierPath {
    let progressViewHeight = bounds.height / 1.5
    let arcRadius = progressViewHeight / 2
    
    let arcCenter = CGPoint(x: CGRectGetMinX(bounds), y: CGRectGetMidY(bounds))
    let arcMax = CGPoint(x: CGRectGetMinX(bounds) + arcRadius, y: progressViewHeight)
    let arcMin = CGPoint(x: CGRectGetMinX(bounds) + arcRadius, y: CGRectGetMaxY(bounds) - progressViewHeight)
    let endPoint = CGPoint(x: CGRectGetMaxX(bounds), y: CGRectGetMidY(bounds))
    
    return UIBezierPath().then {
      $0.lineCapStyle = .Round
      $0.lineJoinStyle = .Round
      
      $0.moveToPoint(arcMax)
      $0.addQuadCurveToPoint(arcMin, controlPoint: arcCenter)
      $0.addLineToPoint(endPoint)
      $0.closePath()
    }
  }
  
  init() {
    super.init(frame: .zero)

    layer.addSublayer(gradientLayer)
    addSubview(progressDot)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    progressDot.layer.cornerRadius = progressDot.size.height / 2
  }
  
  // MARK: CALayer
  
  override func layoutSublayersOfLayer(layer: CALayer) {
    super.layoutSublayersOfLayer(layer)
    
    gradientLayer.frame = bounds
    progressViewShapeLayer.frame = bounds
    progressViewShapeLayer.path = progressViewBezierPath.CGPath
    gradientLayer.mask = progressViewShapeLayer
  }

  func setupConstraints() {
    constrain(progressDot, self) { progressDot, view in
      progressDot.height == view.height
      progressDot.width == progressDot.height
      progressDot.centerY == view.centerY
    }
    updateProgressDotOffsetConstraints()
  }
  
  func updateProgressDotOffsetConstraints() {
//    constrain(progressDot, self, replace: progressDotConstraintGroup) { progressDot, view in
//      progressDot.left == view.left + (1 - abs(progressDotOffset)) * CGPathGetBoundingBox(progressViewShapeLayer.path!).width / 1.8
//    }
  }
}
