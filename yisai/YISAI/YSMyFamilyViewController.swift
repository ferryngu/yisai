//
//  YSMyFamilyViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/15.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyFamilyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private struct AssociatedObject {
        static var GetImageURL = "GetImageURL"
        static var GetVideoURL = "GetVideoURL"
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var lst_family_dynamic: [YSFamilyDynamic]!
    var lst_parent_info: [YSParentInfo]!
    var loadFindWorkIndex: Int = 0
    var isLoadMore: Bool = false
    var isLoading: Bool = false
    var originTableViewFooterOrigin: CGPoint = CGPoint(x: 0, y: 0)
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.duration = 1

        configureRefreshView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let videoName = objc_getAssociatedObject(ysApplication.tabbarController, &AssociatedPostFamilyDynamic.GetVideoName) as? String
        if videoName != nil {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSPostFamilyDynamicViewController") as! YSPostFamilyDynamicViewController
            controller.videoName = videoName
            controller.postStatus = .Video
            self.navigationController?.pushViewController(controller, animated: true)
            objc_setAssociatedObject(ysApplication.tabbarController, &AssociatedPostFamilyDynamic.GetVideoName, nil,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        loadFindWorkIndex = 0
        isLoadMore = false
        isLoading = false
        fetchFamilyInfo(true)
        loadFindWorkIndex += 20
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    func configureFamilyAvatars() {
        
        let img_father = topView.viewWithTag(11) as! UIImageView
        let img_mother = topView.viewWithTag(12) as! UIImageView
        
        img_father.layer.cornerRadius = (SCREEN_WIDTH/2 - (40+30))/2
        img_mother.layer.cornerRadius = (SCREEN_WIDTH/2 - (40+30))/2
        img_father.clipsToBounds = true
        img_mother.clipsToBounds = true
        
        if lst_parent_info == nil || lst_parent_info.count < 2 {
            return
        }
        
        let father_info = lst_parent_info[1]

        img_father.image = feiOSHttpImage.asyncHttpImageInUIThread(father_info.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_father.image = self!.feiOSHttpImage.loadImageInCache(father_info.avatar).0
            })
        
        let mother_info = lst_parent_info[0]
        img_mother.image = feiOSHttpImage.asyncHttpImageInUIThread(mother_info.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_mother.image = self!.feiOSHttpImage.loadImageInCache(mother_info.avatar).0
            })
        
        let btn_father = topView.viewWithTag(21) as! UIButton
        let btn_mother = topView.viewWithTag(22) as! UIButton
        
        btn_father.addTarget(self, action: "gotoEditingParentsInfo:", forControlEvents: .TouchUpInside)
        btn_mother.addTarget(self, action: "gotoEditingParentsInfo:", forControlEvents: .TouchUpInside)
    }
    
    func configureRefreshView() {
        
        self.tableView.addLegendHeaderWithRefreshingBlock { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            if self!.isLoading {
                return
            }
            
            self!.isLoadMore = false
            self!.isLoading = true
            
            self!.loadFindWorkIndex = 0
            
            self!.fetchFamilyInfo(true)
            
            self!.loadFindWorkIndex += 20
            
            self!.tableView.header!.endRefreshing()
        }
        
        self.tableView.header!.setTitle("下拉可以刷新", forState: MJRefreshHeaderStateIdle)
        self.tableView.header!.setTitle("松开进行刷新", forState: MJRefreshHeaderStatePulling)
        self.tableView.header!.setTitle("正在刷新数据中...", forState: MJRefreshHeaderStateRefreshing)
        self.tableView.header!.font = UIFont.systemFontOfSize(13.0)
        self.tableView.header!.textColor = UIColor.lightGrayColor()
        
        self.tableView.addLegendFooterWithRefreshingBlock { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            if self!.isLoading {
                return
            }
            
            self!.isLoadMore = true
            self!.isLoading = true
            
            self!.fetchFamilyInfo(false)
            
            self!.loadFindWorkIndex += 20
            
            self!.tableView.footer!.endRefreshing()
        }
        
        self.tableView.footer!.automaticallyRefresh = false
        self.tableView.footer!.setTitle("上拉可以刷新", forState: MJRefreshFooterStateIdle)
        self.tableView.footer!.setTitle("已无更多内容", forState: MJRefreshFooterStateNoMoreData)
        self.tableView.footer!.setTitle("正在刷新数据中...", forState: MJRefreshFooterStateRefreshing)
        self.tableView.footer!.font = UIFont.systemFontOfSize(13.0)
        self.tableView.footer!.textColor = UIColor.lightGrayColor()
    }
    
    func calculateCellHeight(indexPath: NSIndexPath) -> CGFloat {
        
        let family_dynamic = lst_family_dynamic[indexPath.row]
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 108 - 8, height: 20))
        tempLabel.text = family_dynamic.content
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let lab_contentHeight = tempLabel.sizeThatFits(CGSize(width: SCREEN_WIDTH - 108 - 8, height: 999)).height
        
        let imgWidth = (SCREEN_WIDTH - 108 - 5 * 3)/3
        var imgViewHeight: CGFloat = 0.0
        if family_dynamic.video_img_url != "" {
            
            imgViewHeight = imgWidth * 2 + 8
        } else if family_dynamic.lst_picture.count > 0 {
            
            imgViewHeight = family_dynamic.lst_picture.count < 4 ? imgWidth : 2 * imgWidth + 5
        }
        return 20.0 + lab_contentHeight + imgViewHeight + 20.0
    }
    
    func fetchFamilyInfo(shouldCache: Bool) {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSFamilyInfo.fetchFamilyDynamic(shouldCache, startIndex: loadFindWorkIndex, num: 20) { [weak self] (resp_lst_family_dynamic:[YSFamilyDynamic]!, resp_lst_parent_info: [YSParentInfo]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if self!.originTableViewFooterOrigin.y == 0 {
                self!.originTableViewFooterOrigin = self!.tableView.footer!.frame.origin
            }
            self!.isLoading = false
            
            if self!.isLoadMore {
                
                if resp_lst_family_dynamic != nil {
                    
                    if resp_lst_family_dynamic.count < 1 {
                        self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                        return
                    }
                    
                    for family_dynamic in resp_lst_family_dynamic {
                        self!.lst_family_dynamic.append(family_dynamic)
                    }
                    
                    self!.tableView.reloadData()
                }
                return
            }
            
            self!.lst_family_dynamic = resp_lst_family_dynamic
            self!.lst_parent_info = resp_lst_parent_info
            self!.tableView.footer!.frame.origin = self!.originTableViewFooterOrigin
            self!.tableView.footer!.state = MJRefreshFooterStateIdle
            self!.configureFamilyAvatars()
            self!.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lst_family_dynamic != nil ? lst_family_dynamic.count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("YSMyFamilyCell")
        
        if lst_family_dynamic == nil {
            return cell!
        }
        
        let family_dynamic = lst_family_dynamic![indexPath.row]
        let leftView = cell!.contentView.viewWithTag(10)!
        let lab_monthAndDay = leftView.viewWithTag(1) as! UILabel
        let lab_year = leftView.viewWithTag(2) as! UILabel
        
        lab_monthAndDay.text = family_dynamic.update_time_month_day
        lab_year.text = family_dynamic.update_time_year
        
        let img_view = cell!.contentView.viewWithTag(12)!
        
        for subview in img_view.subviews {
            subview.removeFromSuperview()
        }
        
        let lab_content = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lab_content.numberOfLines = 0
        lab_content.font = UIFont.systemFontOfSize(16.0)
        lab_content.text = family_dynamic.content
        lab_content.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lab_content.frame.size = CGSize(width: SCREEN_WIDTH - 108 - 8, height: lab_content.sizeThatFits(CGSize(width: SCREEN_WIDTH - 108 - 8, height: 999)).height)
        img_view.addSubview(lab_content)
        
        let imgWidth = (SCREEN_WIDTH - 108 - 5*3)/3
        let imgsOriginY = lab_content.bounds.height + 8.0
        if family_dynamic.video_img_url != "" {
            
            let imgViewHeight = imgWidth*2+8
            let imageView = UIImageView(frame: CGRect(x: 0, y: imgsOriginY, width: imgViewHeight * 4 / 3, height: imgWidth * 2 + 8))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.userInteractionEnabled = true
            imageView.clipsToBounds = true
            imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(family_dynamic.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                imageView.image = self!.feiOSHttpImage.loadImageInCache(family_dynamic.video_img_url).0
                })
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "tapVideoView:")
            objc_setAssociatedObject(tapGesture, &AssociatedObject.GetVideoURL, family_dynamic.video_url, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            imageView.addGestureRecognizer(tapGesture)
            
            img_view.addSubview(imageView)
            
            
            
        } else if family_dynamic.lst_picture.count > 0 {
            
            for var i = 0; i < family_dynamic.lst_picture.count; i++ {
                
                let originX = (imgWidth + 5.0) * CGFloat(i%3)
                let originY = i < 3 ? imgsOriginY : imgsOriginY + imgWidth + 5
                let imageView = UIImageView(frame: CGRect(x: originX, y: originY, width: imgWidth, height: imgWidth))
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.userInteractionEnabled = true
                imageView.clipsToBounds = true
                imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(family_dynamic.lst_picture[i], defaultImageName:DEFAULT_IMAGE_NAME_SQUARE, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    imageView.image = self!.feiOSHttpImage.loadImageInCache(family_dynamic.lst_picture[i]).0
                    })
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "tapImageView:")
                objc_setAssociatedObject(tapGesture, &AssociatedObject.GetImageURL, family_dynamic.lst_picture[i], objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                imageView.addGestureRecognizer(tapGesture)
                
                img_view.addSubview(imageView)
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return calculateCellHeight(indexPath)
    }
    
    // MARK: - Actions
    
    func tapVideoView(tap: UITapGestureRecognizer) {
        
        var videoUrl = objc_getAssociatedObject(tap, &AssociatedObject.GetVideoURL) as? String
        
        videoUrl = (videoUrl == nil ? "" : videoUrl)
        
        let controller = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomFullVideoPlayerViewController") as! YSCustomFullVideoPlayerViewController
        controller.contentURLStr = videoUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func tapImageView(tap: UITapGestureRecognizer) {
        
        var imgUrl = objc_getAssociatedObject(tap, &AssociatedObject.GetImageURL) as? String
        
        imgUrl = (imgUrl == nil ? "" : imgUrl)
        
        let controller = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomFullImageViewController") as! YSCustomFullImageViewController
        controller.imgUrl = imgUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func addFamilyInfoWithText(sender: AnyObject) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSPostFamilyDynamicViewController") as! YSPostFamilyDynamicViewController
        controller.postStatus = YSPostFamilyDynamicStatus.Text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func addFamilyInfo(sender: AnyObject) {
        
//        let item = sender as! UIBarButtonItem
        
        let video_action = UIAlertAction(title: "小视频", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            
            let controller = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
            controller.cameraMovieStyle = .Dynamic
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
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
        alertController.addAction(video_action)
        alertController.addAction(camera_action)
        alertController.addAction(photoLib_action)
        alertController.addAction(cancelAction)
        
        if isUsingiPad() {
            
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.frame
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func gotoEditingParentsInfo(button: UIButton) {
        
        if lst_parent_info == nil || lst_parent_info.count < 1 {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSParentInfoViewController") as! YSParentInfoViewController
        
        if button.tag == 22 {
            let motherInfo = lst_parent_info![0]
            controller.sexType = motherInfo.type.integerValue
            controller.piid = motherInfo.piid
            
        } else {
            let fatherInfo = lst_parent_info![1]
            controller.sexType = fatherInfo.type.integerValue
            controller.piid = fatherInfo.piid
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
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
        let dateString = formatter.stringFromDate(date)
        
        let imgName = ysApplication.loginUser.uid + dateString + ".png"
        let imgPath = imgDir + "/" + imgName
        
        if NSFileManager.defaultManager().fileExistsAtPath(imgPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imgPath)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }

        }
        
//        println(imgPath)
        let imageData = UIImagePNGRepresentation(newImage!)
        imageData!.writeToFile(imgPath, atomically: true)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSPostFamilyDynamicViewController") as! YSPostFamilyDynamicViewController
        controller.lst_postImageName = [imgName]
        controller.lst_postImagePath = [imgPath]
        controller.postStatus = YSPostFamilyDynamicStatus.Images
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
