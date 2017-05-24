//
//  GoalActionButton.swift
//  Persimmon
//
//  Created by Binur Konarbayev on 3/10/16.
//  Copyright © 2016 Zero To One Labs. All rights reserved.
//

import UIKit

final class GoalActionButton: ImageAtTopButton {
  override var selected: Bool {
    didSet {
      super.selected = selected
      titleLabel?.font = selected ? .latoRegularOfSize(20) : .latoLightOfSize(20)
    }
  }
  
  override init(image: UIImage?, title: String?, imageAtTop: Bool) {
    super.init(image: image, title: title, imageAtTop: imageAtTop)
    
    setImage(UIImage(), forState: .Selected)
    titleLabel?.font = .latoLightOfSize(20)
    titleLabel?.textAlignment = .Center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = height / 2
  }
}