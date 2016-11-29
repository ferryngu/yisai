//
//  YSPersonalInfoViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/9.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSPersonalInfoViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YSCustomDatePickerDelegate {
    
    @IBOutlet weak var barRightItem: UIBarButtonItem!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var avatarPath: String! = MovieFilesManager.getUserLocalAvatarPath()
    var personalInfo: YSPernalInfo!
    var tips: FETips = FETips()
    var userOrJT: Bool! // 用户(true)或评委/老师(false)
    var uploadManager: MovieUploadManager!
    var pickerController: YSCustomDatePickerViewController!
    var shouldEditing: Bool = false
    var isConfirm: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        fetchPersonalInfo()
        
        pickerController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomDatePickerViewController") as! YSCustomDatePickerViewController
        pickerController.delegate = self
        self.view.addSubview(pickerController.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    
    func fetchPersonalInfo() {
        
        if userOrJT == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSPernalInfo.getUserInfo(userOrJT) { [weak self] (pernalInfo: YSPernalInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.personalInfo = pernalInfo
            
            if self!.personalInfo.username != nil {
                ysApplication.loginUser.setUserNickName(self!.personalInfo.username)
            }
            if self!.personalInfo.realname != nil {
                ysApplication.loginUser.setUserRealName(self!.personalInfo.realname)
            }
            if self!.personalInfo.birth != nil {
                ysApplication.loginUser.setUserBirth(self!.personalInfo.birth)
            }
            if self!.personalInfo.sex != nil {
                ysApplication.loginUser.setUserSex(self!.personalInfo.sex)
            }
            if self!.personalInfo.identity_card != nil {
                ysApplication.loginUser.setUserIDCard(self!.personalInfo.identity_card)
            }
            if self!.personalInfo.region != nil {
                ysApplication.loginUser.setUserRegion(self!.personalInfo.region)
            }
            if self!.personalInfo.phone != nil {
                ysApplication.loginUser.setUserTel(self!.personalInfo.phone)
            }
            self!.tableView.reloadData()
        }
    }
    
    // MARK: - Actions 
    
    @IBAction func updateUserInfo() {
        
        if userOrJT == nil {
            return
        }
        
        if !shouldEditing && isConfirm {
            tips.showTipsInMainThread(Text: "正在提交资料")
            return
        }
        
        shouldEditing = !shouldEditing
        
        if shouldEditing {
            tableView.userInteractionEnabled = true
            self.navigationItem.rightBarButtonItem!.title = "保存"
            return
        } else {
            tableView.userInteractionEnabled = false
            self.navigationItem.rightBarButtonItem!.title = "编辑"
        }
        
        if checkInputEmpty(personalInfo.username) {
            tips.showTipsInMainThread(Text: "请输入用户名")
            return
        }
        
        if checkInputEmpty(personalInfo.avatar) {
            tips.showTipsInMainThread(Text: "请输入头像")
            return
        }
        
        if checkInputEmpty(personalInfo.realname) {
            tips.showTipsInMainThread(Text: "请填写真实姓名")
            return
        }
        
        if checkInputEmpty(personalInfo.birth) {
            tips.showTipsInMainThread(Text: "请填写出生日期")
            return
        }
        
        if checkInputEmpty(personalInfo.sex) {
            tips.showTipsInMainThread(Text: "请填写性别")
            return
        }
        
        if userOrJT! {
            // 评委老师
            if checkInputEmpty(personalInfo.identity_card) {
                tips.showTipsInMainThread(Text: "请填写身份证号")
                return
            }
            
            if checkInputEmpty(personalInfo.region) {
                tips.showTipsInMainThread(Text: "请填写联系地址")
                return
            }
        }
        
        isConfirm = true
        
        YSPernalInfo.updatePersonalInfo(userOrJT, personalInfo: personalInfo, resp: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.isConfirm = false
                
                if self!.navigationController != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                }
                return
            }
            
            if self!.personalInfo.username != nil {
                ysApplication.loginUser.setUserNickName(self!.personalInfo.username)
            }
            if self!.personalInfo.realname != nil {
                ysApplication.loginUser.setUserRealName(self!.personalInfo.realname)
            }
            if self!.personalInfo.birth != nil {
                ysApplication.loginUser.setUserBirth(self!.personalInfo.birth)
            }
            if self!.personalInfo.sex != nil {
                ysApplication.loginUser.setUserSex(self!.personalInfo.sex)
            }
            if self!.personalInfo.identity_card != nil {
                ysApplication.loginUser.setUserIDCard(self!.personalInfo.identity_card)
            }
            if self!.personalInfo.region != nil {
                ysApplication.loginUser.setUserRegion(self!.personalInfo.region)
            }
            
            self!.navigationController?.popViewControllerAnimated(true)
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return personalInfo == nil ? 0 : 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return userOrJT! ? 6 : 4
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let topCell = tableView.dequeueReusableCellWithIdentifier("YSPersonalInfoTopCell")
        let normalCell = tableView.dequeueReusableCellWithIdentifier("YSPersonalInfoNormalCell")
        
        // Configure the cell...
        if indexPath.section == 0 {
            
            if personalInfo == nil {
                return topCell!
            }
            
            let img_avatar = topCell!.contentView.viewWithTag(11) as! UIImageView
            
            if MovieFilesManager.getUserLocalAvatarPath() == nil || UIImage(contentsOfFile: MovieFilesManager.getUserLocalAvatarPath()!) == nil {
                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(personalInfo.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.personalInfo.avatar).0
                    
                    
                    })
            } else {
                
                avatarPath = MovieFilesManager.getUserLocalAvatarPath()
                img_avatar.image = UIImage(contentsOfFile: MovieFilesManager.getUserLocalAvatarPath()!)
            }
            
            if  img_avatar.image == nil
            {
                img_avatar.image = UIImage(named: DEFAULT_AVATAR)
            }
            
            return topCell!
        } else if indexPath.section == 1 {
            
            if personalInfo == nil {
                return normalCell!
            }
            
            let lab_cellTitle = normalCell!.contentView.viewWithTag(21) as! UILabel
            let lab_info = normalCell!.contentView.viewWithTag(22) as! UILabel
            let bottomView = normalCell!.contentView.viewWithTag(12)
            
            switch indexPath.row {
            case 0:
                lab_cellTitle.text = "昵称:"
                lab_info.text = personalInfo.username
                bottomView?.hidden = true
            case 1:
                lab_cellTitle.text = "真实姓名:"
                lab_info.text = personalInfo.realname
                bottomView?.hidden = true
            case 2:
                lab_cellTitle.text = "出生日期:"
                lab_info.text = personalInfo.birth
                bottomView?.hidden = true
            case 3:
                lab_cellTitle.text = "性别:"
                lab_info.text = Int(personalInfo.sex) == 0 ? "女" : "男"
                bottomView?.hidden = true
            case 4:
                lab_cellTitle.text = "身份证号码:"
                lab_info.text = personalInfo.identity_card
                bottomView?.hidden = true
            case 5:
                lab_cellTitle.text = "联系地址:"
                lab_info.text = personalInfo.region
                bottomView?.hidden = false
            default:
                break
            }
        }

        return normalCell!
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 60.0
        } else {
            return 44.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            // 修改头像
            let camera_action = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                    let imagePickerController:UIImagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    //imagePickerController.allowsEditing = true
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera

                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
            }
            
            let photoLib_action = UIAlertAction(title: "从相册中提取", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                    let imagePickerController:UIImagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                  //  imagePickerController.allowsEditing = true
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
             //   alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                // 修改昵称
                let alertController = UIAlertController(title: "昵称", message: "填写昵称", preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler(nil)
                let commitAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    let text = alertController.textFields![0].text
                    if !checkInputEmpty(text) {
                        
                        if(checkRealName(text))
                        {
                        
                        self.personalInfo.username = text
                        
                        }
                        else
                        {
                            self.tips.showTipsInMainThread(Text: "昵称只能由中文、字母或数字组成")
                          
                        }
                    }
                    
                    self.tableView.reloadData()
                })
                alertController.addAction(commitAction)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
                break
            case 1:
                // 修改真实姓名
                let alertController = UIAlertController(title: "真实姓名", message: "填写真实姓名", preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler(nil)
                let commitAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    let text = alertController.textFields![0].text
                    if !checkInputEmpty(text) {
                        if(checkRealName(text))
                        {
                            self.personalInfo.realname = text
                        }
                        else
                        {
                            self.tips.showTipsInMainThread(Text: "姓名只能由中文、字母或数字组成")
                        }
                    }
                    
                    self.tableView.reloadData()
                })
                alertController.addAction(commitAction)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
                break
            case 2:
                // 修改生日
                pickerController.showPicker()
                break
            case 3:
                // 修改性别
                let alertController = UIAlertController(title: "选择性别", message: nil, preferredStyle: .Alert)
                let maleAction = UIAlertAction(title: "男", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    self.personalInfo.sex = "1"
                    self.tableView.reloadData()
                })
                let femaleAction = UIAlertAction(title: "女", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    self.personalInfo.sex = "0"
                    self.tableView.reloadData()
                })
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(maleAction)
                alertController.addAction(femaleAction)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
                break
            case 4:
                // 修改身份证号码
                let alertController = UIAlertController(title: "身份证号码", message: "填写身份证号码", preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler(nil)
                let commitAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    let text = alertController.textFields![0].text
                    if !checkInputEmpty(text) {
                        self.personalInfo.identity_card = text
                    }
                    
                    self.tableView.reloadData()
                })
                alertController.addAction(commitAction)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
                break
            case 5:
                // 所在地区
                let alertController = UIAlertController(title: "地区信息", message: "填写地区", preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler(nil)
                let commitAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    let text = alertController.textFields![0].text
                    if !checkInputEmpty(text) {
                        self.personalInfo.region = text
                    }
                    
                    self.tableView.reloadData()
                })
                alertController.addAction(commitAction)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
                break
            default:
                break
            }
            
        } else {
            
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
      //  var image = info[UIImagePickerControllerEditedImage] as! UIImage
        let ori_image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
        print(ori_image.size.height,ori_image.size.width)
       
        
        var newImage: UIImage? = nil
        
        
        let cropImageViewController =  CropImageViewController(originImage: ori_image) { (cropImage, viewController) in
            //
            
            UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
            let thumbnailRect: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
            cropImage.drawInRect(thumbnailRect)
            
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
            //        var error: NSError?
            if !NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Documents/Image") {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Image", withIntermediateDirectories: true, attributes: nil)
                }catch let error as NSError {
                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                    return
                }
                
            }
            
            let avatarName = ysApplication.loginUser.uid + "\(Int64(NSDate().timeIntervalSince1970 * 1000.0))" + "_avatar.png"
            self.avatarPath = NSHomeDirectory() + "/Documents/Image/" + avatarName
            
            if !NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Documents/Image/" + avatarName) {
                NSFileManager.defaultManager().createFileAtPath(NSHomeDirectory() + "/Documents/Image/" + avatarName, contents: nil, attributes: nil)
            }
            
            let imageData = UIImagePNGRepresentation(newImage!)
            imageData!.writeToFile(self.avatarPath, atomically: true)
            
            viewController.dismissViewControllerAnimated(true, completion: nil)
            
            self.tips.showTipsInMainThread(Text: "上传头像...")
            self.uploadManager = MovieUploadManager(key: avatarName, movieOrImage: 0, status: 2)
            self.uploadManager.getUploadToken({ [weak self] () -> Void in
                
                if self == nil {
                    return
                }
                
                self!.uploadManager.uploadWithProgress(nil, completionBlock: { (resp: QNResponseInfo!, key: String!, info: [NSObject : AnyObject]!) -> Void in
                    
                    if resp.ok {
                        
                        if self == nil {
                            return
                        }
                        
                        NSData(contentsOfFile: self!.avatarPath)?.writeToFile(MovieFilesManager.getUserLocalAvatarPath()!, atomically: true)
                        
                        self!.tips.showTipsInMainThread(Text: "上传成功")
                        
                        self!.tableView.reloadData()
                        
                        YSAvatar.updateAvatar(self!.userOrJT, fileName: avatarName, respBlock: { [weak self] (errorMsg: String!) -> Void in
                            
                            if self == nil {
                                return
                            }
                            
                            if errorMsg != nil {
                                self!.tips.showTipsInMainThread(Text: errorMsg)
                                return
                            }
                            })
                    }
                })
                })
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
        cropImageViewController.fixCropSize = true;
         self.presentViewController(cropImageViewController, animated: true, completion: nil)
     /*   if(ori_image.size.height < ori_image.size.width )
        {
            let rect: CGRect = CGRect(x: image.size.width * 0.2, y: image.size.width * 0.2, width: image.size.width*0.6, height: image.size.height*0.6)
            
            
            let imageRef = CGImageCreateWithImageInRect(image.CGImage!,rect)
            
            image = UIImage(CGImage: imageRef!)
            
          //  CGImageRelease(imageRef!);
            
            
        }*/
        
        
       
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - YSCustomPickerViewDelegate
    
    func changeDateString(dateString: String) {
        
        if personalInfo == nil {
            return
        }
        
        personalInfo.birth = dateString
        
        self.tableView.reloadData()
    }
}
