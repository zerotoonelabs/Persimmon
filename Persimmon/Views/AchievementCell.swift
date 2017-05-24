//
//  AchievementCell.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/18/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import Cartography
import CVCalendar
import ReactiveCocoa
import Reusable
import Sugar
import UIKit

private let cornerRadius: CGFloat = 20
private let sideViewHeight: CGFloat = 2
private let calendarMenuViewHeight: CGFloat = 24
private let descriptionLabelPadding = UIEdgeInsets(top: 40, left: 22, bottom: 36, right: 22)
private let calendarButtonPadding = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 14)
private let calendarViewPadding = UIEdgeInsets(top: 22, left: 22, bottom: 18, right: 22)
private let monthYearLabelsSidePadding: CGFloat = 26

final class AchievementCell: UICollectionViewCell, CardCellProtocol, Reusable {
  private lazy var descriptionLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.textAlignment = .Center
    $0.textColor = .whiteColor()
    $0.font = .systemFontOfSize(20, weight: UIFontWeightLight)
  }
  private lazy var sideViews = [UIView(), UIView(), UIView(), UIView()]
  lazy var calendarButton: UIButton = UIButton().then {
    $0.setImage(UIImage(asset: .ReverseIcon), forState: .Normal)
  }
  var calendarView: CVCalendarView!
  private lazy var monthLabel = UILabel().then {
    $0.font = .systemFontOfSize(20, weight: UIFontWeightLight)
    $0.textColor = .whiteColor()
  }
  private lazy var yearLabel = UILabel().then {
    $0.font = .systemFontOfSize(20, weight: UIFontWeightLight)
    $0.textColor = .whiteColor()
  }
  var datesWithComments = [NSDate: String]() {
    didSet { reloadSelection() }
  }
  
  override var tintColor: UIColor! {
    didSet { calendarView.calendarAppearanceDelegate = self }
  }
  
  // MARK: Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.cornerRadius = cornerRadius
    layer.borderWidth = 2
    opaque = true
    let calendarViewWidth = frame.width - (calendarViewPadding.left + calendarViewPadding.right)
    let calendarViewHeight: CGFloat = (UIDevice().screenType != .iPhone4) ? 225 : 225 / 1.4
    calendarView = CVCalendarView(frame: CGRect(x: 0, y: 0, width: calendarViewWidth, height: calendarViewHeight)).then {
      $0.calendarAppearanceDelegate = self
      $0.calendarDelegate = self
    }
    (sideViews + [calendarView, monthLabel, yearLabel, descriptionLabel, calendarButton]).forEach {
      contentView.addSubview($0)
    }
    
    setUpConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionReusableView
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    descriptionLabel.text = ""
    layer.backgroundColor = UIColor.lightGrayColor().CGColor
    calendarView.coordinator.flush()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    calendarView.commitCalendarViewUpdate()
  }
  
  // MARK: - Public
  
  func configureForUserGoal(userGoal: UserGoal, userGoalEntries: [UserGoalEntry]) {
    tintColor = userGoal.goal.color
    
    layer.backgroundColor = tintColor.colorWithAlphaComponent(0.66).CGColor
    layer.borderColor = tintColor.CGColor
    
    descriptionLabel.text = userGoal.goal.text
    descriptionLabel.updateTextFontSize(20, minFontSize: 13)
    
    let presentedDate = calendarView.presentedDate
    monthLabel.text = NSDateFormatter().monthSymbols[presentedDate.month - 1]
    yearLabel.text = "\(presentedDate.year)"
    
    datesWithComments = Dictionary(keys: userGoalEntries.map { $0.date },
      values: userGoalEntries.map { $0.comment })
  }
  
  func reloadSelection() {
    guard let monthContentController = calendarView.contentController as? CVCalendarMonthContentViewController,
      monthView = monthContentController.monthViews["Presented"],
      weeks = monthView.weeksIn else { return }
    
    removeSelection()
    
    let dates = datesWithComments.map { $0.0 }
    let calendar = NSCalendar.currentCalendar()
    
    let monthDate = calendar.startOfDayForDate(monthView.date)
    let components = calendar.components([.Year, .Month], fromDate: monthDate).then {
      $0.calendar = calendar
    }
    
    for (weekNumber, week) in weeks.enumerate() {
      for day in week {
        for dateToSelect in dates {
          components.setValue(day.1.first!, forComponent: .Day)
          let date = components.date!
          
          if calendar.isDate(date, equalToDate: dateToSelect, toUnitGranularity: [.Year, .Month, .Day]) {
            let dayPositionToSelect = day.0 + weekNumber * 7 - (7 - monthView.weekViews.first!.weekdaysIn!.count)
            monthContentController.selectDayViewWithDay(dayPositionToSelect, inMonthView: monthView)
          }
        }
      }
    }
    
    monthContentController.updateSelection()
  }
  
  private func removeSelection() {
    guard let monthContentController = calendarView.contentController as? CVCalendarMonthContentViewController,
      monthView = monthContentController.monthViews["Presented"] else { return }
    monthView.weekViews.map { $0.dayViews }.forEach { $0.forEach { $0.setDeselectedWithClearing(true) } }
    calendarView.coordinator.flush()
  }
  
  // MARK: - Private
  
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
    constrain(monthLabel, yearLabel, descriptionLabel, self) { monthLabel, yearLabel, descriptionLabel, view in
      monthLabel.top >= descriptionLabel.bottom + descriptionLabelPadding.bottom
      monthLabel.left == view.left + monthYearLabelsSidePadding
      yearLabel.baseline == monthLabel.baseline
      yearLabel.right == view.right - monthYearLabelsSidePadding
    }
    constrain(calendarView, calendarButton, monthLabel, descriptionLabel, self) {
      calendarView, calendarButton, monthLabel, descriptionLabel, view in
      calendarView.left == view.left + calendarViewPadding.left
      calendarView.right == view.right - calendarViewPadding.right
      calendarView.top == monthLabel.bottom + calendarViewPadding.top
      calendarView.bottom == calendarButton.bottom - calendarViewPadding.bottom
    }
    constrain(descriptionLabel, self) { descriptionLabel, view in
      descriptionLabel.top == view.top + descriptionLabelPadding.top
      descriptionLabel.left == view.left + descriptionLabelPadding.left
      descriptionLabel.right == view.right - descriptionLabelPadding.right
    }
    constrain(calendarButton, self) { calendarButton, view in
      calendarButton.bottom == view.bottom - calendarButtonPadding.bottom
      calendarButton.right == view.right - calendarButtonPadding.right
    }
  }
}

// MARK: - Calendar delegates

extension AchievementCell: CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate {
  func presentationMode() -> CalendarMode {
    return .MonthView
  }
  func firstWeekday() -> Weekday {
    return NSCalendar.currentCalendar().firstWeekday == 1 ? .Sunday : .Monday
  }
  func shouldAutoSelectDayOnMonthChange() -> Bool {
    return false
  }
  func presentedDateUpdated(date: Date) {
    let monthName = NSDateFormatter().monthSymbols[date.month - 1]
    yearLabel.text = "\(date.year)"
    monthLabel.text = monthName
  }

  func dayLabelWeekdayFont() -> UIFont {
    return .systemFontOfSize(20)
  }
  func dayLabelWeekdayInTextColor() -> UIColor {
    return .whiteColor()
  }
  
  func dayLabelWeekdaySelectedFont() -> UIFont {
    return dayLabelWeekdayFont()
  }
  func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
    return .whiteColor()
  }
  func dayLabelWeekdaySelectedBackgroundAlpha() -> CGFloat {
    return 0.44
  }
  
  func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
    return .whiteColor()
  }
  func dayLabelPresentWeekdayTextColor() -> UIColor {
    return .whiteColor()
  }
  func dayLabelPresentWeekdayFont() -> UIFont {
    return dayLabelWeekdayFont()
  }
  func dayLabelPresentWeekdayInitallyBold() -> Bool {
    return false
  }
  func dayLabelPresentWeekdayBorderColor() -> UIColor {
    return tintColor
  }
  func dayLabelPresentWeekdayBorderWidth() -> CGFloat {
    return 2
  }
  
  func didShowNextMonthView(date: NSDate) {
    reloadSelection()
  }
  func didShowPreviousMonthView(date: NSDate) {
    reloadSelection()
  }
  
  func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
    let dates = datesWithComments.map { $0.0 }
    if let index = dates.indexOf({ dayView.date.day == NSCalendar.currentCalendar().component(.Day, fromDate: $0) }) {
      descriptionLabel.text = datesWithComments[dates[index]]?.length > 0 ?
        datesWithComments[dates[index]] : "I can't remember what I did, but something has been done :)"
      descriptionLabel.updateTextFontSize(20, minFontSize: 13)
    }
  }
}