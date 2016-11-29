//
//  YSApplication.swift
//  YISAI
//
//  Created by Yufate on 15/5/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

let HOME_VIEWCONTROLLER = 0
let MAIN_VIEWCONTROLLER = 1
let GUIDE_VIEWCONTROLLER = 2

var ysApplication: YSApplication!

class YSApplication: NSObject, FEiOSApplication,UITabBarControllerDelegate{
   
    var feCore: FECore!
    var appDelegate: AppDelegate!
    var loginUser: YSLoginUser!
    var networkReachability: AFNetworkReachabilityManager!
    var uploadQueue: [MovieUploadManager]!
    var homeViewController: YSHomeViewController!
    var homeNavViewController: UINavigationController!
    var tabbarController: UITabBarController!
    var discoveryViewController: YSDiscoveryTableViewController!
    var competitionViewController: YSCompetitionViewController!
    var mineViewController: YSMineTableViewController!
    var guideViewController: YSGuideViewController!
    var backgroundID: UIBackgroundTaskIdentifier!
    
    var nav_discovery:UINavigationController!
    var nav_competition:UINavigationController!
    var nav_mine:UINavigationController!
    
    
    func initFEiOSApplication(Core feCore: FECore, AppDelegate appDelegate: AnyObject) {
        self.feCore = feCore
        self.appDelegate = appDelegate as! AppDelegate
        
        // 创建数据库
//        feInitAttrib()
        
        ysApplication = self
        
        // 创建上传队列
        initUploadQueue()
        
        // 接入的SDK配置
        configureThirdSDK()
        
        // 监听网络连接状态
        networkReachability = AFNetworkReachabilityManager.sharedManager()
        networkReachability.startMonitoring()
        networkReachability.setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(kYSNetworkStatus, object: nil, userInfo: ["status":"\(status.rawValue)"])
        }
    }
    
    /** 构建UI */
    func createUserInterface() {
        
        /* configure status bar */
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        /* configure navigationbar */
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage.createImageWithColor(UIColor(red: 241.0/255.0, green: 87.0/255.0, blue: 81.0/255.0, alpha: 1)), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        /* configure bar back item */
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(UIImage(named: "return_")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 1).resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)), forState: .Normal, barMetrics: .Default)
        
        /* configure tabbar item */
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 241.0/255.0, green: 87.0/255.0, blue: 81.0/255.0, alpha: 1.0)], forState: UIControlState.Selected)
        
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
        
        let loginStoryBoard = UIStoryboard(name: "YSLogin", bundle: nil)
        let discoveryStoryBoard = UIStoryboard(name: "YSDiscovery", bundle: nil)
        let competitionStoryBoard = UIStoryboard(name: "YSCompetition", bundle: nil)
        let mineStoryBoard = UIStoryboard(name: "YSMine", bundle: nil)
        let guideStoryBoard = UIStoryboard(name: "YSGuide", bundle: nil)
        
        homeViewController = loginStoryBoard.instantiateViewControllerWithIdentifier("YSHomeViewController") as! YSHomeViewController
        homeNavViewController = UINavigationController(rootViewController: homeViewController)
        
        discoveryViewController = discoveryStoryBoard.instantiateViewControllerWithIdentifier("YSDiscoveryTableViewController") as! YSDiscoveryTableViewController
        competitionViewController = competitionStoryBoard.instantiateViewControllerWithIdentifier("YSCompetitionViewController") as! YSCompetitionViewController
        mineViewController = mineStoryBoard.instantiateViewControllerWithIdentifier("YSMineTableViewController") as! YSMineTableViewController
       // mineViewController
        guideViewController = guideStoryBoard.instantiateViewControllerWithIdentifier("YSGuideViewController") as! YSGuideViewController
        
        tabbarController = UITabBarController()
        tabbarController.tabBar.layer.masksToBounds = true
        nav_discovery = UINavigationController(rootViewController: discoveryViewController)
         nav_competition = UINavigationController(rootViewController: competitionViewController)
         nav_mine = UINavigationController(rootViewController: mineViewController)
        
        
        tabbarController.delegate = self
        tabbarController.viewControllers = [nav_competition, nav_discovery, nav_mine]
       // tabbarController.delegate  = self
        for index in 0..<tabbarController.viewControllers!.count {
            
            switch index {
            case 0:
                let item = UITabBarItem(title: "比赛", image: UIImage(named: "fx_csh")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "fx_cs")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
                nav_competition.tabBarItem = item
            case 1:
                let item = UITabBarItem(title: "发现", image: UIImage(named: "fx_fxh")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "fx_fx")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
                nav_discovery.tabBarItem = item
            case 2:
                let item = UITabBarItem(title: "我的", image: UIImage(named: "fx_wdh")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "fx_wd")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
                nav_mine.tabBarItem = item
                nav_mine.tabBarItem.tag = 3
            default:
                break
            }
        }
        
        self.appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.appDelegate.window?.backgroundColor = UIColor.whiteColor()
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func startApplication() {
        
        if loginUser == nil {
            loginUser = YSLoginUser()
        }
        
        // 没有登录状态
      //  if !loginUser.getUser() {
            // 切换到登录首页
         //   self.switchViewController(HOME_VIEWCONTROLLER)
     //   }
       // else {
          //  loginUser.getUser()
        
        loginUser.getUser()
        
        self.switchViewController(MAIN_VIEWCONTROLLER)
        
       // }
        
      
    }
    
    /** 切换根视图 */
    func switchViewController(index: Int) {
        
        switch (index) {
        case HOME_VIEWCONTROLLER:
            
            homeNavViewController.popToRootViewControllerAnimated(false)
            
            self.appDelegate.window?.rootViewController = homeNavViewController
            
        case MAIN_VIEWCONTROLLER:
            
            if let deviceToken = (UIApplication.sharedApplication().delegate as! AppDelegate).deviceToken where !XGPush.isUnRegisterStatus() {
                    
                if let uid = ysApplication.loginUser.uid {
                    XGPush.setAccount(uid)
                }
                
                XGPush.registerDevice(deviceToken)
            }
            
            YSUserOnline.updateOnlineTime(nil)
            
            // 置顶全部导航页
            if tabbarController.viewControllers == nil {
                return
            }
            for controller in tabbarController.viewControllers! {
                
                let navController = controller as? UINavigationController
                if navController == nil {
                    continue
                }
                
                navController!.popToRootViewControllerAnimated(false)
            }
            tabbarController.selectedIndex = 0
            
            if self.mineViewController != nil {
                self.mineViewController.handleBudge()
            }
            
            self.appDelegate.window?.rootViewController = tabbarController
            
            
            
        case GUIDE_VIEWCONTROLLER:
            
            self.appDelegate.window?.rootViewController = guideViewController
            
        default:
            break
        }
    }
    
    func startService() {
        
    }
    
    func configureThirdSDK() {
        
        // 异常汇报
        CrashReporter.sharedInstance().installWithAppId("900017499")
        
        WXApi.registerApp("wx9d6366b49d066a38", withDescription: "易赛")
        
        /* umsocial share */
        UMSocialData.setAppKey(UMSocialAppKey)
        UMSocialWechatHandler.setWXAppId("wx9d6366b49d066a38", appSecret: "1d2dcf43ce1ea229872f75b9e5ca6b51", url: nil)
        UMSocialQQHandler.setQQWithAppId("1104738151", appKey: "6oDIWaJjObYUDTf6", url: "http://www.umeng.com/social")
        UMSocialSinaHandler.openSSOWithRedirectURL(nil)
        UMSocialConfig.hiddenNotInstallPlatforms([UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQzone, UMShareToSina, UMShareToQQ])
        
        // 友盟统计
        MobClick.startWithAppkey(UMSocialAppKey, reportPolicy: BATCH, channelId: "Web")
        let analyticsVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        MobClick.setAppVersion(analyticsVersion)
        MobClick.event("application_launch")
//        MobClick.setLogEnabled(true)

        // 腾讯信鸽
        XGPush.startApp(2200137777, appKey: "I57R542FYMCD")
        /* 注销之后需要再次注册前的准备 */
        let successCallback: () -> Void = { [weak self] in
            
            if self == nil {
                return
            }
            
            if !XGPush.isUnRegisterStatus() {
                
                self!.registerPush()
            }
        }
        XGPush.initForReregister(successCallback)
        
        /* 推送反馈回调 */
        let successBlock: () -> Void = {
            
        }
        
        let errorBlock: () -> Void = {
            
        }
        
        /* 角标清0 */
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        let options = (UIApplication.sharedApplication().delegate as! AppDelegate).launchOptions
        
        XGPush.handleLaunching(options, successCallback: successBlock, errorCallback: errorBlock)
    }
    
    private func registerPush() {
        
        // 腾讯信鸽
//        let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title = "Accept"
        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground
        acceptAction.destructive = false
        acceptAction.authenticationRequired = false
        
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier = "INVITE_CATEGORY"
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories = [inviteCategory] as Set<UIMutableUserNotificationCategory>
        
        let mySettings = UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert], categories: categories)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool  {
       // NSLog("tabbar item 被点击")
        if( viewController.tabBarItem.tag == 3)
        {
            // 没有登录状态
            if !loginUser.getUser() {
                // 切换到登录首页
              //  self.switchViewController(HOME_VIEWCONTROLLER)
                let controller = YSLoginViewController()
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionMoveIn;
                transition.subtype = kCATransitionFromTop;
                
                
               let nav =   tabBarController.selectedViewController! as! UINavigationController
                nav.view.layer.addAnimation(transition, forKey: nil)
                controller.hidesBottomBarWhenPushed = true
                nav.pushViewController(controller, animated: false)
                
                
                return false
            }
        }
        
        return true
        
    }
    
}
