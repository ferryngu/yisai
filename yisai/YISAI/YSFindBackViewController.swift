//
//  YSFindBackViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/10/12.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSFindBackViewController: UIViewController {
    
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
        
        self.title = "找回密码"
        
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
         txf_telNumber.inputAccessoryView =   addCanel()
        nameview.addSubview(txf_telNumber)
        
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
        txf_pwd.placeholder="请设置新密码(8-16位字符)"
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
         txf_vcode.inputAccessoryView =   addCanel()
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
        
        
        
        
        
        
        
        let button1 = UIButton(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 50))
        button1.backgroundColor = UIColor.redColor()
        button1.setTitle("提交", forState:.Normal)
        button1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button1.layer.cornerRadius = 5;
        button1.top = bottom_view.bottom + 40
        
        button1.addTarget(self,action:#selector(Submit),forControlEvents:.TouchUpInside)
        
        self.view.addSubview(button1)
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
        countNum = 60
        
        
        MobClick.event("get_regist_code", attributes: ["result": "success"])
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(reloadResendText), userInfo: nil, repeats: true)
        
        
        YSLogin.doVcode(phoneNum: txf_telNumber.text!) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
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
        
        
        YSLogin.resetPasswd("", phoneNum: txf_telNumber.text!, password: txf_pwd.text!, vCode: txf_vcode.text!) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "密码修改成功")
            
            delayCall(1.0, block: { () -> Void in
                
                //self!.dismissViewControllerAnimated(true, completion: nil)
                self!.navigationController?.popViewControllerAnimated(true)
            })
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
        txf_vcode.resignFirstResponder()
    }
    
    
}
