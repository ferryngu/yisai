//
//  FEViewControllerTransition.swift
//  FECore
//
//  Created by apps on 15/10/20.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation

import UIKit

public class FEViewControllerTransition {

    weak var containerView:UIView!

    weak var containerViewController:UIViewController!

    var currentViewController:UIViewController!

    var viewControllerDictionary: Dictionary<String,UIViewController>
    
    public var animaeDuration:NSTimeInterval

    public var animaeOptions:UIViewAnimationOptions
    
    public var animations:(() -> Void)!
    
    
    init(ContainerViewController:UIViewController,ContainerView:UIView) {

        viewControllerDictionary = Dictionary()
        
        self.containerViewController = ContainerViewController
        self.containerView = ContainerView
        
        animaeDuration = 1.0
        
        animaeOptions = UIViewAnimationOptions.TransitionNone
        
    }

    public func addViewController(controllerName:String,viewController:UIViewController) {

        containerViewController.addChildViewController(viewController)

        if 0 == viewControllerDictionary.count {
            viewController.view.frame = containerView.bounds
            containerView.addSubview(viewController.view)
            currentViewController = viewController
        }

        viewControllerDictionary[controllerName] = viewController
        
    }

    public func transition(controllerName:String)->Void {

        if 0 == viewControllerDictionary.count {
            return
        }

        let viewController:UIViewController! = viewControllerDictionary[controllerName]
        
        if nil == viewController {
            return
        }

        if currentViewController == viewController {
            return
        }

        viewController.view.frame = containerView.bounds

        containerViewController.transitionFromViewController(currentViewController, toViewController: viewController,
    
            duration:animaeDuration,
            options:animaeOptions,
            animations: animations,
            completion: {
                (finished:Bool) -> Void in

                if true != finished {
                    return
                }

                self.currentViewController = viewController

            }
    
        )

    }
    
    
}
