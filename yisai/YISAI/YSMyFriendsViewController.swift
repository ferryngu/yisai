//
//  YSMyFriendsViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/16.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyFriendsViewController: UIViewController {

    var currentController: YSMyFriendsMainViewController!
    var fansViewController: YSMyFriendsMainViewController!
    var concernViewController: YSMyFriendsMainViewController!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YSBudge.setConcerned("0")
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        configureContainerView()
        
//        navigationItem.titleView?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleWidth
//        navigationItem.titleView?.autoresizesSubviews = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.tintColor = UIColor.whiteColor()
        
//        navigationItem.titleView?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleWidth
//        navigationItem.titleView?.autoresizesSubviews = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureContainerView() {
        
        concernViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyFriendsMainViewController") as! YSMyFriendsMainViewController
        addChildViewController(concernViewController)
        concernViewController.view.frame = self.containerView.frame
        concernViewController.fetchFanType = 0
        concernViewController.fuid = ysApplication.loginUser.uid
        containerView.addSubview(concernViewController.view)
        currentController = concernViewController
        
        fansViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyFriendsMainViewController") as! YSMyFriendsMainViewController
        fansViewController.view.frame = self.view.frame
        fansViewController.fetchFanType = 1
        fansViewController.fuid = ysApplication.loginUser.uid
    }
    
    func fromController(oldController: UICollectionViewController, toController newController: UICollectionViewController) {
        
        addChildViewController(newController)
        transitionFromViewController(oldController, toViewController: newController, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil) { [weak self] (finished: Bool) -> Void in
            
            if finished {
                
                newController.didMoveToParentViewController(self)
                oldController.willMoveToParentViewController(nil)
                oldController.removeFromParentViewController()
                self!.currentController = newController as! YSMyFriendsMainViewController
//                self!.currentController.fetchCompetitionInfo(true)
            } else {
                self!.currentController = oldController as! YSMyFriendsMainViewController
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .Left {
            
            if currentController == fansViewController {
                return
            }
            
            fromController(currentController, toController: fansViewController)
        } else {
            
            if currentController == concernViewController {
                return
            }
            
            fromController(currentController, toController: concernViewController)
        }
    }
    
    @IBAction func changeSegment(sender: UISegmentedControl) {
        
        if currentController == fansViewController {
            
            fromController(currentController, toController: concernViewController)
        } else {
            
            fromController(currentController, toController: fansViewController)
        }
    }
}
