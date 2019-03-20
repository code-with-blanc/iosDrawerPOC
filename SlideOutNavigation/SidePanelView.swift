//
//  SidePanelViewController.swift
//  HomeDrawerPOC
//
//  Created by Pedro Blanc on 20/03/19.
//  Copyright © 2019 James Frost. All rights reserved.
//

import UIKit

class SidePanelView : UIView {
  private let tabImageView = UIImageView()
  private var contentViewController = UIViewController()
  
  private var contentSize = CGSize(width: 0, height: 0)
  private var tabSize = CGSize(width: 40, height: 50)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    createViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    createViews()
  }
  
  func createViews() {
    if let tabImg = UIImage(named: "eco_menu") {
      tabImageView.image = tabImg
      tabImageView.bounds.size = tabSize
      tabImageView.backgroundColor = UIColor.green
    }
    
    contentViewController.view.backgroundColor = UIColor.red
    contentViewController.view.alpha = 0.6
    contentSize = CGSize(width: 100, height: 300)
    
    self.backgroundColor = UIColor.blue
    
    self.addSubview(contentViewController.view)
    self.addSubview(tabImageView)
  }
  
  override func layoutSubviews() {
    let origin = self.frame.origin
    let tabSize = tabImageView.frame.size
    
    self.frame = CGRect(x: origin.x,
                        y: 100,
                        width: contentSize.width + tabSize.width,
                        height: contentSize.height )
    
    tabImageView.frame = CGRect(x: self.frame.maxX - tabSize.width,
                                y: contentSize.height/2 - tabSize.height/2,
                                width: tabSize.width,
                                height: tabSize.height )
    
    contentViewController.view.frame.size = contentSize
    contentViewController.view.frame.origin = CGPoint(x: 0, y: 0)
  }
}
