//
//  SidePanelViewController.swift
//  HomeDrawerPOC
//
//  Created by Pedro Blanc on 20/03/19.
//  Copyright © 2019 James Frost. All rights reserved.
//

import UIKit

class ContentWithTabView : UIView {
  private let tabImageView = UIImageView()
  private var contentViewController = UIViewController()
  
  private var tabSize = CGSize(width: 70, height: 50)
  var contentSize = CGSize(width: 160, height: 250)
  var tabWidth : CGFloat {
    get { return tabSize.width }
    set {
      tabSize.width = newValue
      recalculateFrameSize()
      self.setNeedsLayout()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    createViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    createViews()
  }
  
  func setContentSize(_ newSize : CGSize) {
    contentSize = newSize
    recalculateFrameSize()
    self.setNeedsLayout()
  }
  
  func setContentViewController(_ vc : UIViewController, parentVC: UIViewController) {
    contentViewController.willMove(toParentViewController: nil)
    contentViewController.view.removeFromSuperview()
    contentViewController.removeFromParentViewController()
    
    contentViewController = vc
    
    self.addSubview(contentViewController.view)
    parentVC.addChildViewController(vc)
    vc.didMove(toParentViewController: parentVC)
  }
  
  private func createViews() {
    if let tabImg = UIImage(named: "eco_menu") {
      tabImageView.image = tabImg
      tabImageView.bounds.size = tabSize
      tabImageView.backgroundColor = UIColor.green
    }
    
    contentViewController.view.backgroundColor = UIColor.red
    contentViewController.view.alpha = 0.8
    
    self.backgroundColor = UIColor.blue
    
    self.addSubview(contentViewController.view)
    self.addSubview(tabImageView)

    layoutSubviews()
  }
  
  override func layoutSubviews() {
    recalculateFrameSize()
    
    tabImageView.frame = CGRect(x: self.frame.width - tabSize.width,
                                y: contentSize.height/2 - tabSize.height/2,
                                width: tabSize.width,
                                height: tabSize.height )
    
    contentViewController.view.frame.size = contentSize
    contentViewController.view.frame.origin = CGPoint(x: 0, y: 0)
  }
  
  private func recalculateFrameSize() {
    self.frame = CGRect(x: self.frame.origin.x,
                        y: self.frame.origin.y,
                        width: contentSize.width + tabSize.width,
                        height: contentSize.height )
  }
}
