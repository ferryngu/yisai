//
//  YSRegistSubmitViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/10/11.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSRegistSubmitViewController: UIViewController {
    
    var txf_telNumber: UITextField!
    var txf_pwd: UITextField!
    var txf_vcode: UITextField!
    var btn_sendVcode: UIButton!
    
    var role_type: String!
    var tips: FETips = FETips()
    var isLogin: Bool = false
    var imageName: String!
    var timer: NSTimer!
    var countNum: Int = 60
    var isRegister: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "注册"
        
        tips.duration = 1
        
        self.view.backgroundColor = viewbackColor
        
        let imgWidth = SCREEN_WIDTH/4
        
        
        let nameview = UIView(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 90))
        nameview.backgroundColor = UIColor.whiteColor()
        nameview.layer.cornerRadius = 5;
        
        nameview.top = 40
        
        
        self.view.addSubview(nameview)
        
        
        
        txf_telNumber = UITextField(frame: CGRectMake(5,12.5,nameview.width-20,20))
        //设置边框样式为圆角矩形
        txf_telNumber.borderStyle = UITextBorderStyle.None
        txf_telNumber.placeholder="请输入手机号码"
        txf_telNumber.clearButtonMode =  UITextFieldViewMode.WhileEditing
        txf_telNumber.keyboardType = .NumberPad
        nameview.addSubview(txf_telNumber)
        txf_telNumber.inputAccessoryView =   addCanel()
        let line = UIView(frame: CGRect(x: 0, y: 44.5, width: SCREEN_WIDTH-30, height:1))
        line.backgroundColor = viewbackColor
        nameview.addSubview(line)
        
        
        self.view.addSubview(nameview)
        
        txf_pwd = UITextField(frame: CGRectMake(5,57.5,nameview.width-20,20))
        //设置边框样式为圆角矩形
        txf_pwd.borderStyle = UITextBorderStyle.None
        txf_pwd.clearButtonMode =  UITextFieldViewMode.WhileEditing
        txf_pwd.secureTextEntry = true
         txf_pwd.inputAccessoryView =   addCanel()
        txf_pwd.placeholder="请设置密码(8-16位字符)"
        nameview.addSubview(txf_pwd)
        
        
        
        let bottom_view = UIView(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 45))
        bottom_view.backgroundColor = UIColor.whiteColor()
        bottom_view.layer.cornerRadius = 5;
        
        bottom_view.top = nameview.bottom + 40
        
        
        self.view.addSubview(bottom_view)
        
        txf_vcode = UITextField(frame: CGRectMake(5,12.5,nameview.width-130,20))
        //设置边框样式为圆角矩形
        txf_vcode.borderStyle = UITextBorderStyle.None
        txf_vcode.placeholder="请输入验证码"
        txf_vcode.clearButtonMode =  UITextFieldViewMode.WhileEditing
        txf_vcode.keyboardType = .NumberPad
        bottom_view.addSubview(txf_vcode)
        
        btn_sendVcode  = UIButton(frame: CGRect(x: 15, y: 4, width: 120, height: 37))
        btn_sendVcode.backgroundColor = UIColor.init(red: 68/255.0, green: 122/255.0, blue: 195/255.0, alpha: 1)
        btn_sendVcode.setTitle("获取验证码", forState:.Normal)
        btn_sendVcode.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn_sendVcode.right = bottom_view.width-10;
        btn_sendVcode.titleLabel?.font = UIFont.systemFontOfSize(15)
        btn_sendVcode.layer.cornerRadius = 5;
        btn_sendVcode.addTarget(self,action:#selector(sendVcode),forControlEvents:.TouchUpInside)
        bottom_view.addSubview(btn_sendVcode)
        txf_vcode.inputAccessoryView =   addCanel()
        

        

        
        
        let button1 = UIButton(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 50))
        button1.backgroundColor = UIColor.redColor()
        button1.setTitle("注册", forState:.Normal)
        button1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button1.layer.cornerRadius = 5;
        button1.top = bottom_view.bottom + 40
        
        button1.addTarget(self,action:#selector(Submit),forControlEvents:.TouchUpInside)
        
        self.view.addSubview(button1)

      /*  let  btn_agree = UIButton(frame: CGRectMake(SCREEN_WIDTH/2+25,0,20,20))
        btn_agree.backgroundColor = UIColor.clearColor()
        btn_agree.addTarget(self,action:#selector(agree),forControlEvents:.TouchUpInside)
        btn_agree.setBackgroundImage(UIImage(named: "agree_pro"), forState: UIControlState.Normal)
        self.view.addSubview(btn_agree)
        
        btn_agree.top = button1.bottom + 5
        btn_agree.left = button1.left
        */
        
        
        
        let button2 = UIButton(frame: CGRect(x: 15, y: 20, width: 140, height: 20))
        button2.backgroundColor = UIColor.clearColor()
        button2.setTitle("注册即表示您已同意", forState: .Normal)
        button2.setTitleColor(UIColor(netHex:0x9d9e9e), forState: .Normal)
        button2.contentHorizontalAlignment = .Left;
        button2.addTarget(self,action:#selector(agree),forControlEvents:.TouchUpInside)
        button2.titleLabel?.font = UIFont.systemFontOfSize(15)
        button2.top = button1.bottom + 5
        button2.left = button1.left
        self.view.addSubview(button2)
        
        
        let button3 = UIButton(frame: CGRect(x: 15, y: 20, width:125, height: 20))
        button3.backgroundColor = UIColor.clearColor()
        button3.setTitle("《易赛服务协议》", forState:.Normal)
        button3.setTitleColor(UIColor(netHex:0x747474), forState: .Normal)
        button3.contentHorizontalAlignment = .Right;
        button3.titleLabel?.font = UIFont.systemFontOfSize(15)
         button3.addTarget(self,action:#selector(tapProtocol),forControlEvents:.TouchUpInside)
        button3.top = button1.bottom + 5
        button3.left = button2.right
        self.view.addSubview(button3)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func Submit()
    {
        if checkInputEmpty(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "请输入手机号码")
            return
        }
        
        if checkInputEmpty(txf_pwd.text) {
            self.tips.showTipsInMainThread(Text: "请输入密码")
            return
        }
        
        if checkInputEmpty(txf_vcode.text) {
            self.tips.showTipsInMainThread(Text: "请输入验证码")
            return
        }
        
        if !checkTelNumber(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "输入的号码格式有误")
            return
        }
        
         gotoRegister()
        

    }
    
    func gotoRegister() {
        
        if isRegister {
            tips.showTipsInMainThread(Text: "正在注册...")
            return
        }
        
        isRegister = true
        
        YSRegister.register(phoneNum: txf_telNumber.text!, password: txf_pwd.text!, vcode: txf_vcode.text!, filename: "", username: "", role_type: role_type, openID: "", finish_block: { [weak self] (uid: String!, loginKey: String!, role_type: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.isRegister = false
                
                if errorMsg == "注册成功,登陆失败" {
                    
                    // 注册成功
                    MobClick.event("register", attributes: ["role": self!.role_type, "result": "success"])
                    
                    // 登录失败
                    MobClick.event("login", attributes: ["role": self!.role_type, "result": "failure"])
                    
                    if self!.navigationController != nil {
                        ysApplication.homeNavViewController.popToRootViewControllerAnimated(false)
                        
                        let registerController = self!.storyboard?.instantiateViewControllerWithIdentifier("YSRegisterTableViewController") as! YSRegisterTableViewController
                        registerController.role_type = "\(self!.role_type)"
                        ysApplication.homeNavViewController.pushViewController(registerController, animated: true)
                    }
                    return
                }
                
                if errorMsg == "获取数据失败" {
                    
                    // 注册失败
                    MobClick.event("register", attributes: ["role": self!.role_type, "result": "failure"])
                }
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            // 注册成功
            MobClick.event("register", attributes: ["role": self!.role_type, "result": "success"])
            
            self!.tips.showTipsInMainThread(Text: "登录成功")
            
            let user = YSLoginUser(uid: uid, loginKey: loginKey, role_type: role_type)
            ysApplication.loginUser.setUser(user)
            
            // 拉取配置信息
            YSConfigure.fetchConf()
            
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            /*self!.uploadAvatar()
            
            let controller = YSPersonalInfoViewController()
            controller.userOrJT = (role_type == "1" ? true : false)
            controller.fetchPersonalInfo()
            
            delayCall(1.0, block: { () -> Void in
                
                if self!.navigationController != nil {
                    self!.navigationController?.popToRootViewControllerAnimated(false)
                }
                ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
            })*/
            
          //  self!.navigationController?.popToViewController(viewController: UIViewController, animated: <#T##Bool#>)
            let navcount = self!.navigationController!.viewControllers.count
            
            let viewCtl = self!.navigationController?.viewControllers[navcount-4];
            
            self!.navigationController?.popToViewController(viewCtl!, animated: true)
            
            })
            
    }
    
    func reloadResendText(timer: NSTimer) {
        countNum -= 1
        if countNum == 0 {
            countNum = 60
            btn_sendVcode.enabled = true
            btn_sendVcode.setTitle("重新发送验证码", forState: .Normal)
            timer.invalidate()
            return
        }
        btn_sendVcode.setTitle("\(countNum)s后重新发送", forState: .Normal)
    }
    
    func sendVcode(sender: AnyObject) {
        
        if checkInputEmpty(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "请输入手机号码")
            return
        }
        
        if !checkTelNumber(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "输入的号码格式有误")
            return
        }
        
        btn_sendVcode.enabled = false
       
        
        
        MobClick.event("get_regist_code", attributes: ["result": "success"])
        
         timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(reloadResendText), userInfo: nil, repeats: true)
        
        
        YSRegister.getVerifyNum(phoneNum: txf_telNumber.text!, role_type: role_type) { [weak self] (vcode: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                self!.btn_sendVcode.enabled = true
                self!.btn_sendVcode.setTitle("发送验证码", forState: .Normal)
                self!.timer.invalidate()
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "发送成功!")
            
           
        }
    }
    func tapProtocol(sender: AnyObject) {
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
        controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/about/privacy_policy.html")
        controller.title_str = "易赛服务协议"
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func agree(sender: AnyObject)
    {
        
    }
    
    func addCanel()->UIToolbar
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.frame = CGRectMake(0,0,SCREEN_WIDTH,40)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let button =  UIButton(type:.Custom)
        button.frame=CGRectMake(2, 2, 50, 30)
        button.setTitle("完成", forState:UIControlState.Normal) //普通状态下的文字
        button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        button.backgroundColor = UIColor.redColor()
        button.layer.cornerRadius = 5
        button.addTarget(self,action:#selector(resignAllResponder),forControlEvents:.TouchUpInside)
        
        
        //继续创建按钮
        // let doneButton = UIBarButtonItem(title: "完成", style:UIBarButtonItemStyle.Plain, target:self, action:#selector(resignInput))
        
        let doneButton  = UIBarButtonItem(customView: button)
        
        
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        
        return toolBar
        
    }
    func resignAllResponder()
    {
        txf_telNumber.resignFirstResponder()
        txf_pwd.resignFirstResponder()
        txf_vcode.resignFirstResponder()
    }
}
