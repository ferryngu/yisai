//
//  YSPostFamilyDynamicViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/17.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum YSPostFamilyDynamicStatus {
    case Text   // 发送纯文本
    case Images // 发送图片+文本
    case Video  // 发送小视频+文本.
}

struct AssociatedPostFamilyDynamic {
    static var GetDeleteStatus = "GetDeleteStatus"
    static var GetVideoName = "GetVideoName"
}

class YSPostFamilyDynamicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txv_content: UITextView!
    
    var postStatus: YSPostFamilyDynamicStatus = .Images // 发送文本或小视频或图片
    var lst_postImageName: [String]! // 发送图片名称
    var lst_postImagePath: [String]! // 发送图片本地路径
    var videoName: String! // 视频名称
    var currentIndex: Int = 1000 // 当前进入编辑状态的按钮
    var tips: FETips = FETips()
    var uploadManager: MovieUploadManager!
    var uploadSuccessCount: Int = 0
    var isPosting: Bool = false
    
    private let btnWidth = (SCREEN_WIDTH - 16 * 2 - 5 * 3) / 4
    private let bgOriginY = 8 + 100 + 8
    private let bgOriginX = 20
    private let imgBtnOriginTag = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = FETips()
        tips.duration = 1

        // Do any additional setup after loading the view.
        if postStatus == .Images {
            configureImageBg()
        } else if postStatus == .Video {
            configureVideoBg()
        }
        
        uploadManager = MovieUploadManager(key: nil, movieOrImage: 0, status: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if postStatus == .Images {
            // 删除不要的图片
            let deleteStatus = objc_getAssociatedObject(self.navigationController, &AssociatedPostFamilyDynamic.GetDeleteStatus) as? String
            if deleteStatus != nil && deleteStatus == "1" {
                
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(lst_postImagePath[currentIndex - imgBtnOriginTag])
                }catch let error as NSError {
                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                    return
                }

                
                lst_postImageName.removeAtIndex(currentIndex - imgBtnOriginTag)
                lst_postImagePath.removeAtIndex(currentIndex - imgBtnOriginTag)
                
                objc_setAssociatedObject(self.navigationController, &AssociatedPostFamilyDynamic.GetDeleteStatus, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            refreshImageWall()
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        
//        super.viewWillDisappear(animated)
//        
//        if isPosting {
//            let alertController = UIAlertController(title: "提示", message: "是否取消发送？", preferredStyle: UIAlertControllerStyle.Alert)
//            let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
//                
//                self.uploadManager.suspendFlag = true
//            })
//            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
//            alertController.addAction(confirmAction)
//            alertController.addAction(cancelAction)
//            presentViewController(alertController, animated: true, completion: nil)
//            return
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureImageBg() {
        
        for var i = 0; i < 6; i++ {
            
            let originX = bgOriginX + (5 + Int(btnWidth)) * (i % 4)
            let originY = (i < 4) ? bgOriginY : (bgOriginY + Int(btnWidth) + 5)
            let btn = UIButton(frame: CGRect(x: originX, y: originY, width: Int(btnWidth), height: Int(btnWidth)))
            btn.addTarget(self, action: "editImage:", forControlEvents: .TouchUpInside)
            btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            btn.clipsToBounds = true
            btn.tag = imgBtnOriginTag + i
            btn.setImage(UIImage(named: "postfamily_fasong"), forState: UIControlState.Normal)
            btn.hidden = true
            view.addSubview(btn)
        }
    }
    
    func configureVideoBg() {
        
        let btn = UIButton(frame: CGRect(x: bgOriginX, y: bgOriginY, width: Int(btnWidth * 2) * 4 / 3, height: Int(btnWidth * 2)))
        btn.addTarget(self, action: "editVideo:", forControlEvents: .TouchUpInside)
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        btn.clipsToBounds = true
        btn.setImage(MovieFilesManager.getImage(MovieFilesManager.movieFilePathURL(videoName)), forState: .Normal)
        view.addSubview(btn)
    }
    
    func refreshImageWall() {
        
        for index in 0...5 {
            let btn = view.viewWithTag(imgBtnOriginTag+index) as! UIButton
            btn.hidden = true
            btn.setImage(nil, forState: .Normal)
        }
        
        if lst_postImagePath == nil{
            return
        }
        
        for index in 0..<lst_postImagePath.count {
            let imagePath = lst_postImagePath[index]
            let btn = view.viewWithTag(imgBtnOriginTag+index) as! UIButton
            btn.hidden = false
            btn.setImage(UIImage(named: imagePath), forState: .Normal)
        }
        
        if lst_postImagePath.count < 6 {
            let btn = view.viewWithTag(imgBtnOriginTag+lst_postImagePath.count) as! UIButton
            btn.hidden = false
            btn.setBackgroundImage(UIImage(named: "postfamily_fasong"), forState: UIControlState.Normal)
        }
    }
    
    // MARK: - Actions
    
    func editImage(button: UIButton) {
        
        currentIndex = button.tag
        if currentIndex > imgBtnOriginTag + lst_postImagePath.count - 1 {
            
            let camera_action = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                    let imagePickerController:UIImagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
            }
            
            let photoLib_action = UIAlertAction(title: "从相册中提取", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                    let imagePickerController:UIImagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler:nil)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alertController.addAction(camera_action)
            alertController.addAction(photoLib_action)
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // 进入图片预览
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSPostImagePreviewViewController") as! YSPostImagePreviewViewController
            controller.imagePath = lst_postImagePath[currentIndex - imgBtnOriginTag]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func editVideo(button: UIButton) {
        
        let controller = UIStoryboard(name: "YSPlayer", bundle: nil).instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
        controller.isFullscreen = true
        controller.contentURL = MovieFilesManager.movieFilePathURL(videoName)
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func commit(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        switch postStatus {
        case .Text:
            
            if txv_content.text == nil || txv_content.text == "这一刻想说点什么......" {
                tips.showTipsInMainThread(Text: "请输入要发送的文字")
                return
            }
            
            if isPosting {
                return
            }
            
            tips.duration = 30
            tips.showActivityIndicatorViewInMainThread(self, text: "正在发送")
            
            isPosting = true
            
            YSFamilyDynamic.postFamilyDynamic(txv_content.text, videoFil: nil, imagesName: nil, block: { [weak self] (errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                self!.isPosting = false
                
                if errorMsg != nil {
                    self!.tips.duration = 1
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                self!.tips.disappearActivityIndicatorViewInMainThread()
                self!.tips.duration = 1
                self!.tips.showTipsInMainThread(Text: "发送成功")
                
                delayCall(1.0, block: { () -> Void in
                    self!.navigationController?.popViewControllerAnimated(true)
                })
            })
        case .Images:
            
            if lst_postImagePath == nil || lst_postImageName == nil || lst_postImageName.count < 1 || lst_postImagePath.count < 1 {
                
                tips.showTipsInMainThread(Text: "请输入要发送的图片")
                return
            }
            
            if isPosting {
                return
            }
            
            isPosting = true
            uploadManager.movieOrImage = 0
            tips.duration = 150
            
            let currentUpload = (uploadSuccessCount + 1 > lst_postImageName.count) ? uploadSuccessCount : uploadSuccessCount + 1
            tips.showActivityIndicatorViewInMainThread(self, text: "正在发送图片(\(currentUpload)/\(lst_postImageName.count))")
            postImages(lst_postImageName[0])
        case .Video:
            
            if isPosting {
                return
            }
            
            isPosting = true
            
            let postText: String? = (txv_content.text == nil || txv_content.text == "这一刻想说点什么......") ? nil : txv_content.text
            uploadManager.movieOrImage = 1
            uploadManager.key = videoName
            uploadManager.status = 1
            tips.duration = 60
            tips.showActivityIndicatorViewInMainThread("正在发送中")
                
            uploadManager.uploadWithProgress(nil, completionBlock: { [weak self] (resp: QNResponseInfo!, key: String!, info: [NSObject : AnyObject]!) -> Void in
                
                if self == nil {
                    return
                }
                
                if resp.error != nil {
                    self!.isPosting = false
                }
                
                if resp.ok {
                    YSFamilyDynamic.postFamilyDynamic(postText, videoFil: self!.videoName, imagesName: nil, block: { [weak self] (errorMsg: String!) -> Void in
                        
                        if self == nil {
                            return
                        }
                        
                        self!.isPosting = false
                        
                        if errorMsg != nil {
                            self!.tips.showTipsInMainThread(Text: errorMsg)
                            return
                        }
                        
                        self!.tips.disappearActivityIndicatorViewInMainThread()
                        self!.tips.duration = 1
                        self!.tips.showTipsInMainThread(Text: "发送成功")
                        delayCall(1.0, block: { () -> Void in
                            self!.navigationController?.popViewControllerAnimated(true)
                        })
                    })
                }
            })
        }
    }
    
    func postImages(imageName: String) {
        
        uploadManager.movieOrImage = 0
        uploadManager.status = 1
        uploadManager.key = imageName
        uploadManager.getUploadToken({ [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.uploadManager.uploadWithProgress(nil, completionBlock: { (resp: QNResponseInfo!, key: String!, info: [NSObject : AnyObject]!) -> Void in
                
                if self == nil {
                    return
                }
                
                if resp.ok {
                    self!.uploadSuccessCount++
                    if self!.uploadSuccessCount < self!.lst_postImageName.count {
                        
                        let currentUpload = (self!.uploadSuccessCount + 1 > self!.lst_postImageName.count) ? self!.uploadSuccessCount : self!.uploadSuccessCount + 1
                        self!.tips.tipsViewlabel.text = "正在发送图片(\(currentUpload)/\(self!.lst_postImageName.count))"
                        self!.postImages(self!.lst_postImageName[self!.uploadSuccessCount])
                    }
                }
                
                if (resp.error != nil) {
                    self!.isPosting = false
                    self!.tips.disappearActivityIndicatorViewInMainThread()
                    self!.tips.duration = 1
                    self!.tips.showTipsInMainThread(Text: resp.error.localizedDescription)
                    return
                }
                
                if self!.uploadSuccessCount == self!.lst_postImageName.count {
                    
                    let postText: String? = (self!.txv_content.text == nil || self!.txv_content.text == "这一刻想说点什么......") ? nil : self!.txv_content.text
                    
                    YSFamilyDynamic.postFamilyDynamic(postText, videoFil: nil, imagesName: self!.lst_postImageName, block: { (errorMsg: String!) -> Void in
                        
                        if self == nil {
                            return
                        }
                        
                        self!.isPosting = false
                        
                        if errorMsg != nil {
                            self!.tips.showTipsInMainThread(Text: errorMsg)
                            return
                        }
                        
                        self!.tips.disappearActivityIndicatorViewInMainThread()
                        self!.tips.duration = 1
                        self!.tips.showTipsInMainThread(Text: "发送成功")
                        delayCall(1.0, block: { () -> Void in
                            
                            if self == nil {
                                return
                            }
                            
                            self!.navigationController?.popViewControllerAnimated(true)
                        })
                    })
                }
            })
        })
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if txv_content.text == "这一刻想说点什么......" {
            txv_content.text = ""
        }
        
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if txv_content.text == nil {
            txv_content.text = "这一刻想说点什么......"
        }
        
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        var newImage: UIImage? = nil
        
        UIGraphicsBeginImageContext(CGSize(width: image.size.width/2, height: image.size.height/2))
        let thumbnailRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width/2, height: image.size.height/2)
        image.drawInRect(thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        newImage = UIImage(data: UIImageJPEGRepresentation(newImage, 0.5))
        
//        var error: NSError?
        let imgDir = NSHomeDirectory() + "/Documents/Image"
        if !NSFileManager.defaultManager().fileExistsAtPath(imgDir) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(imgDir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }
        }
        
        let date: NSDate = NSDate()
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        _ = formatter.stringFromDate(date)
        
        let imgName = ysApplication.loginUser.uid + "\(Int64(NSDate().timeIntervalSince1970 * 1000.0))" + ".png"
        let imgPath = imgDir + "/" + imgName
        
        if NSFileManager.defaultManager().fileExistsAtPath(imgPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imgPath)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }

        }
        
        let imageData = UIImagePNGRepresentation(newImage!)
        imageData!.writeToFile(imgPath, atomically: true)
        
        self.lst_postImagePath.append(imgPath)
        self.lst_postImageName.append(imgName)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
