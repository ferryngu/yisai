  //
//  AppDelegate.swift
//  YISAI
//
//  Created by Yufate on 15/5/20.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    var isFullScreen: Bool = false
    var launchOptions: [NSObject: AnyObject]!
    var pushNotify: [NSObject : AnyObject]!
    var deviceToken: NSData!
    var currentStates = true

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
//       --------------potatoes---------------
        let time: NSTimeInterval = 1.5
        let delay = dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
        
            print("1.5 秒后输出")
        }
        //-----------------------------------
        self.launchOptions = launchOptions
        
        let iosversion : NSString = UIDevice.currentDevice().systemVersion
        let f_ver = iosversion.floatValue
        
        if f_ver >= 80000 {
            
            let userSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
            
        }
        
        
        feCore = FECore()
        
        feCore.initFEApplication(AppDelegate: self, ClassName: NSStringFromClass(YSApplication.self))
        feCore.iOSApplication?.startApplication()
        
        // 推送反馈(app没有运行时，点击推送启动时)
        XGPush.handleLaunching(launchOptions, successCallback: handleRomoteNotifySuccessCallback, errorCallback: handleRomoteNotifyErrorCallback)
        
        gotoGuide()
        
//        handleRomoteNotification()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).currentStates = false
        NSNotificationCenter.defaultCenter().postNotificationName(YSApplicationDidEnterBackground, object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        (UIApplication.sharedApplication().delegate as! AppDelegate).currentStates = true
        XGPush.handleReceiveNotification(pushNotify, successCallback: nil, errorCallback: handleRomoteNotifyErrorCallback, completion: handleRomoteNotifySuccessCallback)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().postNotificationName(YSApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if isFullScreen {
            return UIInterfaceOrientationMask.AllButUpsideDown
        }
        
        return UIInterfaceOrientationMask.Portrait
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        self.deviceToken = deviceToken
        
        if ysApplication.loginUser.uid != nil {
            XGPush.setAccount(ysApplication.loginUser.uid)
        }
        
        let deviceTokenStr = XGPush.registerDevice(deviceToken)
        print("XGPush registerDevice" + deviceTokenStr)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        //推送反馈(app运行时)

        pushNotify = userInfo
        
        XGPush.handleReceiveNotification(userInfo)
        
        handleRemoteNotification(userInfo)
        
        NSNotificationCenter.defaultCenter().postNotificationName(YSApplicationDidReceiveRemoteNotification, object: nil, userInfo: userInfo)
        
        if !currentStates {
            jumpToAppointedPage(userInfo)
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).currentStates =  true
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        stopUploadMovie(nil)
        YSUserOnline.updateOnlineTime(1)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        // 支付宝支付回调
        AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic: [NSObject : AnyObject]!) -> Void in
            
            print("alipay result = ")
            print(resultDic)
        })
        
        // 微信支付回调
        WXApi.handleOpenURL(url, delegate: self)
        
        return UMSocialSnsService.handleOpenURL(url)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return UMSocialSnsService.handleOpenURL(url)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        // 支付宝支付回调
        AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic: [NSObject : AnyObject]!) -> Void in
            
            print("alipay result = ")
            print(resultDic)
        })
        
        // 微信支付回调
        WXApi.handleOpenURL(url, delegate: self)
        
        return true
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.sccp.YISAI" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("YISAI", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("YISAI.sqlite")
//        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            return coordinator
        }catch var error as NSError {
            coordinator = nil
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
            
        }

//        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
//            coordinator = nil
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
        
//        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
//            var error: NSError? = nil
//            if moc.hasChanges && !moc.save(&error) {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
//                abort()
//            }
            
            if moc.hasChanges {
                do {
                    try moc.save()
                }catch let error as NSError {
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
            }

        }
    }
    
    func gotoGuide() {
    
        /* detect the first launch */
        var isFirstLaunch: Bool? = NSUserDefaults.standardUserDefaults().objectForKey("FirstLaunch") as? Bool
        if isFirstLaunch == nil {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLaunch")
            isFirstLaunch = false
        }
        
        if !isFirstLaunch! {
            /* first launch */
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
//            let storyBoard = UIStoryboard(name: "YSGuide", bundle: nil)
//            let viewController = storyBoard.instantiateViewControllerWithIdentifier("YSGuideViewController") as! YSGuideViewController
            ysApplication.switchViewController(2)
        }
    }
    
    // MARK: - 推送处理
    
    private func handleRomoteNotifySuccessCallback() {
        
        let options = (UIApplication.sharedApplication().delegate as! AppDelegate).launchOptions
        
        if options == nil && pushNotify != nil {
            
            handleRemoteNotification(pushNotify!)
            return
        }
        
        if let remoteNotification = options![UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            
            handleRemoteNotification(remoteNotification)
        }
    }
    
    private func handleRomoteNotifyErrorCallback() {
        
    }
    
    private func handleRomoteNotification() {
        
        let options = (UIApplication.sharedApplication().delegate as! AppDelegate).launchOptions
        
        if options == nil {
            return
        }
        
        let remoteNotification = options![UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
        if remoteNotification != nil {
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).jumpToAppointedPage(remoteNotification! as! [NSObject : AnyObject])
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).currentStates =  true
        }
    }
    
    func jumpToAppointedPage(userInfo: [NSObject : AnyObject]) {
        
        ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
        ysApplication.tabbarController.selectedIndex = 2
        
        // 参赛状态/比赛开始/比赛排名发布更改
        let competition_join = userInfo["competition_join"] as? Int
        let competition_start = userInfo["competition_start"] as? Int
        let competition_score = userInfo["competition_score"] as? Int
        
        if (competition_join != nil && competition_join == 1) || (competition_start != nil && competition_start == 1) || (competition_score != nil && competition_score == 1) {
            ysApplication.mineViewController.gotoCompetitionJoined()
            return
        }
        
        // 学生绑定
        let new_student = userInfo["new_student"] as? Int
        
        if (new_student != nil && new_student == 1) {
            ysApplication.mineViewController.gotoMyStudents()
            return
        }
        
        // 主办方邀请
        let new_invitation = userInfo["new_invitation"] as? Int
        
        if (new_invitation != nil && new_invitation == 1) {
            ysApplication.mineViewController.gotoOrganization()
            return
        }
        
        // 收到作品评分通知/比赛评分开始/比赛评分结束
        let new_unscored_work = userInfo["new_unscored_work"] as? Int
        let competition_score_start = userInfo["competition_score_start"] as? Int
        let competition_score_end = userInfo["competition_score_end"] as? Int
        
        if (new_unscored_work != nil && new_unscored_work == 1) || (competition_score_start != nil && competition_score_start == 1) || (competition_score_end != nil && competition_score_end == 1) {
            ysApplication.mineViewController.gotoMarking()
            return
        }
        
        // 被其他用户关注
        let new_fans = userInfo["new_fans"] as? Int
        
        if (new_fans != nil && new_fans == 1) {
            ysApplication.mineViewController.gotoMyFriends()
            return
        }
        
        // 新私信
        let new_message = userInfo["new_message"] as? Int
        
        if (new_message != nil && new_message == 1) {
            ysApplication.mineViewController.gotoMyMessages()
            return
        }
    }
    
    func handleRemoteNotification(userInfo: [NSObject : AnyObject]) {

        // 参赛状态/比赛开始/比赛排名发布更改
        let competition_join = userInfo["competition_join"] as? Int
        let competition_start = userInfo["competition_start"] as? Int
        let competition_score = userInfo["competition_score"] as? Int
        
        if (competition_join != nil && competition_join == 1) || (competition_start != nil && competition_start == 1) || (competition_score != nil && competition_score == 1) {
            YSBudge.setEnterCompetition("1")
        }
        
        // 学生绑定
        let new_student = userInfo["new_student"] as? Int
        
        if (new_student != nil && new_student == 1) {
            YSBudge.setBindTutor("1")
        }
        
        // 主办方邀请
        let new_invitation = userInfo["new_invitation"] as? Int
        
        if (new_invitation != nil && new_invitation == 1) {
            YSBudge.setInstitutionInvitation("1")
        }
        
        // 收到作品评分通知/比赛评分开始/比赛评分结束
        let new_unscored_work = userInfo["new_unscored_work"] as? Int
        let competition_score_start = userInfo["competition_score_start"] as? Int
        let competition_score_end = userInfo["competition_score_end"] as? Int
        
        if (new_unscored_work != nil && new_unscored_work == 1) || (competition_score_start != nil && competition_score_start == 1) || (competition_score_end != nil && competition_score_end == 1) {
            YSBudge.setMarked("1")
        }
        
        // 被其他用户关注
        let new_fans = userInfo["new_fans"] as? Int
        
        if (new_fans != nil && new_fans == 1) {
            YSBudge.setConcerned("1")
        }
        
        // 新私信
        let new_message = userInfo["new_message"] as? Int
        
        if (new_message != nil && new_message == 1) {
            YSBudge.setReceivedMsg("1")
        }
        
        if ysApplication.mineViewController != nil {
            ysApplication.mineViewController.handleBudge()
        }
    }

    // MARK: - 支付回调
    
    // 微信支付回调
    func onResp(resp: BaseResp!) {
        
        if resp is PayResp {
            
            switch resp.errCode {
            case WXSuccess.rawValue:
                NSNotificationCenter.defaultCenter().postNotificationName(YSWechatPaySuccess, object: NSNumber(int: resp.errCode))
            default:
                NSNotificationCenter.defaultCenter().postNotificationName(YSWechatPayFailed, object: NSNumber(int: resp.errCode))
            }
            
        } else if resp is SendAuthResp {
            
            switch resp.errCode {
            case WXSuccess.rawValue:
                NSNotificationCenter.defaultCenter().postNotificationName(YSWechatAuthSuccess, object: resp as! SendAuthResp)
            case WXErrCodeAuthDeny.rawValue:
                NSNotificationCenter.defaultCenter().postNotificationName(YSWechatAuthRefuse, object: nil)
            case WXErrCodeUserCancel.rawValue:
                NSNotificationCenter.defaultCenter().postNotificationName(YSWechatAuthCancel, object: nil)
            default:
                break
            }
        }
    }
}

