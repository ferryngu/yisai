//
//  YSHomeSelectViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/7.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSHomeSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    var role_type: Int! // 角色标识，1为普通用户，2为评委/老师
    var tips: FETips = FETips()
    var openID: String!
    var handleWechatTimes: Int = 0
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tips.duration = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.createImageWithColor(UIColor.clearColor()), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
            
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWechatAuth:", name: YSWechatAuthSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWechatRefuse:", name: YSWechatAuthRefuse, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWechatCancel:", name: YSWechatAuthCancel, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.createImageWithColor(UIColor(red: 241.0/255.0, green: 87.0/255.0, blue: 81.0/255.0, alpha: 1)), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        
        if self.openID != nil {
            self.openID = nil
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSWechatAuthSuccess, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSWechatAuthRefuse, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSWechatAuthCancel, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 6
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 44
        case 1:
            return 226
        case 2:
            return role_type == 3 ? 0.01 : 130
        case 3:
            return 130
        case 4:
            return 40
        default:
            return role_type == 3 ? 0.01 : 142
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectBlankCell", forIndexPath: indexPath) 
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectTopCell", forIndexPath: indexPath) 
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectImageCell", forIndexPath: indexPath) 
            
            if role_type == 3 {
                
                for subview in cell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                
                return cell
            }
            
            let img = cell.contentView.viewWithTag(11) as! UIImageView
            let btn_image = cell.contentView.viewWithTag(12) as! UIButton
            
            img.image = UIImage(named: "zc_weizhuce")
            
            btn_image.addTarget(self, action: "gotoRegister", forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectImageCell", forIndexPath: indexPath) 
            
            let img = cell.contentView.viewWithTag(11) as! UIImageView
            let btn_image = cell.contentView.viewWithTag(12) as! UIButton
            
            img.image = UIImage(named: "zc_yizhuce")
            
            btn_image.addTarget(self, action: "gotoLogin", forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectBlankCell", forIndexPath: indexPath) 
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSHomeSelectBottomCell", forIndexPath: indexPath)
            
            if role_type == 3 || !WXApi.isWXAppInstalled() {
                
                for subview in cell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                
                return cell
            }
            
            let btn_wechat = cell.contentView.viewWithTag(11) as! UIButton
            
            btn_wechat.addTarget(self, action: "gotoWechatLogin", forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
        }
        
        
    }
    
    func gotoWechatLogin() {
        
        if !WXApi.isWXAppInstalled() {
            tips.showTipsInMainThread(Text: "没有安装微信应用")
            return
        }
        
        MobClick.event("third_login", attributes: ["result": "success"])
        
        
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendReq(req)
    }
    
    func gotoRegister() {
        
        let registerController = self.storyboard?.instantiateViewControllerWithIdentifier("YSRegisterTableViewController") as! YSRegisterTableViewController
        registerController.role_type = "\(role_type)"
        if openID != nil {
            registerController.openID = openID
        }
        
        self.navigationController?.pushViewController(registerController, animated: true)
    }
    
    func gotoLogin() {
        
        let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("YSLoginTableViewController") as! YSLoginTableViewController
        loginController.role_type = "\(((role_type == 2 || role_type == 3) ? 2 : 1))"
        self.navigationController?.pushViewController(loginController, animated: true)
    }
    
    // MARK: - Notification
    
    func handleWechatAuth(notificaiton: NSNotification) {
        
        let authResp = notificaiton.object as? SendAuthResp
        
        let urlString = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx9d6366b49d066a38&secret=1d2dcf43ce1ea229872f75b9e5ca6b51&code=\(authResp!.code)&grant_type=authorization_code"
        let url = NSURL(string: urlString)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
//            let dataStr = String(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
            let data:NSData?
            do {
                let dataStr = try String(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
                data = dataStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if data != nil {
                    let dict:NSDictionary?
//                    let dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
                    do {
                        dict = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    }catch let error as NSError{
                        CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                        return
                    }
                    
                    
                    
                    if dict == nil {
                        self!.tips.showTipsInMainThread(Text: "微信登录信息错误")
                        return
                    }
                    
                    let errcode = dict!["errcode"] as? String
                    
                    if errcode != nil {
                        // 获取token错误
                        self!.tips.showTipsInMainThread(Text: "微信登录信息错误")
                        
                    } else {
                        
                        if self == nil {
                            return
                        }
                        
                        let openid = dict?["openid"] as? String
                        
                        if openid == nil {
                            return
                        }
                        
                        self!.openID = openid

                        YSLogin.loginByWechat("\(self!.role_type)", openid: openid!, finish_block: { (uid: String!, loginkey: String!, role_type: String!, errorMsg: String!) -> Void in
                            
                            if self == nil {
                                return
                            }
                            
                            if errorMsg != nil {
                                
                                if errorMsg == "获取数据失败" {
                                    
                                    // 登录失败
                                    MobClick.event("login", attributes: ["role": ysApplication.loginUser.role_type, "result": "failure"])
                                }
                                
                                if errorMsg == "1002" {
                                    self!.gotoRegister()
                                    return
                                }
                                
                                self!.tips.showTipsInMainThread(Text: errorMsg)
                                return
                            }
                            
                            self!.tips.showTipsInMainThread(Text: "登录成功")
                            
                            // 拉取配置信息
                            YSConfigure.fetchConf()
                            
                            // 登录成功
                            MobClick.event("login", attributes: ["role": self!.role_type, "result": "success"])
                            
                            UIApplication.sharedApplication().registerForRemoteNotifications()
                            
                            YSPersonalInfoViewController().fetchPersonalInfo()
                            
                            let user = YSLoginUser(uid: uid, loginKey: loginkey, role_type: role_type)
                            ysApplication.loginUser.setUser(user)
                            
                            delayCall(1.0, block: { () -> Void in
                                ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
                            })
                        })
                    }
                }
            })
        })
    }
    
    func handleWechatRefuse(notification: NSNotification) {
        tips.showTipsInMainThread(Text: "你拒绝了微信登录")
    }
    
    func handleWechatCancel(notification: NSNotification) {
        tips.showTipsInMainThread(Text: "已取消微信登录")
    }
}
