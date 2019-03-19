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
    case bothCollapsed
    case leftPanelExpanded
  }
  
  var centerNavigationController: UINavigationController!
  var centerViewController: CenterViewController!
  
  var currentState: SlideOutState = .bothCollapsed
  var leftViewController: SidePanelViewController?
  
  let centerPanelExpandedOffset: CGFloat = 60
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    centerViewController = UIStoryboard.centerViewController()
    centerViewController.delegate = self
    
    centerNavigationController = UINavigationController(rootViewController: centerViewController)
    view.addSubview(centerNavigationController.view)
    addChildViewController(centerNavigationController)
    
    centerNavigationController.didMove(toParentViewController: self)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
  }
}

// MARK: CenterViewController delegate
extension ContainerViewController: CenterViewControllerDelegate {
  
  func toggleLeftPanel() {
    
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    
    if notAlreadyExpanded {
      addLeftPanelViewController()
    }
    
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
  
  func collapseSidePanels() {
    
    switch currentState {
    case .leftPanelExpanded:
      toggleLeftPanel()
    default:
      break
    }
  }
  
  func addLeftPanelViewController() {
    
    guard leftViewController == nil else { return }
    
    if let vc = UIStoryboard.leftViewController() {
      vc.animals = Animal.allCats()
      addChildSidePanelController(vc)
      leftViewController = vc
    }
  }
  
  func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
    sidePanelController.delegate = centerViewController
    view.insertSubview(sidePanelController.view, at: 0)
    
    addChildViewController(sidePanelController)
    sidePanelController.didMove(toParentViewController: self)
  }
  
  func animateLeftPanel(shouldExpand: Bool) {
    
    if shouldExpand {
      currentState = .leftPanelExpanded
//      if let leftVC = leftViewController {
//        leftVC.view.frame.origin.x = -leftVC.view.frame.width
//      }
      animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
    } else {
      
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .bothCollapsed
        self.leftViewController?.view.removeFromSuperview()
        self.leftViewController = nil
      }
    }
  }
  
  func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
    
    UIView.animate(withDuration: 1.0, delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0,
                   options: .curveEaseInOut,
                   animations: {
//                      let leftVC = self.leftViewController
//                      let leftWidth = leftVC?.view.bounds.width ?? 0
//                      leftVC?.view.frame.origin.x = targetPosition - leftWidth
                      self.centerNavigationController.view.frame.origin.x = targetPosition
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
      if currentState == .bothCollapsed {
        if gestureIsDraggingFromLeftToRight {
          addLeftPanelViewController()
        }
      }
      
    case .changed:
      if let rview = recognizer.view {
        let newCenter = rview.center.x + recognizer.translation(in: view).x
        rview.center.x = max(newCenter, rview.frame.width/2)
        recognizer.setTranslation(CGPoint.zero, in: view)
      }
      
    case .ended:
      if let _ = leftViewController,
        let rview = recognizer.view {
        // animate the side panel open or closed based on whether the view has moved more or less than halfway
        let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
        animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
        
      }
      
    default:
      break
    }
  }
}

private extension UIStoryboard {
  
  static func main() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> SidePanelViewController? {
    return main().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
  }
  
  static func centerViewController() -> CenterViewController? {
    return main().instantiateViewController(withIdentifier: "CenterViewController") as? CenterViewController
  }
}
