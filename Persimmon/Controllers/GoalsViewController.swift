//
//  GoalsViewController.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/7/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import Cartography
import ReactiveCocoa
import TPKeyboardAvoiding
import enum Result.NoError
import class Parse.PFFile
import Whisper
import Reusable
import Sugar
import EasyTipView

final class GoalsViewController: BaseViewController {
  private let activeDayButtonPadding = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0)
  private let inActiveDayButtonPadding = UIEdgeInsets(top: 16, left: 22, bottom: 0, right: 0)
  private let inActiveDayButtonSize = CGSize(width: 22, height: 22)
  private let activeEveningButtonPadding = UIEdgeInsets(top: 11, left: 0, bottom: 0, right: 0)
  private let inActiveEveningButtonPadding = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 25)
  private let inActiveEveningButtonSize = CGSize(width: 18, height: 19)
  private let progressViewSize = CGSize(width: 0, height: 10)
  private let progresssViewPadding = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 10)
  private let topLabelPadding = UIEdgeInsets(top: 35, left: 20, bottom: 0, right: 20)
  
  private let editButtonPadding = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 0)
  private let categoryButtonPadding = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
  private let categoryButtonSize = CGSize(width: 112, height: 39)
  private let shareButtonPadding = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 20)
  private let tipTextPadding = UIEdgeInsets(top: 5, left: 12, bottom: 12, right: 5)
  private let shareButtonSize = CGSize(width: 24, height: 24)
  
  private let collectionViewPadding = UIEdgeInsets(top: 25, left: 0, bottom: 22, right: 0)
  
  private var tipView: EasyTipView?
  
  private lazy var backgroundImageView = UIImageView(image: GoalCategory.Spirituality.backgroundImage).then {
    $0.layer.drawsAsynchronously = true
    $0.userInteractionEnabled = true
  }
  private lazy var dayButton: UIButton = {
    return UIButton(icon: .SunIcon).then {
      $0.adjustsImageWhenHighlighted = false
      $0.rac_command = RACCommand { sender in
        guard let sender = sender as? UIButton else { return .empty() }
        dispatch {
          self.toggleTipView("In the morning, visualize your ideal future.", forView: sender)
        }
        return .empty()
      }
    }
  }()
  private lazy var eveningButton: UIButton = {
    return UIButton(icon: .MoonIcon).then {
      $0.adjustsImageWhenHighlighted = false
      $0.rac_command = RACCommand { sender in
        guard let sender = sender as? UIButton else { return .empty() }
        dispatch {
          self.toggleTipView("In the evening, reflect on the past day.", forView: sender)
        }
        return .empty()
      }
    }
  }()
  private lazy var categoryButton: ImageAtTopButton = {
    return ImageAtTopButton(image: GoalCategory.Spirituality.icon,
      title: GoalCategory.Spirituality.description, imageAtTop: true).then {
        $0.layer.drawsAsynchronously = true
        $0.adjustsImageWhenHighlighted = false
        $0.setTitleColor(.whiteColor(), forState: .Normal)
        $0.titleLabel?.font = .systemFontOfSize(12, weight: UIFontWeightMedium)
        $0.titleLabel?.textAlignment = .Center
        $0.rac_command = RACCommand { sender in
          guard let sender = sender as? UIButton else { return .empty() }
          dispatch {
            self.toggleTipView("Dream up an inspiring life!", forView: sender)
          }
          return .empty()
        }
    }
  }()
  private lazy var topLabel = UILabel().then {
    $0.font = .latoLightOfSize(14)
    $0.textColor = .whiteColor()
  }
  private lazy var editButton: UIButton = {
    return UIButton(icon: .EditIcon).then {
      $0.adjustsImageWhenHighlighted = false
      $0.setTitle("Done", forState: .Selected)
      $0.setImage(UIImage(), forState: .Selected)
      $0.setTitleColor(.whiteColor(), forState: .Normal)
      $0.titleLabel?.font = .boldSystemFontOfSize(16)
      $0.rac_command = RACCommand { sender in
        guard let button = sender as? UIButton else { return .empty() }
        self.inEditMode = !self.inEditMode
        button.selected = self.inEditMode
        return .empty()
      }
    }
  }()
  private lazy var shareButton: UIButton = {
    return UIButton(icon: .PersimmonIcon).then {
      $0.rac_command = RACCommand { _ in
        if self.userGoals.isEmpty { return .empty() }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyboard.instantiateViewControllerWithIdentifier("ShareViewController")
        if let shareVC = shareVC as? ShareViewController {
          shareVC.userGoals = self.userGoals
        }
        self.navigationController?.presentViewController(shareVC, animated: true, completion: nil)
        
        return .empty()
      }
    }
  }()
  private lazy var timeProgressView = ProgressView().then {
    $0.tintColor = .whiteColor()
  }
  lazy var collectionView: TPKeyboardAvoidingCollectionView = {
    let cardsLayout = CardsCollectionViewLayout(UIOffset(horizontal: 20, vertical: 0))
    return TPKeyboardAvoidingCollectionView(frame: .zero, collectionViewLayout: cardsLayout).then {
      $0.clipsToBounds = false
      $0.layer.masksToBounds = false
      $0.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
      $0.decelerationRate = 0
      $0.backgroundColor = .clearColor()
      $0.dataSource = self
      $0.showsHorizontalScrollIndicator = false
      $0.registerReusableCell(GoalCell)
      $0.registerReusableCell(AchievementCell)
    }
  }()
  let timeButtonsConstraintGroup = ConstraintGroup()
  let timeProgressViewConstraintGroup = ConstraintGroup()
  
  private var viewModel: GoalsViewModel = GoalsViewModel()
  private var layout = GoalsViewLayout() {
    didSet { layout.delegate = self }
  }
  private var userGoals = [UserGoal]() {
    didSet {
      dispatch { self.collectionView.reloadData() }
      viewModel.userGoalEntries(forUserGoals: userGoals).startWithNext {
        self.hideLoading()
        self.userGoalEntries = $0
      }
    }
  }
  private var userGoalEntries = [UserGoalEntry]() {
    didSet {
      dispatch { self.collectionView.reloadData() }
    }
  }
  private let backgroundImages = GoalCategory.allValues.map { $0.backgroundImage }
  private let categoryIconImages = GoalCategory.allValues.map { $0.icon }
  private var currentPage = 0 {
    didSet {
      if currentPage < userGoals.count && currentPage >= 0 {
        let currentGoal = userGoals[currentPage].goal
        dispatch {
          self.backgroundImageView.image = self.backgroundImages[self.currentPage]
          self.categoryButton.setImage(self.categoryIconImages[self.currentPage], forState: .Normal)
          self.categoryButton.setTitle(currentGoal.categoryDescription, forState: .Normal)
          self.backgroundImageView.crossDissolveAnimateChange()
          self.categoryButton.crossDissolveAnimateChange()
        }
      }
    }
  }
  private var currentIndexPath: NSIndexPath {
    return NSIndexPath(forItem: currentPage, inSection: 0)
  }
  private var currentCell: UICollectionViewCell? {
    return collectionView.cellForItemAtIndexPath(currentIndexPath)
  }
  private var currentUserGoal: UserGoal {
    return userGoals[currentIndexPath.row]
  }
  private var inEditMode = false {
    didSet {
      if inEditMode != oldValue {
        dispatch { self.collectionView.reloadData() }
        if !inEditMode {
          let dirtyUserGoals = userGoals.filter { $0.dirty }
          if dirtyUserGoals.count < 1 { return }
          showLoading()
          viewModel.saveUserGoals(dirtyUserGoals).startWithNext { _ in
            self.hideLoading()
          }
        }
      }
    }
  }
  private var achievementsShown = false {
    didSet {
      dispatch {
        UIView.animateWithDuration(0.2) {
          self.editButton.alpha = self.achievementsShown ? 0 : 1
        }
        UIView.transitionWithView(self.collectionView, duration: 0.3,
          options: [.TransitionFlipFromRight, .BeginFromCurrentState, .AllowUserInteraction, .ShowHideTransitionViews], animations: {
            self.collectionView.reloadData()
          }, completion: nil)
      }
    }
  }
  private var currentTimeOfDay: TimeOfDay = .Undefined

  // MARK: - View Lifecycle
  
  deinit {
    removeObserver(self, forKeyPath: "collectionView.contentOffset")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    automaticallyAdjustsScrollViewInsets = false
    [backgroundImageView, dayButton, eveningButton, topLabel, categoryButton,
      editButton, shareButton, timeProgressView, collectionView].forEach {
        view.addSubview($0)
    }
    addObserver(self, forKeyPath: "collectionView.contentOffset", options: [.New], context: nil)
    setUpConstraints()
    
    viewModel.layout.startWithNext { self.layout = $0 }
    showLoading()
    viewModel.userGoals.startWithNext { self.userGoals = $0 }
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    navigationController?.navigationBarHidden = true
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    timeProgressView.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.17)
    timeProgressView.progressDot.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.17)
    topLabel.enableGlow(glowColor: UIColor.whiteColor(), blur: 5, spread: 0, opacity: 0.5)
    shareButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 20, spread: 0, opacity: 0.86)
    editButton.enableGlow(glowColor: UIColor.whiteColor(), blur: 20, spread: 0, opacity: 0.86)
  }

  // MARK: - Private

  private func setUpConstraints() {
    constrain(backgroundImageView) { backgroundImageView in
      backgroundImageView.top == backgroundImageView.superview!.top
      backgroundImageView.bottom == backgroundImageView.superview!.bottom
      backgroundImageView.left == backgroundImageView.superview!.left
      backgroundImageView.right == backgroundImageView.superview!.right
    }
    constrain(editButton, categoryButton, shareButton) { editButton, categoryButton, shareButton in
      categoryButton.width == categoryButtonSize.width
      categoryButton.height == categoryButtonSize.height
    }
    constrain(editButton, categoryButton, shareButton, view) {
      editButton, categoryButton, shareButton, view in
      editButton.bottom == view.bottom - editButtonPadding.bottom
      editButton.left == view.left + editButtonPadding.left
      shareButton.width == shareButtonSize.width
      shareButton.height == shareButtonSize.height
      shareButton.bottom == view.bottom - shareButtonPadding.bottom
      shareButton.right == view.right - shareButtonPadding.right
      categoryButton.centerX == view.centerX
      categoryButton.bottom == view.bottom - categoryButtonPadding.bottom
    }
    constrain(dayButton, shareButton, collectionView, view) {
      dayButton, shareButton, collectionView, view in
      collectionView.top == dayButton.bottom + collectionViewPadding.top
      collectionView.bottom == shareButton.top - collectionViewPadding.bottom
      collectionView.left == view.left
      collectionView.right == view.right
    }
    updateTimeButtonsConstraints(forTimeOfDay: layout.time)
  }

  // MARK: - Observers

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
    change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
      if keyPath == "collectionView.contentOffset" {
        let newCurrentPage = Int(round(collectionView.contentOffset.x / collectionView.width))
        if newCurrentPage != currentPage {
          currentPage = newCurrentPage
        }
      }
  }
  
  private func toggleTipView(text: String, forView view: UIView) {
    guard let tipView = tipView else {
      var preferences = EasyTipView.Preferences()
      preferences.drawing.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
      preferences.drawing.foregroundColor = UIColor.whiteColor()
      preferences.drawing.backgroundColor = UIColor(white: 0, alpha: 0.36)
      preferences.drawing.arrowPosition = .Bottom
      preferences.drawing.borderWidth = 1
      preferences.drawing.borderColor = UIColor.whiteColor()
      preferences.positioning.textVInset = tipTextPadding.top
      preferences.positioning.textHInset = tipTextPadding.left
      self.tipView = EasyTipView(text: text, preferences: preferences)
      self.tipView?.show(animated: true, forView: view, withinSuperview: self.view)
      return
    }
    tipView.dismiss()
    self.tipView = nil
  }
  
  func handleTap() {
    tipView?.dismiss()
    tipView = nil
  }
}

// MARK: - UICollectionViewDataSource

extension GoalsViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userGoals.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      tipView?.dismiss()
      tipView = nil
      
      let cell = achievementsShown ? achievementCell(forIndexPath: indexPath) : goalCell(forIndexPath: indexPath)
      if let cell = cell as? CardCellProtocol {
        cell.calendarButton.rac_command = RACCommand() { _ in
          self.achievementsShown = !self.achievementsShown
          return .empty()
        }
      }
      return cell
  }
  
  func goalCell(forIndexPath indexPath: NSIndexPath) -> GoalCell {
    return (collectionView.dequeueReusableCell(indexPath: indexPath) as GoalCell).then {
      $0.time = layout.time
      $0.inEditMode = inEditMode
      $0.descriptionTextView.delegate = self
      $0.configureForUserGoal(userGoals[indexPath.row])
      $0.updateLetterCount(Constants.goalCharactersMaxCount)
      
      if $0.time == .Evening {
        $0.actionView.commentTextView.delegate = self
        $0.actionView.updateLetterCount(Constants.commentCharactersMaxCount)
      }
      
      $0.changeImageOverlayButton.rac_command = RACCommand() { _ in
        self.showImageChooseActionSheet()
        return .empty()
      }
    }
  }
  
  func achievementCell(forIndexPath indexPath: NSIndexPath) -> AchievementCell {
    return (collectionView.dequeueReusableCell(indexPath: indexPath) as AchievementCell).then {
      $0.configureForUserGoal(userGoals[indexPath.row],
        userGoalEntries: userGoalEntries.filter { $0.userGoal.objectId == userGoals[indexPath.row].objectId })
    }
  }
}

// MARK: - GoalsViewLayoutDelegate

extension GoalsViewController: GoalsViewLayoutDelegate {
  func goalsViewLayoutTimeDidChange(time: TimeOfDay, timeIntervalBetweenTimeOfDays: NSTimeInterval,
    timeIntervalToFollowingTimeOfDay: NSTimeInterval) {
      if currentTimeOfDay != time { updateUI(forTimeOfDay: time) }
      let progressOffset = CGFloat(abs((timeIntervalBetweenTimeOfDays - timeIntervalToFollowingTimeOfDay) / timeIntervalBetweenTimeOfDays))
      timeProgressView.progressDotOffset = (time == .Day) ? 1 - progressOffset - 0.1 : 1 - progressOffset
      currentTimeOfDay = time
  }
  
  func updateUI(forTimeOfDay time: TimeOfDay) {
    topLabel.text = time == .Day ? "I’m reviewing" : "I’m reflecting"
    dayButton.alpha = time == .Day ? 1 : 0.5
    dayButton.enableGlow(time == .Day, glowColor: .whiteColor(), blur: 10, spread: 1, opacity: 0.61)
    eveningButton.alpha = time == .Evening ? 1 : 0.5
    eveningButton.enableGlow(time == .Evening, glowColor: .whiteColor(), blur: 11, spread: 1, opacity: 0.61)
    updateTimeButtonsConstraints(forTimeOfDay: time)
    UIView.animateWithDuration(0.2) {
      let radians = (time == .Evening) ? CGFloat(M_PI) : CGFloat(0)
      self.timeProgressView.layer.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
      self.view.layoutIfNeeded()
    }
  }

  func updateTimeButtonsConstraints(forTimeOfDay time: TimeOfDay) {
    let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
    constrain(dayButton, eveningButton, topLabel, view, replace: timeButtonsConstraintGroup) {
      dayButton, eveningButton, topLabel, view in
      topLabel.top == view.top + topLabelPadding.top
      if time == .Day {
        eveningButton.width == inActiveEveningButtonSize.width
        eveningButton.height == inActiveEveningButtonSize.height
        dayButton.top == view.top + statusBarHeight + activeDayButtonPadding.top
        eveningButton.top == view.top + statusBarHeight + inActiveEveningButtonPadding.top
        dayButton.centerX == view.centerX
        eveningButton.right == view.right - inActiveEveningButtonPadding.right
        topLabel.left == view.left + topLabelPadding.left
      } else if time == .Evening {
        dayButton.width == inActiveDayButtonSize.width
        dayButton.height == inActiveDayButtonSize.height
        eveningButton.top == view.top + statusBarHeight + activeEveningButtonPadding.top
        dayButton.top == view.top + statusBarHeight + inActiveDayButtonPadding.top
        eveningButton.centerX == view.centerX
        dayButton.left == view.left + inActiveDayButtonPadding.left
        topLabel.right == view.right - topLabelPadding.right
      }
    }
    
    constrain(timeProgressView, dayButton, eveningButton, replace: timeProgressViewConstraintGroup) {
      progressView, dayButton, eveningButton in
      progressView.height == progressViewSize.height
      if time == .Day {
        progressView.centerY == dayButton.centerY
        progressView.left == dayButton.right + progresssViewPadding.right
        progressView.right == eveningButton.left - progresssViewPadding.left
      } else if time == .Evening {
        progressView.centerY == eveningButton.centerY
        progressView.left == dayButton.right + progresssViewPadding.left
        progressView.right == eveningButton.left - progresssViewPadding.right
      }
    }
  }
}

// MARK: - UITextViewDelegate

extension GoalsViewController: UITextViewDelegate {
  func textViewDidBeginEditing(textView: UITextView) {
    collectionView.scrollEnabled = false
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    collectionView.scrollEnabled = true
    textView.text = textView.text.split(" ").joinWithSeparator(" ")
    textViewDidChange(textView)
    editButton.hidden = false
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      if let currentCell = currentCell as? GoalCell {
        if textView == currentCell.actionView.commentTextView {
          currentUserGoal.updateState(.DidCommit, comment: textView.text).startWithNext {
            if !$0 { return }
            UIView.animateWithDuration(0.2) {
              currentCell.enableGlows(true, imageViewGlowColor: self.currentUserGoal.goal.color)
            }
            self.viewModel.userGoalEntries(forUserGoals: self.userGoals).startWithNext {
              self.userGoalEntries = $0
            }
          }
          currentCell.actionView.userGoalEntry.activateState(.DidCommit)
          self.editButton.hidden = false
        }
      }
      return false
    }
    if let currentCell = currentCell as? GoalCell where
      textView == currentCell.actionView.commentTextView {
        return "\(text)\(textView.text)".length <= Constants.commentCharactersMaxCount
    }
    return "\(text)\(textView.text)".length <= Constants.goalCharactersMaxCount
  }
  
  func textViewDidChange(textView: UITextView) {
    if let currentCell = currentCell as? GoalCell {
      if textView == currentCell.descriptionTextView {
        currentUserGoal.goal.text = textView.text
        currentCell.updateLetterCount(Constants.goalCharactersMaxCount)
        textView.updateTextFontSize(currentCell.descriptionTextViewMaxFontSize,
          minFontSize: currentCell.descriptionTextViewMinFontSize)
      } else {
        currentCell.actionView.updateLetterCount(Constants.commentCharactersMaxCount)
        textView.updateTextFontSize(17, minFontSize: 8)
      }
    }
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    if let currentCell = currentCell as? GoalCell {
      if textView == currentCell.actionView.commentTextView {
        editButton.hidden = true
      }
    }
    return true
  }
}

// MARK: - UIImagePickerControllerDelegate

extension GoalsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func showImageChooseActionSheet() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
    
    if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
      alertController.addAction(UIAlertAction(title: "Choose from Photo Library", style: .Default,
        handler: { _ in
        self.showImagePickerController(fromPhotoLibrary: true)
      }))
    }
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      alertController.addAction(UIAlertAction(title: "Take photo", style: .Default,
        handler: { _ in
        self.showImagePickerController(fromPhotoLibrary: false)
      }))
    }
    if !currentUserGoal.goal.image.name.containsString("default") {
      alertController.addAction(UIAlertAction(title: "Use default picture", style: .Destructive,
        handler: { _ in
        self.changeToDefaultCategoryImage()
      }))
    }
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func changeToDefaultCategoryImage() {
    guard let currentCell = currentCell as? GoalCell,
      currentGoalCategory = GoalCategory(rawValue: currentIndexPath.row) else { return }
    
    let defaultImage = currentGoalCategory.defaultImage
    if let defaultImageData = UIImageJPEGRepresentation(defaultImage, 1),
      defaultImageFile = PFFile(name: "default\(currentGoalCategory.rawValue)", data: defaultImageData) {
      currentUserGoal.goal.image = defaultImageFile
    }
    currentCell.imageView.image = defaultImage
    currentCell.imageView.crossDissolveAnimateChange()
  }
  
  func showImagePickerController(fromPhotoLibrary photoLibrary: Bool) {
    presentViewController(UIImagePickerController().then {
      $0.delegate = self
      $0.sourceType = photoLibrary ? .PhotoLibrary : .Camera
      }, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    picker.dismissViewControllerAnimated(true, completion: nil)
      dispatch(queue: .Background) {
        let resizedImage = image.resizeImage(360)
        let resizedImageData = UIImageJPEGRepresentation(resizedImage, 0.5)

        if let currentCell = self.currentCell as? GoalCell, imageFile = PFFile(data: resizedImageData!) {
          dispatch {
            self.currentUserGoal.goal.image = imageFile
            currentCell.imageView.image = resizedImage
            currentCell.imageView.crossDissolveAnimateChange()
          }
        }
      }
  }
  
  func navigationController(navigationController: UINavigationController,
    willShowViewController viewController: UIViewController, animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .Default
  }
}