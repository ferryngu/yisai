//
//  YSLoginViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/10/10.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSLoginViewController: UIViewController,UITextFieldDelegate {

    var txf_telNumber: UITextField!
    var txf_pwd: UITextField!
    
    var role_type: String!
    var tips: FETips = FETips()
    var isLogin: Bool = false
    var button1:UIButton!
    var img_avatar:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "登录"
        
        tips.duration = 1
        
        self.view.backgroundColor = viewbackColor
        
        let imgWidth = SCREEN_WIDTH/4
        
        
         img_avatar = UIImageView(frame: CGRect(x: (SCREEN_WIDTH-imgWidth)/2, y: 40, width: imgWidth, height: imgWidth))
        
        
        img_avatar.userInteractionEnabled = true
        img_avatar.layer.cornerRadius = imgWidth / 2
        img_avatar.clipsToBounds = true
        
        
        
       // let image = UIImage(contentsOfFile: NSHomeDirectory() + "/Documents/Image/\(ysApplication.loginUser.uid)_avatar.png")
        
        
        img_avatar.image =  UIImage(named: "login_deflaut")
        
        self.view.addSubview(img_avatar)
        
        let nameview = UIView(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 90))
        nameview.backgroundColor = UIColor.whiteColor()
        nameview.layer.cornerRadius = 5;
        
        nameview.top = img_avatar.bottom + 40
        
        
        self.view.addSubview(nameview)
        
        
        
        txf_telNumber = UITextField(frame: CGRectMake(5,12.5,nameview.width-20,20))
        //设置边框样式为圆角矩形
        txf_telNumber.borderStyle = UITextBorderStyle.None
        txf_telNumber.placeholder="请输入手机号码"
        txf_telNumber.clearButtonMode =  UITextFieldViewMode.WhileEditing
        txf_telNumber.keyboardType = .NumberPad
        txf_telNumber.delegate = self
        txf_telNumber.addTarget(self,action:#selector(textFieldDidChange),forControlEvents:.EditingChanged)
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
        txf_pwd.placeholder="请输入新密码"
        nameview.addSubview(txf_pwd)
        
        
        
        
         button1 = UIButton(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 50))
        button1.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 0.4)
        button1.setTitle("登录", forState:.Normal)
        button1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
         button1.layer.cornerRadius = 5;
        button1.top = nameview.bottom + 25
        
        button1.addTarget(self,action:#selector(login),forControlEvents:.TouchUpInside)
        self.view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRect(x: 15, y: 20, width: 50, height: 20))
        button2.backgroundColor = UIColor.clearColor()
        button2.setTitle("注册", forState: .Normal)
        button2.setTitleColor(UIColor(netHex:0x37a4f5), forState: .Normal)
        button2.contentHorizontalAlignment = .Left;
       button2.addTarget(self,action:#selector(regist),forControlEvents:.TouchUpInside)
        button2.titleLabel?.font = UIFont.systemFontOfSize(15)
        button2.top = button1.bottom + 5
        button2.left = button1.left
        self.view.addSubview(button2)
        
        
        let button3 = UIButton(frame: CGRect(x: 15, y: 20, width:80, height: 20))
        button3.backgroundColor = UIColor.clearColor()
        button3.setTitle("找回密码", forState:.Normal)
        button3.setTitleColor(UIColor(netHex:0x37a4f5), forState: .Normal)
         button3.contentHorizontalAlignment = .Right;
         button3.titleLabel?.font = UIFont.systemFontOfSize(15)
        button3.top = button1.bottom + 5
        button3.right = button1.right
        
        button3.addTarget(self,action:#selector(forgetPassword),forControlEvents:.TouchUpInside)
        self.view.addSubview(button3)
        
        role_type = "1"
        
        let leftBarBtn:UIBarButtonItem = UIBarButtonItem(image:UIImage(named: "cs_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backToPrevious))
        leftBarBtn.tintColor = UIColor.whiteColor()
      //  self.navigationController!.hidesBottomBarWhenPushed = true
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        
        
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

    func login(sender: AnyObject) {
        
        if checkInputEmpty(txf_telNumber.text) {
            tips.showTipsInMainThread(Text: "请输入手机号码")
            return
        }

        
        if !checkTelNumber(txf_telNumber.text) {
            tips.showTipsInMainThread(Text:"输入的号码格式有误")
            return
        }
        
        
        
        if checkInputEmpty(txf_pwd.text) {
            tips.showTipsInMainThread(Text: "请输入密码")
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
               // ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
                
               self!.backToPrevious()
            })
        }
    }
    
    func forgetPassword(sender: AnyObject) {
        
        // 密码找回点击
        MobClick.event("find_passwd", attributes: ["role": role_type])
        
      /*  let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSFindPasswordViewController") as! YSFindPasswordViewController
        controller.role_type = role_type
        
        let navController = UINavigationController(rootViewController: controller)
        
        self.presentViewController(navController, animated: true, completion: nil)*/
        
        
        let controller =  YSFindBackViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func regist(sender: AnyObject)
    {
        let controller = YSRegistViewController()
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        if checkTelNumber(txf_telNumber.text) {
           // tips.showTipsInMainThread(Text:"输入的号码格式有误")
           // return
            button1.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 1)
            button1.tag = 1
            let str = txf_telNumber.text
            let imgpath = NSHomeDirectory() + "/Documents/Image/"+str!+"_avatar.png"
            print(imgpath)
             let image = UIImage(contentsOfFile: imgpath)
            if(image != nil)
            {
                 img_avatar.image = image
            }
            
        }
        else
        {
            button1.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 0.4)
             button1.tag = 0
        }

        
       
        
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
    }
    
    //返回按钮点击响应
    func backToPrevious(){
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        
        self.navigationController!.view.layer .addAnimation(transition, forKey: nil)
  
        self.navigationController?.popViewControllerAnimated(false)
        
        }
}
