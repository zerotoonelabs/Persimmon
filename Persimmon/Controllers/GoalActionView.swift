//
//  GoalActionView.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/23/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Cartography
import ReactiveCocoa
import Transporter
import KMPlaceholderTextView
import Sugar
import UIKit

private let buttonOffset: CGFloat = 16
private let actionButtonSize = CGSize(width: 38, height: 47)
private let commentTextViewPadding = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
private let commentLetterCountLabelPadding = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
private let commentCancelButtonPadding = UIEdgeInsets(top: 5, left: 0, bottom: 9, right: 0)
private let actionLabelPadding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
private let commentLetterCountLabelSize = CGSize(width: 0, height: 17)

final class GoalActionView: UIView {
  private lazy var actionLabel = UILabel().then {
    $0.minimumScaleFactor = 0.3
    $0.adjustsFontSizeToFitWidth = true
    $0.font = .systemFontOfSize(15, weight: UIFontWeightLight)
    $0.textColor = .whiteColor()
    $0.text = NSLocalizedString("Have you done anything today?", comment: "Action label for goal card")
    $0.shadowColor = UIColor(white: 1, alpha: 0.5)
    $0.textAlignment = .Center
  }
  private lazy var checkButton: GoalActionButton = {
    return GoalActionButton(image: UIImage(asset: .CheckUpIcon), title: "Yes", imageAtTop: true).then {
      $0.rac_command = RACCommand {
        guard let sender = $0 as? GoalActionButton else { return .empty() }
        self.animate = true
        self.selectButton(sender)
        return .empty()
      }
    }
  }()
  private lazy var crossButton: GoalActionButton = {
    return GoalActionButton(image: UIImage(asset: .CheckDownIcon), title: "No", imageAtTop: false).then {
      $0.rac_command = RACCommand {
        guard let sender = $0 as? GoalActionButton else { return .empty() }
        self.animate = true
        self.selectButton(sender)
        return .empty()
      }
    }
  }()
  private lazy var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
  lazy var commentTextView: KMPlaceholderTextView = {
    return KMPlaceholderTextView().then {
      $0.placeholderColor = UIColor(white: 1, alpha: 0.7)
      $0.scrollEnabled = false
      $0.textContainerInset = UIEdgeInsetsZero
      $0.textContainer.lineFragmentPadding = 0
      $0.backgroundColor = .clearColor()
      $0.textAlignment = .Center
      $0.textColor = .whiteColor()
      $0.font = .systemFontOfSize(17, weight: UIFontWeightLight)
      $0.keyboardAppearance = .Dark
      $0.returnKeyType = .Done
    }
  }()
  private lazy var commentLetterCountLabel = UILabel().then {
    $0.font = .systemFontOfSize(14)
    $0.textColor = .whiteColor()
    $0.textAlignment = .Center
  }
  private lazy var commentCancelButton: UIButton = {
    return UIButton().then {
      $0.setTitleColor(.whiteColor(), forState: .Normal)
      $0.titleLabel?.textAlignment = .Center
      $0.titleLabel?.font = .systemFontOfSize(20, weight: UIFontWeightLight)
      $0.setTitle("Cancel", forState: .Normal)
      $0.rac_command = RACCommand { _ in
        self.userGoalEntry.activateState(.Untouched)
        self.commentTextView.resignFirstResponder()
        return .empty()
      }
    }
  }()
  
  var userGoal: UserGoal?
  var animate: Bool = false
  var buttonsConstraintGroup: ConstraintGroup?
  private var initialLocation = CGPoint.zero
  private var buttonToPan: GoalActionButton?
  private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    return UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
  }()
  
  lazy var userGoalEntry: StateMachine<UserGoalEntryState> = {
    let untouched = State(UserGoalEntryState.Untouched)
    untouched.didEnterState = { _ in
      self.reset(false)
    }
    let didCommit = State(UserGoalEntryState.DidCommit)
    didCommit.didEnterState = { _ in
      self.activityIndicatorView.stopAnimating()
      self.hidden = true
    }
    let didNotCommit = State(UserGoalEntryState.DidNotCommit)
    didNotCommit.didEnterState = { _ in
      self.activityIndicatorView.stopAnimating()
      self.hidden = true
    }
    return StateMachine(initialState: untouched, states: [didCommit, didNotCommit])
  }()

  
  // MARK: - Initialization

  init() {
    super.init(frame: .zero)
    
    addGestureRecognizer(panGestureRecognizer)
    [actionLabel, checkButton, crossButton, activityIndicatorView,
      commentTextView, commentCancelButton, commentLetterCountLabel].forEach {
        addSubview($0)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  func updateLetterCount(maxCount: Int) {
    commentLetterCountLabel.text = "\(commentTextView.text.length)/\(maxCount)"
  }
  
  func setUpConstraints() {
    constrain(actionLabel, self) { actionLabel, view in
      actionLabel.left == view.left + actionLabelPadding.left
      actionLabel.right == view.right - actionLabelPadding.right
      actionLabel.center == view.center
    }
    constrain(checkButton, crossButton, activityIndicatorView, self) {
      checkButton, crossButton, activityIndicatorView, view in
      checkButton.width == actionButtonSize.width
      checkButton.height == actionButtonSize.height
      crossButton.size == checkButton.size
      checkButton.centerX == view.centerX
      crossButton.centerX == view.centerX
      activityIndicatorView.center == view.center
    }
    constrain(commentTextView, commentLetterCountLabel, commentCancelButton, self) {
      commentTextView, commentLetterCountLabel, commentCancelButton, view in
      commentTextView.left == view.left + commentTextViewPadding.left
      commentTextView.right == view.right - commentTextViewPadding.right
      commentTextView.height <= view.height / 3
      commentTextView.height >= view.height / 4
      commentTextView.centerY == view.centerY
      commentLetterCountLabel.height == commentLetterCountLabelSize.height
      commentLetterCountLabel.top == commentTextView.bottom + commentLetterCountLabelPadding.top
      commentLetterCountLabel.centerX == view.centerX
      commentCancelButton.top == commentLetterCountLabel.bottom + commentCancelButtonPadding.top
      commentCancelButton.bottom == view.bottom - commentCancelButtonPadding.bottom
      commentCancelButton.centerX == view.centerX
    }
    updateButtonsConstraints()
  }
  
  func updateButtonsConstraints() {
    buttonsConstraintGroup = ConstraintGroup()

    constrain(checkButton, crossButton, self, replace: buttonsConstraintGroup!) { checkButton, crossButton, view in
      checkButton.top == view.top + buttonOffset
      crossButton.bottom == view.bottom - buttonOffset
    }
  }
  
  func panned(pan: UIPanGestureRecognizer) {
    let translation = pan.translationInView(self)
    
    if pan.state == .Began {
      buttonToPan = translation.y < 0 ? checkButton : crossButton
      initialLocation = buttonToPan!.center
    } else if let buttonToPan = buttonToPan where pan.state == .Changed {
      let y = initialLocation.y + translation.y
      buttonToPan.center = CGPoint(x: initialLocation.x, y: initialLocation.y + y)
    } else {
      guard let buttonToPan = buttonToPan else { return }
      
      let delta = buttonToPan.center.y - initialLocation.y
      var shouldSelect = buttonToPan == checkButton ? delta < 0 : delta > 0
      
      UIView.animateWithDuration(0.2) {
        buttonToPan.center = self.initialLocation
        shouldSelect = shouldSelect && abs(delta) > 15
        
        if pan.state == .Ended && shouldSelect {
          buttonToPan.sendActionsForControlEvents(.TouchUpInside)
          self.buttonToPan = nil
        }
      }
    }
  }

  func reset(loading: Bool) {
    hidden = false
    [commentTextView, commentLetterCountLabel, commentCancelButton].forEach { $0.hidden = true }
    [checkButton, crossButton, actionLabel].forEach { $0.hidden = false }
    
    loading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    
    [checkButton, crossButton, actionLabel].forEach {
      if let actionButton = $0 as? GoalActionButton {
        actionButton.selected = false
      }
      $0.alpha = loading ? 0 : 1
    }
    [checkButton, crossButton].forEach { $0.userInteractionEnabled = !loading }
    panGestureRecognizer.enabled = !loading
  }
  
  // MARK: - Private

  private func selectButton(selectButton: GoalActionButton) {
    let hideButton = (selectButton == checkButton) ? crossButton : checkButton
    
    activityIndicatorView.stopAnimating()
    panGestureRecognizer.enabled = false
    selectButton.userInteractionEnabled = false
    actionLabel.alpha = 1
    
    if !animate {
      selectButton.alpha = 1
      hideButton.alpha = 0
      selectButton.selected = true
      updateButtonsConstraints()
      toggleCommentVisibility(selectButton == crossButton)
      
      return
    }
    
    UIView.animateWithDuration(0.5, animations: {
      selectButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2)
    }) { _ in
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0,
        options: [.BeginFromCurrentState], animations: {
          selectButton.transform = CGAffineTransformIdentity
        }) { finished in
          if !finished { return }
          
          self.toggleCommentVisibility(selectButton == self.crossButton)
          if selectButton != self.crossButton { return }
          
          self.userGoalEntry.activateState(.DidNotCommit)
          self.userGoal?.updateState(.DidNotCommit, comment: nil).start()
          
          guard let cell = self.superview?.superview as? GoalCell else { return }
          UIView.animateWithDuration(0.2) {
            cell.enableGlows(true, imageViewGlowColor: .failColor())
          }
      }
    }
    
    UIView.animateWithDuration(0.5) {
      selectButton.selected = true
      selectButton.alpha = 1
      hideButton.alpha = 0
      
      self.updateButtonsConstraints()
    }
  }
  
  private func toggleCommentVisibility(hide: Bool) {
    [commentTextView, commentLetterCountLabel, commentCancelButton].forEach { $0.hidden = hide }
    [actionLabel, checkButton, crossButton].forEach { $0.hidden = !hide }
    
    if !commentTextView.hidden {
      commentTextView.becomeFirstResponder()
    }
  }
}