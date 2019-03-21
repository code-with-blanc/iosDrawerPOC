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
  
  var currentState: SlideOutState = .collapsed
  
  var centerViewController: PanelViewController!
  var sidePanelView: ContentWithTabView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sidePanelView = ContentWithTabView()
    sidePanelView.tabWidth = 30
    sidePanelView.setContentSize(UIScreen.main.bounds.size)
    view.addSubview(sidePanelView)
    
    moveSidePanelOutsideScreen()
    
    setupGestureRecognizers()
  }

  func moveSidePanelOutsideScreen() {
    let w = sidePanelView.frame.width
    let h = sidePanelView.frame.height
    let x = -w + sidePanelView.tabWidth
    let y = sidePanelView.frame.origin.y
    sidePanelView.frame = CGRect(x: x, y: y, width: w, height: h)
  }
  
  func setCenterViewController(_ vc : PanelViewController?) {
    if let vc = vc {
      centerViewController = vc
      centerViewController?.containerDelegate = self
      
      self.view.insertSubview(vc.view, at: 0)
      addChildViewController(centerViewController)
      vc.didMove(toParentViewController: self)
    }
  }
  
  func setSidePanelViewController(_ vc : PanelViewController?) {
    guard let vc = vc else { return }
    
    vc.containerDelegate = self
    
    sidePanelView.setContentViewController(vc, parentVC: self)
  }
  
  func setTabImage(_ img : UIImage?) {
    if let img = img {
      sidePanelView.setTabImage(img)
    }
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
      if let width = sidePanelView?.bounds.width {
        animateSidePanelXPosition(targetPosition: -width + sidePanelView.tabWidth) { _ in
          self.currentState = .collapsed
        }
      }
    }
  }
  
  func animateSidePanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
    UIView.animate(withDuration: 0.3, delay: 0,
                   options: .curveEaseOut,
                   animations: {
                    if let view = self.sidePanelView {
                      view.frame.origin.x = targetPosition
                    }
    },
                   completion: completion)
  }
}

// MARK: Pan Gesture recognizer
extension ContainerViewController: UIGestureRecognizerDelegate {
  private func setupGestureRecognizers() {
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(handlePanGesture(_:)) )
    sidePanelView.addGestureRecognizer(panGestureRecognizer)
    
    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(handleTapGesture))
    sidePanelView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state
    {
    case .changed:
      if currentState != .expanded {
        let translation = recognizer.translation(in: view).x
        let xCollapsed = -sidePanelView.contentWidth
        sidePanelView.frame.origin.x = xCollapsed + translation
      }
      break
      
    case .ended:
      let sidePanelEnd = sidePanelView.frame.origin.x + sidePanelView.frame.width
      let tabCenter = sidePanelEnd - sidePanelView.tabWidth
      let screenW = UIScreen.main.bounds.size.width
      let shouldExpand = (tabCenter > 0.15 * screenW)

      animateSidePanel(shouldExpand: shouldExpand)
      
    default:
      break
    }
  }
  
  @objc func handleTapGesture() {
    animateSidePanel(shouldExpand: true)
  }
}
