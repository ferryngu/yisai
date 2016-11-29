//
//  YSLoginTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSLoginTableViewController: UITableViewController {

    @IBOutlet weak var txf_telNumber: UITextField!
    @IBOutlet weak var txf_pwd: UITextField!
    
    var role_type: String!
    var tips: FETips = FETips()
    var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "登陆"
        
        tips.duration = 1
        
        tableView.sectionHeaderHeight = 16
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if checkInputEmpty(txf_telNumber.text) {
            tips.showTipsInMainThread(Text: "请输入手机号码")
            return
        }
        
        if checkInputEmpty(txf_pwd.text) {
            tips.showTipsInMainThread(Text: "请输入密码")
            return
        }
        
        if !checkTelNumber(txf_telNumber.text) {
            tips.showTipsInMainThread(Text:"输入的号码格式有误")
            return
        }
        
        tips.showTipsInMainThread(Text: "正在登录...")
        
        if isLogin {
            return
        }
        
        isLogin = true
        
        YSLogin.loginWithPhone(role_type, phoneNum: txf_telNumber.text!, password: txf_pwd.text!) { [weak self] (uid: String!, loginkey: String!, role_type: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.isLogin = false
                
                if errorMsg == "获取数据失败" {
                    
                    // 登录失败
                    MobClick.event("login", attributes: ["role": self!.role_type, "result": "failure"])
                }
                
                self!.tips.tipsViewlabel.text = errorMsg
                return
            }
            
            self!.tips.tipsViewlabel.text = "登录成功"
            
            // 登录成功
            MobClick.event("login", attributes: ["role": self!.role_type, "result": "success"])
            
            let user = YSLoginUser(uid: uid, loginKey: loginkey, role_type: role_type)
            ysApplication.loginUser.setUser(user)
            
            // 拉取配置信息
            YSConfigure.fetchConf()
            
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let controller = YSPersonalInfoViewController()
            controller.userOrJT = (role_type == "1" ? true : false)
            controller.fetchPersonalInfo()
            
            delayCall(1.0, block: { () -> Void in
                ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
            })
        }
    }
    
    @IBAction func forgetPassword(sender: AnyObject) {
        
        // 密码找回点击
        MobClick.event("find_passwd", attributes: ["role": role_type])
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSFindPasswordViewController") as! YSFindPasswordViewController
        controller.role_type = role_type
        
        let navController = UINavigationController(rootViewController: controller)
        
        self.presentViewController(navController, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 || indexPath.row == 1 {
            return 65.0
        } else {
            return 85.0
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }
}
