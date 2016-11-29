//
//  FECore.swift
//  ch74
//
//  Created by xyz on 14/7/5.
//  Copyright (c) 2014年 apps. All rights reserved.
//

import UIKit

var feCore:FECore!;

@objc protocol FEiOSApplication {

    func initFEiOSApplication(Core feCore:FECore, AppDelegate appDelegate:AnyObject)->();

    func createUserInterface()->();

    func startApplication()->();

    func switchViewController(index:Int);
    
    func startService();

}

class FECore: NSObject {
    
    var iOSApplication:FEiOSApplication?;

    var viewControllerDictionary: NSMutableDictionary?;

    var appDelegate:UIApplicationDelegate!;

    //用于底层任意位置操作当前的view，显示时把当前 ViewController 保存在这里，退出是设置为 nil
    var currentViewController:UIViewController!
    
    func initFEApplication(AppDelegate appDelegate:AnyObject, ClassName className:String)->()
    {

        initFEiOSMiscSwift();

        viewControllerDictionary = NSMutableDictionary();
        
        let FEiOSApplicationClass = NSClassFromString(className) as? NSObject.Type
        
        iOSApplication = FEiOSApplicationClass!.init() as? FEiOSApplication
        
        iOSApplication?.initFEiOSApplication(Core: self, AppDelegate: appDelegate)
        
        self.appDelegate = appDelegate as! UIApplicationDelegate;
        
        currentViewController = nil;
        
        iOSApplication?.createUserInterface();
    }

    func regStaticViewController(ViewController viewController:AnyObject, name:String)
    {
    
        viewControllerDictionary?.setObject(viewController, forKey: name)
    }

    func getStaticViewController(name:String) ->(AnyObject)
    {
        return viewControllerDictionary?.valueForKey(name) as AnyObject!;
    }


    func pushStaticViewControllerWithTabBar(TabBarIndex tabBarIndex:Int, name:String)
    {

        let uiViewController:UIViewController! = viewControllerDictionary?.valueForKey(name) as! UIViewController!;
        pushStaticViewControllerWithTabBar(tabBarIndex, ViewController:uiViewController);

    }

    func pushStaticViewControllerWithTabBar(tabBarIndex:Int, ViewController uiViewController:UIViewController!)
    {

        if ( nil==uiViewController )
        {
            return;
        }

        let uiTabBarController:UITabBarController = appDelegate?.window??.rootViewController as! UITabBarController;
        
        let uiNavigationController:UINavigationController? = uiTabBarController.viewControllers?[tabBarIndex] as? UINavigationController;
        
        uiNavigationController?.popToRootViewControllerAnimated(true)
        
        uiNavigationController?.pushViewController(uiViewController!, animated: true)
        
        uiTabBarController.selectedIndex = tabBarIndex;
    
    }

    func setTabarInMainThread( tabBarIndex:Int )
    {
        
        if !(self.appDelegate?.window??.rootViewController is UITabBarController )
        {
            return;
        }
        
        let uiTabBarController:UITabBarController = self.appDelegate?.window??.rootViewController as! UITabBarController;
        
        if ( uiTabBarController.tabBar.items?.count<tabBarIndex )
        {
            return;
        }
        
        dispatch_async (
            dispatch_get_main_queue(),
            {
                uiTabBarController.selectedIndex = tabBarIndex;
            }
        )
        
    }

    func setTabarbadgeInMainThread( tabarIdx:Int, badge:String )
    {
        
        if !(self.appDelegate?.window??.rootViewController is UITabBarController )
        {
            return;
        }
        
        let uiTabBarController:UITabBarController = self.appDelegate?.window??.rootViewController as! UITabBarController;
        
        if ( uiTabBarController.tabBar.items?.count<tabarIdx )
        {
            return;
        }
        
        let uiTabBarItem:UITabBarItem = uiTabBarController.tabBar.items![tabarIdx]

        dispatch_async (
            dispatch_get_main_queue(),
            {
                uiTabBarItem.badgeValue = badge;
            }
        )
        
    }

    func getStaticiOSApplication()->FEiOSApplication?
    {
        return iOSApplication;
    }

    class func getStaticFEcore()->FECore?
    {
        return feCore;
    }

}
