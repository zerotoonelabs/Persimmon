//
//  CardsCollectionViewLayout.swift
//  Persimmon
//
//  Created by Ayan Yenbekbay on 11/8/15.
//  Copyright © 2015 Zero To One Labs. All rights reserved.
//

import UIKit

enum CardsCollectionViewLayoutType: Int {
  case Horizontal, Vertical
}

final class CardsCollectionViewLayout: UICollectionViewLayout {
  typealias LayoutInfoType = [NSIndexPath: UICollectionViewLayoutAttributes]
  var layoutType: CardsCollectionViewLayoutType {
    didSet { self.invalidateLayout() }
  }
  private var verticalLayout: Bool {
    return layoutType == .Vertical
  }
  private var layoutInfo: LayoutInfoType?
  private var offset: UIOffset {
    didSet { self.invalidateLayout() }
  }
  private var cardWidth: CGFloat {
    return collectionView.flatMap {
      UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ?
        $0.width / 2 - offset.horizontal * 2 : $0.width - offset.horizontal * 2
    } ?? 0
  }
  private var cardHeight: CGFloat {
    return collectionView.flatMap { $0.height } ?? 0
  }
  private var pageWidth: CGFloat {
    return cardWidth + offset.horizontal
  }
  private var pageHeight: CGFloat {
    return cardHeight + offset.vertical / 2
  }
  private let flickVelocity: CGFloat = 0.3

  // MARK: - Initialization

  convenience override init() {
    self.init(layoutType: CardsCollectionViewLayoutType.Horizontal, offset: UIOffsetZero)
  }

  convenience init(_ offset: UIOffset) {
    self.init(layoutType: CardsCollectionViewLayoutType.Horizontal, offset: offset)
  }

  convenience init(_ layoutType: CardsCollectionViewLayoutType) {
    self.init(layoutType: layoutType, offset: UIOffsetZero)
  }

  init(layoutType: CardsCollectionViewLayoutType, offset: UIOffset) {
    self.layoutType = layoutType
    self.offset = offset
    
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionViewLayout

  override func prepareLayout() {
    guard let collectionView = collectionView else { return }
    if collectionView.numberOfSections() == 0 { return }
    
    layoutInfo = [Int](0..<collectionView.numberOfItemsInSection(0)).map {
      return NSIndexPath(forItem: $0, inSection: 0)
    }.map {
      return [$0: attributesForCard($0)]
    }.reduce(LayoutInfoType()) {
      var result = LayoutInfoType()
      for dict in [$0, $1] {
        guard let dict = dict else { continue }
        for (key, value) in dict {
          result[key] = value
        }
      }
      return result
    }
  }

  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
      -> UICollectionViewLayoutAttributes? {
    return layoutInfo.flatMap { $0[indexPath] }
  }

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return layoutInfo.flatMap { Array($0.values) }
  }

  override func collectionViewContentSize() -> CGSize {
    guard let collectionView = collectionView else { return .zero }
    if collectionView.numberOfSections() == 0 { return collectionView.size }
    
    return CGSize(
      width: verticalLayout ? collectionView.width :
        (pageWidth * CGFloat(collectionView.numberOfItemsInSection(0)) + offset.horizontal * 1.5),
      height: verticalLayout ? (pageHeight * CGFloat(collectionView.numberOfItemsInSection(0)) + offset.vertical)
                     : collectionView.height
    )
  }

  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
      withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else { return proposedContentOffset }

    let rawPageValue = verticalLayout ? (collectionView.contentOffset.y / pageHeight)
                                      : (collectionView.contentOffset.x / pageWidth)
    let velocityValue = verticalLayout ? velocity.y : velocity.x
    let currentPage = velocityValue > 0 ? Int(floor(rawPageValue)) : Int(ceil(rawPageValue))
    let nextPage = velocityValue > 0 ? Int(ceil(rawPageValue)) : Int(floor(rawPageValue))
    let flicked = fabs(1 + CGFloat(currentPage) - rawPageValue) > 0.5 && fabs(velocityValue) > flickVelocity

    var proposedContentOffset = proposedContentOffset
    if verticalLayout {
      if flicked {
        proposedContentOffset.y = CGFloat(nextPage) * pageHeight
        if nextPage < collectionView.numberOfItemsInSection(0) {
          proposedContentOffset.y = max(proposedContentOffset.y - offset.vertical / 2, 0)
        }
      } else {
        proposedContentOffset.y = max(0, round(rawPageValue) * pageHeight - offset.vertical / 2)
      }
    } else {
      if flicked {
        proposedContentOffset.x = CGFloat(nextPage) * pageWidth
      } else {
        proposedContentOffset.x = max(0, round(rawPageValue) * pageWidth)
      }
    }

    return proposedContentOffset
  }

  // MARK: - Helpers

  private func attributesForCard(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
    let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
    
    let horizontalOffset = verticalLayout ? offset.horizontal
                                          : (offset.horizontal + pageWidth * CGFloat(indexPath.row))
    let verticalOffset = verticalLayout ? (offset.vertical + pageHeight * CGFloat(indexPath.row))
                                        : offset.vertical

    itemAttributes.frame = CGRectMake(horizontalOffset, verticalOffset, cardWidth, cardHeight)
    return itemAttributes
  }
  
}