//
//  TutorialCell.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/2/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import KMPlaceholderTextView
import EasyTipView
import Reusable
import UIKit

final class TutorialCell: CardCell {
  private let tipTextPadding = UIEdgeInsets(top: 5, left: 12, bottom: 12, right: 5)
  private let tipViewWidth: CGFloat = 141
  private let cellHPadding: CGFloat = 14
  private var shouldShowTooltip = false
  var goalTextViewMaxFontSize: CGFloat = 24
  var goalTextViewMinFontSize: CGFloat = 13
  
  @IBOutlet weak var goalCategoryIconImageView: UIImageView!
  @IBOutlet weak var goalCategoryTitleLabel: UILabel!
  @IBOutlet weak var letterCountLabel: UILabel!
  @IBOutlet weak var goalTextView: KMPlaceholderTextView!
  
  lazy var tipView: EasyTipView = {
    var preferences = EasyTipView.Preferences()
    preferences.drawing.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
    preferences.drawing.foregroundColor = UIColor.whiteColor()
    preferences.drawing.backgroundColor = UIColor(white: 1, alpha: 0.36)
    preferences.drawing.arrowPosition = .Bottom
    preferences.drawing.borderWidth = 1
    preferences.drawing.borderColor = UIColor.whiteColor()
    preferences.positioning.textVInset = self.tipTextPadding.top
    preferences.positioning.textHInset = self.tipTextPadding.left
    return EasyTipView(text: "Tap here to start", preferences: preferences)
  }()
  
  // UICollectionViewCell
  
  override func prepareForReuse() {
    super.prepareForReuse()

    goalTextView.placeholder = ""
    goalTextView.text = ""
    tipView.removeFromSuperview()
    shouldShowTooltip = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    goalTextView.updateTextFontSize(goalTextViewMaxFontSize, minFontSize: goalTextViewMinFontSize)
    tipView.removeFromSuperview()
    if shouldShowTooltip {
      tipView.show(animated: false, forView: goalTextView, withinSuperview: self)
    }
  }
  
  // MARK: Public
  
  func configureForUserGoal(userGoal: UserGoal) {
    cellColor = userGoal.goal.color
    
    goalTextView.layer.cornerRadius = 10
    goalTextView.layer.masksToBounds = true
    goalTextView.layer.borderColor = UIColor(white: 1, alpha: 0.51).CGColor
    goalTextView.layer.borderWidth = 1
    
    goalCategoryTitleLabel.text = userGoal.goal.categoryDescription
    goalCategoryIconImageView.image = userGoal.goal.categoryIconImage
    
    if userGoal.goal.text == GoalCategory(rawValue: userGoal.goal.category)?.defaultText {
      goalTextView.placeholder = userGoal.goal.text
    } else {
      goalTextView.text = userGoal.goal.text
    }
  }
  
  func showTooltip() {
    shouldShowTooltip = true
  }
  
  func updateLetterCount(maxCount: Int) {
    letterCountLabel.text = "\(goalTextView.text.length)/\(maxCount)"
  }
}