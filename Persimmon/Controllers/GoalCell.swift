//
//  GoalCell.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/7/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Cartography
import ReactiveCocoa
import Transporter
import DynamicColor
import Sugar
import Reusable
import UIKit

final class GoalCell: CardCell, CardCellProtocol {
  private let descriptionLabelPadding = UIEdgeInsets(top: 10, left: 14, bottom: 0, right: 14)
  private let imageViewPadding = UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25)
  private let sideViewHeight: CGFloat = 2
  private let calendarButtonPadding = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 14)
  private let descriptionLetterCountLabelPadding = UIEdgeInsets(top: 10, left: 25, bottom: 25, right: 25)
  private let descriptionLetterCountLabelHeight: CGFloat = 12
  var descriptionTextViewMinFontSize: CGFloat = 16
  var descriptionTextViewMaxFontSize: CGFloat = 24
  
  lazy var descriptionTextView: UITextView = {
    return UITextView().then {
      $0.editable = self.inEditMode
      $0.textContainerInset = UIEdgeInsetsZero
      $0.textContainer.lineFragmentPadding = 0
      $0.backgroundColor = .clearColor()
      $0.textAlignment = .Center
      $0.textColor = .whiteColor()
      $0.font = .systemFontOfSize(24, weight: UIFontWeightLight)
      $0.keyboardAppearance = .Dark
      $0.returnKeyType = .Done
      $0.enableGlow(glowColor: .blackColor(), blur: 4, spread: 0, opacity: 1)
      $0.scrollEnabled = false
    }
  }()
  private lazy var descriptionLetterCountLabel: UILabel = {
    return UILabel().then {
      $0.hidden = !self.inEditMode
      $0.font = .systemFontOfSize(14)
      $0.textColor = .whiteColor()
      $0.textAlignment = .Right
    }
  }()
  private lazy var imageViewContainer: UIView = {
    return UIView().then {
      $0.optimize()
      $0.backgroundColor = .clearColor()
      $0.addSubview(self.imageView)
      $0.addSubview(self.changeImageOverlayButton)
    }
  }()
  lazy var imageView = UIImageView().then {
    $0.optimize()
    $0.userInteractionEnabled = true
    $0.contentMode = .Center
  }
  lazy var changeImageOverlayButton: UIButton = {
    return UIButton().then {
      $0.backgroundColor = UIColor(white: 0, alpha: 0.36)
      $0.titleLabel?.textAlignment = .Center
      $0.titleLabel?.font = .systemFontOfSize(17, weight: UIFontWeightLight)
      $0.setTitle("Change the picture", forState: .Normal)
      $0.hidden = !self.inEditMode
    }
  }()
  lazy var actionView = GoalActionView().then {
    $0.clipsToBounds = true
    $0.backgroundColor = UIColor(white: 0, alpha: 0.36)
  }
  lazy var calendarButton: UIButton = {
    return UIButton().then {
      $0.hidden = self.inEditMode
      $0.setImage(UIImage(asset: .CalendarIcon), forState: .Normal)
    }
  }()
  
  var inEditMode = false {
    didSet {
      dispatch {
        self.descriptionTextView.editable = self.inEditMode
        self.calendarButton.hidden = self.inEditMode
        self.descriptionLetterCountLabel.hideAnimated(!self.inEditMode)
        self.changeImageOverlayButton.hideAnimated(!self.inEditMode)
        if self.inEditMode { self.actionView.hidden = true }
      }
    }
  }
  var time: TimeOfDay = .Day {
    didSet {
      dispatch {
        self.actionView.hidden = self.time == .Day || !self.actionView.userGoalEntry.isInState(.Untouched)
      }
    }
  }

  // MARK: Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override func setup() {
    super.setup()
    
    [imageViewContainer, actionView, descriptionTextView, descriptionLetterCountLabel, calendarButton].forEach {
      contentView.addSubview($0)
    }
    
    cornerRadius = 20
    borderWidth = 2
    setUpConstraints()
  }

  // MARK: - UICollectionReusableView

  override func prepareForReuse() {
    super.prepareForReuse()
    enableGlows(false, imageViewGlowColor: .whiteColor())
    descriptionTextView.text = ""
    glowsEnabled = false
    imageView.image = nil
    imageView.motionEffects.forEach { imageView.removeMotionEffect($0) }
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    imageViewContainer.layer.cornerRadius = imageViewContainer.height / 2
    imageView.layer.cornerRadius = imageView.height / 2
    changeImageOverlayButton.layer.cornerRadius = changeImageOverlayButton.height/2
    if time == .Evening {
      actionView.layer.cornerRadius = actionView.height / 2
    }
    imageView.applyParrallaxEffect(-0.075, maximumRelativeValue: 0.075)
  }

  // MARK: - Public

  func configureForUserGoal(userGoal: UserGoal) {
    cellColor = userGoal.goal.color

    descriptionTextView.text = userGoal.goal.text
    
    if userGoal.goal.isDefault {
      imageView.image = GoalCategory(rawValue: userGoal.goal.category)?.defaultImage
    } else {
      userGoal.goal.image.getDataInBackgroundWithBlock { data, error in
        if error != nil {
          log.error("Failed to get image for goal: \(userGoal)")
        } else if let data = data {
          let resizedImage = UIImage(data: data)?.resizeImage(360)
          dispatch { self.imageView.image = resizedImage }
        }
      }
    }
    
    descriptionTextView.updateTextFontSize(descriptionTextViewMaxFontSize,
      minFontSize: descriptionTextViewMinFontSize)
    
    if time == .Evening {
      if let defaultGoalEntryText = GoalCategory(rawValue: userGoal.goal.category)?.defaultGoalEntryText {
        actionView.commentTextView.placeholder = defaultGoalEntryText
      }
      actionView.userGoal = userGoal
      actionView.reset(true)
      
      userGoal.getCurrentGoalEntry().start { event in
        switch event {
        case let .Next(userGoalEntry):
          guard let state = UserGoalEntryState(rawValue: userGoalEntry.state) else { return }
          self.actionView.animate = false
          self.actionView.userGoalEntry.activateState(state)
          if state != .Untouched {
            self.enableGlows(true, imageViewGlowColor: state == .DidCommit ? userGoal.goal.color : .redColor())
          }
        case let .Failed(error):
          log.error("Failed to get user goal entry: \(error)")
        default: ()
        }
      }
    }
  }
  
  func updateLetterCount(maxCount: Int) {
    descriptionLetterCountLabel.text = "\(descriptionTextView.text.length)/\(maxCount)"
  }
  
  private var glowsEnabled = false
  func enableGlows(enable: Bool = true, imageViewGlowColor: UIColor = .whiteColor()) {
    glowsEnabled = enable
    imageViewContainer.enableGlow(enable, glowColor: imageViewGlowColor, blur: 8, spread: 0, opacity: 0.86)
  }

  // MARK: - Private

  private func setUpConstraints() {
    let factor: CGFloat = (UIDevice().screenType == .iPhone4) ? 2 : 1
    
    constrain(imageViewContainer, imageView, actionView, changeImageOverlayButton, self) {
      imageViewContainer, imageView, actionView, changeImageButton, view in
      imageViewContainer.top == view.top + imageViewPadding.top / factor
      imageViewContainer.left == view.left + imageViewPadding.left * factor
      imageViewContainer.right == view.right - imageViewPadding.right * factor
      imageViewContainer.height == imageView.width
      imageView.edges == imageViewContainer.edges
      changeImageButton.edges == imageView.edges
      actionView.edges == imageViewContainer.edges
    }
    constrain(descriptionTextView, descriptionLetterCountLabel, imageView, self) {
      descriptionTextView, descriptionLetterCountLabel, imageView, view in
      descriptionTextView.top == imageView.bottom + descriptionLabelPadding.top
      descriptionTextView.left == view.left + descriptionLabelPadding.left
      descriptionTextView.right == view.right - descriptionLabelPadding.right
    }
    constrain(descriptionTextView, descriptionLetterCountLabel, self) {
      descriptionTextView, descriptionLetterCountLabel, view in
      descriptionLetterCountLabel.top == descriptionTextView.bottom + descriptionLetterCountLabelPadding.top
      descriptionLetterCountLabel.bottom == view.bottom - descriptionLetterCountLabelPadding.bottom / factor
      descriptionLetterCountLabel.height == descriptionLetterCountLabelHeight
      descriptionLetterCountLabel.left == view.left + descriptionLetterCountLabelPadding.left
      descriptionLetterCountLabel.right == view.right - descriptionLetterCountLabelPadding.right
    }
    constrain(calendarButton, self) { calendarButton, view in
      calendarButton.bottom == view.bottom - calendarButtonPadding.bottom
      calendarButton.right == view.right - calendarButtonPadding.right
    }
    actionView.setUpConstraints()
  }
}