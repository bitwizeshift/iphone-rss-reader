//
//  ContainerViewController.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

class ContainerViewController: UIViewController {
    var centerNavigationController: UINavigationController!
    var centerViewController: MainTableViewController!
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var sideTableViewController: SideTableViewController?
    var rightTableViewController: RightTableViewController?
    let centerPanelExpandedOffset: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.mainTableViewController()
        centerViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

        // Do any additional setup after loading the view.
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: CenterViewController delegate
extension ContainerViewController: MainTableViewControllerDelegate {
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(notAlreadyExpanded)
    }
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        animateRightPanel(notAlreadyExpanded)
    }
    func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    func addLeftPanelViewController() {
        if (sideTableViewController == nil) {
            sideTableViewController = UIStoryboard.sideTableViewController()
            addChildSidePanelController(sideTableViewController!)
        }
    }
    func addRightPanelViewController() {
        if (rightTableViewController == nil) {
            rightTableViewController = UIStoryboard.rightTableViewController()
            addChildRightPanelController(rightTableViewController!)
        }
    }
    func addChildRightPanelController(rightTableViewController: RightTableViewController) {
        rightTableViewController.delegate = centerViewController
        view.insertSubview(rightTableViewController.view, atIndex: 0)
        
        addChildViewController(rightTableViewController)
        rightTableViewController.didMoveToParentViewController(self)
    }
    
    func addChildSidePanelController(sideTableViewController: SideTableViewController) {
        sideTableViewController.delegate = centerViewController
        view.insertSubview(sideTableViewController.view, atIndex: 0)
        
        addChildViewController(sideTableViewController)
        sideTableViewController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.currentState = .BothCollapsed
                self.sideTableViewController!.view.removeFromSuperview()
                self.sideTableViewController = nil;
            }
        }
    }
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .RightPanelExpanded
            animateCenterPanelXPosition(-CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.currentState = .BothCollapsed
                self.rightTableViewController!.view.removeFromSuperview()
                self.rightTableViewController = nil;
            }
        }
    }
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func sideTableViewController() -> SideTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SideTableViewController") as? SideTableViewController
    }
    
    class func rightTableViewController() -> RightTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RightTableViewController") as? RightTableViewController
    }
    
    class func mainTableViewController() -> MainTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainTableViewController") as? MainTableViewController
    }
}
