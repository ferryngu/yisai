//
//  YSParentInfoViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/15.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSParentInfoViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, YSCustomDatePickerDelegate {

    @IBOutlet weak var txf_name: UITextField!
    @IBOutlet weak var lab_birth: UILabel!
    @IBOutlet weak var img_avatar: UIImageView!
    var datePickerBgview: UIView!
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    
    var sexType: Int = 0
    var piid: String!
    var parentInfo: YSParentInfo!
    var tips: FETips = FETips()
    var avatarPath: String!
    var pickerController: YSCustomDatePickerViewController!
    var isConfirm: Bool = false
    var uploadManager: MovieUploadManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tips = FETips()
        tips.duration = 1
        
        fetchParentInfo()
        
        pickerController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomDatePickerViewController") as! YSCustomDatePickerViewController
        pickerController.delegate = self
        self.view.addSubview(pickerController.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if sexType == 1 {
            self.title = "我的妈妈"
        } else {
            self.title = "我的爸爸"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchParentInfo() {
        
//        if sexType == 1 {
//            avatarPath = NSHomeDirectory() + "/Documents/Image/FatherAvatar.png"
//        } else {
//            avatarPath = NSHomeDirectory() + "/Documents/Image/MotherAvatar.png"
//        }
        
//        img_avatar.image = UIImage(named: avatarPath)
        img_avatar.image = UIImage(named: DEFAULT_AVATAR)
        
        if piid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSParentInfo.fetchParentInfo(piid, block: { [weak self] (resp_parentInfo: YSParentInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.parentInfo = resp_parentInfo
           
            self!.img_avatar.image = self!.feiOSHttpImage.asyncHttpImageInUIThread(resp_parentInfo.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                self!.img_avatar.image = self!.feiOSHttpImage.loadImageInCache(resp_parentInfo.avatar).0
                })
            self!.txf_name.text = resp_parentInfo.realname
            self!.lab_birth.text = resp_parentInfo.birth
            self!.tableView.reloadData()
        })
    }
    
    // MARK: - Actions
    
    @IBAction func commitInfo(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if img_avatar.image == nil {
            tips.showTipsInMainThread(Text: "请输入头像")
            return
        }
        
        if txf_name.text == nil || checkInputEmpty(txf_name.text) {
            tips.showTipsInMainThread(Text: "请输入姓名")
            return
        }
        
        if lab_birth.text == nil {
            tips.showTipsInMainThread(Text: "请输入出生日期")
            return
        }
        
        if isConfirm {
            tips.showTipsInMainThread(Text: "正在提交资料")
            return
        }
        
        isConfirm = true
        
        YSParentInfo.updateParentInfo(txf_name.text!, birth: lab_birth.text!, type: sexType) { [weak self] (errorMsg: String!) -> Void in
            
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
            
            if self!.navigationController != nil {
                self!.tips.showTipsInMainThread(Text: "提交成功")
            }
        }
    }
    
    func datePickerDateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        self.lab_birth.text = dateFormatter.stringFromDate(datePicker.date)
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            self!.datePickerBgview.alpha = 0
            }) { [weak self] (completed: Bool) -> Void in
                self!.datePickerBgview.removeFromSuperview()
        }
    }
    
    @IBAction func selectBirth(sender: AnyObject) {
        
        if txf_name.isFirstResponder() {
            txf_name.resignFirstResponder()
        }
        
        // 修改生日
        pickerController.showPicker()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return parentInfo == nil ? 0 : 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            // 修改头像
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
               /// alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
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
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Image", withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }

        }
        
        let imageName = ysApplication.loginUser.uid + "\(Int64(NSDate().timeIntervalSince1970 * 1000.0))" + ".png"
        avatarPath = NSHomeDirectory() + "/Documents/Image/" + imageName
        let imageData = UIImagePNGRepresentation(newImage!)
        imageData!.writeToFile(avatarPath, atomically: true)
        
        picker.dismissViewControllerAnimated(true, completion: { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "上传头像...")
            
            self!.uploadManager = MovieUploadManager(key: imageName, movieOrImage: 0, status: 2)
            self!.uploadManager.getUploadToken({ [weak self] () -> Void in
                
                self!.uploadManager.uploadWithProgress(nil, completionBlock: { (resp: QNResponseInfo!, key: String!, info: [NSObject : AnyObject]!) -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    if resp.ok {
                        
                        YSParentInfo.updateParentAvatar(self!.piid, filename: imageName, block: { (errorMsg: String!) -> Void in
                            
                            if self == nil {
                                return
                            }
                            
                            if errorMsg != nil {
                                self!.tips.showTipsInMainThread(Text: errorMsg)
                                return
                            }
                            
                            self!.tips.showTipsInMainThread(Text: "上传成功")
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self!.img_avatar.image = newImage
                            })
                        })
                    }
                })
            })
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - YSCustomPickerViewDelegate
    
    func changeDateString(dateString: String) {
        
        self.lab_birth.text = dateString
        
        self.tableView.reloadData()
    }
}
