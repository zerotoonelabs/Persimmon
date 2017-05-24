//
//  TutorialViewController.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/1/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import FXPageControl
import KMPlaceholderTextView
import Sugar
import Reusable
import UIKit

private let pageCount = 9

final class TutorialViewController: BaseViewController {
  @IBOutlet private weak var backgroundImageView: UIImageView!
  @IBOutlet private weak var pageControl: FXPageControl!
  @IBOutlet private weak var collectionView: UICollectionView!
  
  private var shouldShowTooltip = true
  private var textViewShaken = false
  private var userGoals = [UserGoal]() {
    didSet {
      dispatch { self.collectionView.reloadData() }
    }
  }
  private lazy var viewModel = GoalsViewModel()
  private var currentPage = 0 {
    didSet {
      var backgroundImage: UIImage? = nil
      if currentPage < userGoals.count {
        backgroundImage = userGoals[currentPage].goal.categoryBackgroundImage
      } else {
        backgroundImage = currentPage == userGoals.count ?
          UIImage(named: "EndTurtorialBackground") : UIImage(named: "DayEveningTutorialBackground")
      }
      
      dispatch {
        self.pageControl.currentPage = self.currentPage
        if let backgroundImage = backgroundImage {
          self.backgroundImageView.image = backgroundImage
          self.backgroundImageView.crossDissolveAnimateChange()
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
  
  deinit {
    removeObserver(self, forKeyPath: "collectionView.contentOffset")
  }
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
    showLoading()
    viewModel.userGoals.startWithNext {
      self.hideLoading()
      self.userGoals = $0
    }
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
  
  // MARK: - Private
  
  private func setUpViews() {
    pageControl.currentPage = 0
    
    collectionView.collectionViewLayout = CardsCollectionViewLayout(UIOffsetMake(20, 0))
    collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    collectionView.decelerationRate = 0
    addObserver(self, forKeyPath: "collectionView.contentOffset",
      options: NSKeyValueObservingOptions([.New]), context: nil)
  }
  
  var transitionedToGoals = false
  @IBAction func startButtonTouched() {
    let dirtyUserGoals = userGoals.filter { $0.dirty }
    if dirtyUserGoals.count < 1 {
      showGoals()
    } else {
      showLoading()
      saveUserGoals(dirtyUserGoals)
    }
  }
  
  private func saveUserGoals(userGoals: [UserGoal]) {
    Goal.saveUserGoals(userGoals).start { event in
      self.hideLoading()
      if self.transitionedToGoals { return }
      if case let .Failed(error) = event {
        dispatch { self.showError("The goals could not be saved.") }
        log.error("error saving userGoals: \(error)")
      }
      
      self.transitionedToGoals = true
      self.showGoals()
    }
  }
  
  private func showGoals() {
    guard let appDelegate = UIApplication.sharedApplication().delegate else { return }
    let navigationController = UINavigationController()
    navigationController.viewControllers = [GoalsViewController()]
    dispatch {
      UIView.transitionWithView(appDelegate.window!!, duration: 0.3, options: .TransitionCrossDissolve, animations: {
        appDelegate.window!!.rootViewController = navigationController
        }, completion: nil)
    }
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
}

// MARK: - UICollectionViewDataSource

extension TutorialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userGoals.count > 0 ? userGoals.count + 2 : 0
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
    -> UICollectionViewCell {
      if indexPath.row < userGoals.count {
        return (collectionView.dequeueReusableCell(indexPath: indexPath) as TutorialCell).then {
          if !textViewShaken {
            textViewShaken = true
            $0.goalTextView.shake()
          }
          
          $0.goalTextView.delegate = self
          $0.configureForUserGoal(userGoals[indexPath.row])
          $0.updateLetterCount(Constants.goalCharactersMaxCount)
          if shouldShowTooltip { $0.showTooltip() }
        }
      } else if indexPath.row == userGoals.count {
        return collectionView.dequeueReusableCell(indexPath: indexPath) as CardCell
      } else {
        return (collectionView.dequeueReusableCell(indexPath: indexPath) as EndTutorialCell).then {
          $0.titleLabel.enableGlow(glowColor: UIColor.blackColor(), blur: 9, spread: 0, opacity: 0.62)
          $0.startButton.layer.borderColor = UIColor.whiteColor().CGColor
          $0.startButton.layer.borderWidth = 2
          $0.startButton.layer.cornerRadius = 10
        }
      }
  }
}

// MARK: UITextViewDelegate

extension TutorialViewController: UITextViewDelegate {
  func textViewDidBeginEditing(textView: UITextView) {
    if let currentCell = currentCell as? TutorialCell {
      shouldShowTooltip = false
      currentCell.tipView.dismiss()
    }
    collectionView.scrollEnabled = false
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    collectionView.scrollEnabled = true
    textView.text = textView.text.split(" ").joinWithSeparator(" ")
    textViewDidChange(textView)
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return "\(text)\(textView.text)".length <= Constants.goalCharactersMaxCount
  }
  
  func textViewDidChange(textView: UITextView) {
    if let currentCell = currentCell as? TutorialCell {
      if textView == currentCell.goalTextView {
        guard let textView = textView as? KMPlaceholderTextView else { return }
        currentUserGoal.goal.text = textView.text.length > 0 ? textView.text : textView.placeholder
        currentCell.updateLetterCount(Constants.goalCharactersMaxCount)
        textView.updateTextFontSize(currentCell.goalTextViewMaxFontSize,
          minFontSize: currentCell.goalTextViewMinFontSize)
      }
    }
  }
}