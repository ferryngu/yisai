//
//  YSRegisterTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary

class YSRegisterTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var img_loginImg: UIImageView!
    @IBOutlet weak var txf_telNumber: UITextField!
    @IBOutlet weak var txf_pwd: UITextField!
    @IBOutlet weak var txf_userName: UITextField!
    @IBOutlet weak var txf_vcode: UITextField!
    @IBOutlet weak var btn_sendVcode: UIButton!
    @IBOutlet weak var img_noImage: UIImageView!
    @IBOutlet weak var lab_noImage: UILabel!
    
    var role_type: String!
    var imageName: String!
    var tips: FETips = FETips()
//    var vcode: String!
    var timer: NSTimer!
    var countNum: Int = 60
    var isRegister: Bool = false
    var uploadManager: MovieUploadManager!
    var openID: String!
    
    var avatarPath: String!
    
    deinit {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "注册"
        
        tips.duration = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        img_loginImg.layer.cornerRadius = (110.0 * SCREEN_WIDTH / 320.0 - 32.0) / 2
        
        if openID != nil {
            self.title = "资料补充"
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoRegister() {
        
        if isRegister {
            tips.showTipsInMainThread(Text: "正在注册...")
            return
        }
        
        isRegister = true
        
        YSRegister.register(phoneNum: txf_telNumber.text!, password: txf_pwd.text!, vcode: txf_vcode.text!, filename: imageName, username: txf_userName.text!, role_type: role_type, openID: openID, finish_block: { [weak self] (uid: String!, loginKey: String!, role_type: String!, errorMsg: String!) -> Void in
            
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
            
            self!.uploadAvatar()
            
            let controller = YSPersonalInfoViewController()
            controller.userOrJT = (role_type == "1" ? true : false)
            controller.fetchPersonalInfo()
            
            delayCall(1.0, block: { () -> Void in
                
                if self!.navigationController != nil {
                    self!.navigationController?.popToRootViewControllerAnimated(false)
                }
                ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
            })
        })
    }
    
    func reloadResendText(timer: NSTimer) {
        --countNum
        if countNum == 0 {
            countNum = 30
            btn_sendVcode.enabled = true
            btn_sendVcode.setTitle("重新发送验证码", forState: .Normal)
            timer.invalidate()
            return
        }
        btn_sendVcode.setTitle("\(countNum)s后重新发送", forState: .Normal)
    }
    
    func uploadAvatar() {
        
        let tImageName = imageName
        let tAvatarPath = avatarPath
        let tRole_type = role_type
        
        uploadManager = MovieUploadManager(key: tImageName, movieOrImage: 0, status: 2)
        uploadManager.getUploadToken({ [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.uploadManager.uploadWithProgress(nil, completionBlock: { (resp: QNResponseInfo!, key: String!, info: [NSObject : AnyObject]!) -> Void in
                
                if resp.ok {
                    
                    NSData(contentsOfFile: tAvatarPath)?.writeToFile(MovieFilesManager.getUserLocalAvatarPath()!, atomically: true)
                    
                    YSAvatar.updateAvatar(tRole_type != "1" ? false : true, fileName: tImageName, respBlock: { (errorMsg: String!) -> Void in
                        
                        if errorMsg != nil {
                            self!.tips.showTipsInMainThread(Text: errorMsg)
                            return
                        }
                    })
                }
            })
        })
    }
    
    // MARK: - Actions
    
    @IBAction func tapProtocol(sender: AnyObject) {
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
        controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/about/privacy_policy.html")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancelInput(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func setPhoto(sender: AnyObject) {
        let camera_action = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePickerController:UIImagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let photoLib_action = UIAlertAction(title: "从相册中提取", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePickerController:UIImagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction!) -> Void in
            
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(camera_action)
        alertController.addAction(photoLib_action)
        alertController.addAction(cancelAction)
        
        if isUsingiPad() {
            
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.frame
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendVcode(sender: AnyObject) {
        
        if checkInputEmpty(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "请输入手机号码")
            return
        }
        
        if !checkTelNumber(txf_telNumber.text) {
            self.tips.showTipsInMainThread(Text: "输入的号码格式有误")
            return
        }
        
        btn_sendVcode.enabled = false
        countNum = 30
        
        
        MobClick.event("get_regist_code", attributes: ["result": "success"])
        
        
        YSRegister.getVerifyNum(phoneNum: txf_telNumber.text!, role_type: role_type) { [weak self] (vcode: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "发送成功!")
            
            self!.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self!, selector: "reloadResendText:", userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func commit(sender: AnyObject) {
        
        if self.img_loginImg.image == nil || imageName == nil {
            self.tips.showTipsInMainThread(Text: "请设置注册头像")
            return
        }
        
        if checkInputEmpty(txf_userName.text) {
            self.tips.showTipsInMainThread(Text: "请输入用户名")
            return
        }
        
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
        
//        if txf_vcode.text != vcode {
//            self.tips.showTipsInMainThread(self.navigationController!, Text: "输入的验证码错误")
//            return
//        }
        
//        tips.showActivityIndicatorViewInMainThread("正在注册中...")
        
        gotoRegister()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 6
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 110.0 * SCREEN_WIDTH / 320.0
        case 1, 2, 3, 4:
            return 65.0
        default:
            return 90.0
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        var newImage: UIImage? = nil
        
        UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
        let thumbnailRect: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        image.drawInRect(thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        var error: NSError?
        if !NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Documents/Image") {
//            NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Image", withIntermediateDirectories: true, attributes: nil, error: nil)
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Image", withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }

            
        }
        
        imageName = "\(Int64(NSDate().timeIntervalSince1970 * 1000.0))_avatar.png"
        avatarPath = NSHomeDirectory() + "/Documents/Image/" + imageName
        let imageData = UIImagePNGRepresentation(newImage!)
        imageData!.writeToFile(avatarPath, atomically: true)
        
        img_loginImg.image = newImage
        img_noImage.hidden = true
        lab_noImage.hidden = true
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        
//    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
