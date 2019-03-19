//
//  ContainerViewControllerDelegate.swift
//  HomeDrawerPOC
//
//  Created by Pedro Blanc on 19/03/19.
//  Copyright © 2019 James Frost. All rights reserved.
//

import Foundation

import UIKit

@objc
protocol ContainerViewControllerDelegate {
  @objc func toggleSidePanel()
  @objc func expandSidePanel()
  @objc func collapseSidePanel()
}


