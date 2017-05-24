//
//  ImageAtTopButton.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 2/11/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

class ImageAtTopButton: UIButton {
  private let distanceBetweenTitleAndImage: CGFloat = 10
  var imageAtTop = true
  
  init(image: UIImage?, title: String?, imageAtTop: Bool) {
    super.init(frame: .zero)
    
    if let image = image { setImage(image, forState: .Normal) }
    if let title = title { setTitle(title, forState: .Normal) }
    
    self.imageAtTop = imageAtTop
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
    let rect = super.titleRectForContentRect(contentRect)
    let y = imageAtTop ? contentRect.height - rect.height : 0
    
    return CGRect(x: 0, y: y, width: contentRect.width, height: rect.height)
  }
  
  override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
    let imageRect = super.imageRectForContentRect(contentRect)
    let titleRect = titleRectForContentRect(contentRect)
    let x = (contentRect.width - imageRect.width) / 2
    let y: CGFloat = imageAtTop ? 0 : contentRect.height - titleRect.height
    return CGRect(origin: CGPoint(x: x, y: y), size: imageRect.size)
  }
  
  override func intrinsicContentSize() -> CGSize {
    let size = super.intrinsicContentSize()
    guard let image = imageView?.image else { return size }
    let labelHeight = titleLabel?.sizeThatFits(CGSize(width: contentRectForBounds(bounds).width,
      height: .max)).height ?? 0
    
    return CGSize(width: size.width, height: image.size.height + labelHeight)
  }
}