/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import QuartzCore

class ContainerViewController: UIViewController {
  
  enum SlideOutState {
    case collapsed
    case expanded
  }
  
  var centerNavigationController: UINavigationController!
  
  var centerViewController: PanelViewController!
  var sidePanelController: UIViewController?
  
  var currentState: SlideOutState = .collapsed
  
  let sidePanelRelativeWidth : CGFloat = 1.0
  let sidePanelCollapsedOffset : CGFloat = 20
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    self.view.addGestureRecognizer(panGestureRecognizer)
  }

  func setCenterViewController(_ vc : PanelViewController?) {
    if let vc = vc {
      centerViewController = vc
      centerViewController?.containerDelegate = self
      
      
      self.view.addSubview(vc.view)
      addChildViewController(centerViewController)
      vc.didMove(toParentViewController: self)
    }
  }
  
  func setSidePanelViewController(_ vc : PanelViewController?) {
    guard let vc = vc else { return }
    
    vc.containerDelegate = self
    
    view.addSubview(vc.view)
    addChildViewController(vc)
    vc.didMove(toParentViewController: self)
    
    let w = sidePanelRelativeWidth * vc.view.frame.width
    let h = vc.view.frame.height
    let x = -w + sidePanelCollapsedOffset
    let y = vc.view.frame.origin.y
    vc.view.frame = CGRect(x: x, y: y, width: w, height: h)
    vc.view.layoutIfNeeded()
    
    sidePanelController = vc
  }
}

// MARK: ContainerViewController delegate
extension ContainerViewController: ContainerViewControllerDelegate {
  func toggleSidePanel() {
    let notAlreadyExpanded = (currentState != .expanded)
    
    animateSidePanel(shouldExpand: notAlreadyExpanded)
  }
  
  func expandSidePanel() {
    if(currentState == .collapsed)  { toggleSidePanel() }
  }
  
  func collapseSidePanel() {
    if(currentState == .expanded)  { toggleSidePanel() }
  }
  
  func animateSidePanel(shouldExpand: Bool) {
    
    if shouldExpand {
      currentState = .expanded
      animateSidePanelXPosition(targetPosition: 0)
    } else {
      if let width = sidePanelController?.view.bounds.width {
        animateSidePanelXPosition(targetPosition: -width + sidePanelCollapsedOffset) { _ in
          self.currentState = .collapsed
        }
      }
    }
  }
  
  func animateSidePanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
    UIView.animate(withDuration: 0.3, delay: 0,
                   options: .curveEaseOut,
                   animations: {
                    if let vc = self.sidePanelController {
                      vc.view.frame.origin.x = targetPosition
                    }
    },
                   completion: completion)
  }
}

// MARK: Gesture recognizer
extension ContainerViewController: UIGestureRecognizerDelegate {
  
  @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    
    let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
    
    switch recognizer.state {
      
    case .began:
//      let prepareToExpand = (currentState == .collapsed) && gestureIsDraggingFromLeftToRight
//      if prepareToExpand {
//          addSidePanelViewController()
//      }
      break
      
    case .changed:
//      if let rview = recognizer.view {
//        let newCenter = rview.center.x + recognizer.translation(in: view).x
//        rview.center.x = max(newCenter, rview.frame.width/2)
//        recognizer.setTranslation(CGPoint.zero, in: view)
//      }
      break
      
    case .ended:
      if let _ = sidePanelController,
        let rview = recognizer.view {
        // animate the side panel open or closed based on whether the view has moved more or less than halfway
        let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
        animateSidePanel(shouldExpand: hasMovedGreaterThanHalfway)
      }
      
    default:
      break
    }
  }
}
