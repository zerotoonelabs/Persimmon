//
//  UIViewExtensions.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/8/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Sugar
import UIKit

extension UIView {
  var width: CGFloat {
    get {
      return frame.width
    }
    set(width) {
      frame = widthLens.to(width, frame)
    }
  }
  var height: CGFloat {
    get {
      return frame.height
    }
    set(height) {
      frame = heightLens.to(height, frame)
    }
  }
  var size: CGSize {
    get {
      return frame.size
    }
    set(size) {
      frame = sizeLens.to(size, frame)
    }
  }
  var origin: CGPoint {
    get {
      return frame.origin
    }
    set(origin) {
      frame = originLens.to(origin, frame)
    }
  }
  var centerX: CGFloat {
    get {
      return center.x
    }
    set(centerX) {
      center = CGPoint(x: centerX, y: centerY)
    }
  }
  var centerY: CGFloat {
    get {
      return center.y
    }
    set(centerY) {
      center = CGPoint(x: centerX, y: centerY)
    }
  }
  var left: CGFloat {
    get {
      return frame.origin.x
    }
    set(left) {
      frame = xLens.to(left, frame)
    }
  }
  var right: CGFloat {
    get {
      return left + width
    }
    set(right) {
      left = right - width
    }
  }
  var top: CGFloat {
    get {
      return frame.origin.y
    }
    set(top) {
      frame = yLens.to(top, frame)
    }
  }
  var bottom: CGFloat {
    get {
      return top + height
    }
    set(bottom) {
      frame = yLens.to(bottom - height, frame)
    }
  }
}

extension UIView {
  func enableGlow(enable: Bool = true, glowColor: UIColor, blur: CGFloat, spread: CGFloat, opacity: Float) {
    layer.shadowOffset = .zero
    layer.shadowColor = enable ? glowColor.CGColor : nil
    layer.shadowRadius = enable ? blur : 0
    layer.shadowOpacity = enable ? opacity : 0
    layer.masksToBounds = !enable
    layer.rasterizationScale = UIScreen.mainScreen().scale
    layer.shouldRasterize = true
    
    if spread == 0 { return }

    let shadowRect = width < height ?
      xLens.to(bounds.origin.x - spread / 2, widthLens.to(bounds.width + spread, bounds)) :
      yLens.to(bounds.origin.y - spread / 2, heightLens.to(bounds.height + spread, bounds))

    layer.shadowPath = UIBezierPath(ovalInRect: shadowRect).CGPath
  }
  
  func applyInterpolatingMotionEffect(minimumRelativeValue: Double, maximumRelativeValue: Double, forKeyPath keypath: String) {
    if motionEffects.count > 0 { return }
    
    addMotionEffect(UIMotionEffectGroup().then {
      $0.motionEffects = [
        UIInterpolatingMotionEffect(keyPath: "\(keypath).y", type: .TiltAlongVerticalAxis).then {
          $0.minimumRelativeValue = minimumRelativeValue
          $0.maximumRelativeValue = maximumRelativeValue
        },
        UIInterpolatingMotionEffect(keyPath: "\(keypath).x", type: .TiltAlongHorizontalAxis).then {
          $0.minimumRelativeValue = minimumRelativeValue
          $0.maximumRelativeValue = maximumRelativeValue
        }]
      })
  }
  
  func applyParrallaxEffect(minimumRelativeValue: Double, maximumRelativeValue: Double) {
    applyInterpolatingMotionEffect(minimumRelativeValue, maximumRelativeValue: maximumRelativeValue, forKeyPath: "center")
  }
  
  func hideAnimated(hide: Bool = true, duration: Double = 0.2) {
    UIView.animateWithDuration(duration, animations: {
      self.alpha = hide ? 0 : 1
      if !hide { self.hidden = false }
    }) { _ in
      if hide { self.hidden = true }
    }
  }
  
  func shake(maxOffset: Float = -12) {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    animation.duration = 0.6
    animation.values = [-maxOffset, maxOffset,
      -maxOffset, maxOffset,
      -maxOffset/2, maxOffset/2,
      -maxOffset/4, maxOffset/4, 0]
    layer.addAnimation(animation, forKey: "shake")
  }
}

private func transition(withDuration duration: Double) -> CATransition {
  return CATransition().then {
    $0.duration = duration
    $0.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    $0.type = kCATransitionFade
  }
}

extension UIImageView {
  override func applyParrallaxEffect(minimumRelativeValue: Double, maximumRelativeValue: Double) {
    applyInterpolatingMotionEffect(minimumRelativeValue, maximumRelativeValue: maximumRelativeValue, forKeyPath: "layer.contentsRect.origin")
  }
  
  func crossDissolveAnimateChange(withDuration duration: Double = 0.3) {
    layer.addAnimation(transition(withDuration: duration), forKey: nil)
  }
}

extension UIButton {
  convenience init(icon: Asset) {
    self.init()
    setImage(UIImage(asset: icon).imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    imageView?.tintColor = .whiteColor()
  }
  
  func crossDissolveAnimateChange(withDuration duration: Double = 0.3) {
    layer.addAnimation(transition(withDuration: duration), forKey: nil)
  }
}

extension UITextView {
  func updateTextFontSize(maxFontSize: CGFloat, minFontSize: CGFloat) {
    if size == .zero { return }
    
    let expectSize = sizeThatFits(CGSize(width: width, height: .max))
    var expectFont = font
    
    if expectSize.height > height {
      while sizeThatFits(CGSize(width: width, height: .max)).height > height
        && font?.pointSize > minFontSize {
          expectFont = font?.fontWithSize(font!.pointSize - 1)
          font = expectFont
      }
    } else {
      while sizeThatFits(CGSize(width: width, height: .max)).height < height
        && font?.pointSize < maxFontSize {
          expectFont = font
          font = font?.fontWithSize(font!.pointSize + 1)
      }
      font = expectFont
    }
  }
}

extension UILabel {
  func updateTextFontSize(maxFontSize: CGFloat, minFontSize: CGFloat) {
    if text?.length < 1 || bounds.size == .zero { return }
    
    let expectSize = sizeThatFits(CGSize(width: width, height: .max))
    var expectFont = font
    
    if expectSize.height > height {
      while sizeThatFits(CGSize(width: width, height: .max)).height > height
        && font?.pointSize > minFontSize {
          expectFont = font!.fontWithSize(font!.pointSize - 1)
          font = expectFont
      }
    } else {
      while sizeThatFits(CGSize(width: width, height: .max)).height < height
        && font?.pointSize < maxFontSize {
          expectFont = font
          font = font!.fontWithSize(font!.pointSize + 1)
      }
      font = expectFont
    }
  }
}

class PersimmonTextField: UITextField {
  var insets: UIEdgeInsets
  
  required init?(coder aDecoder: NSCoder) {
    self.insets = UIEdgeInsetsZero
    super.init(coder: aDecoder)
  }
  
  // placeholder position
  override func textRectForBounds(bounds: CGRect) -> CGRect {
    return super.textRectForBounds(UIEdgeInsetsInsetRect(bounds, insets))
  }
  
  // text position
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return super.editingRectForBounds(UIEdgeInsetsInsetRect(bounds, insets))
  }
}

extension UITextField {
  func addBottomSeparator()  {
    let border = CALayer().then {
      let borderWidth: CGFloat = 0.5
      $0.frame = CGRect(x: 20, y: height - borderWidth, width: width - left, height: height)
      $0.borderColor = tintColor.CGColor
      $0.borderWidth = borderWidth
    }
    layer.addSublayer(border)
    layer.masksToBounds = true
  }
}

extension Array where Element: UITextField {
  func addBottomSeparators()  {
    for textField in self { textField.addBottomSeparator() }
  }
}