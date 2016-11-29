//
//  YSDiscoveryDetailViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/12.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

class YSDiscoveryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UMSocialUIDelegate {

    private struct AssociatedKeys {
        static var GetTopCell = "GetTopCell"
        static var GetCommentUser = "GetCommentUser"
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loc_bottomView_bottom: NSLayoutConstraint!
    @IBOutlet weak var loc_bottomView_height: NSLayoutConstraint!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var btn_share: UIButton!
    
    @IBOutlet weak var loc_container_height: NSLayoutConstraint!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var wid: String!
    var detail: YSDiscoveryDetail!
    var movieURL: String!
    var movieController: MoviePlayerController!
    var maxTextHeight: CGFloat = 85
    var tips: FETips = FETips()
    var praiseStatus: Bool = false
    var networkStatus: AFNetworkReachabilityStatus = .ReachableViaWiFi
    var img_video: UIImageView!
    var popView: MZPopView!
    var videoImage: UIImage!
    var fullscreen: Bool = false
    var back_btn:UIButton!
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.duration = 120
//MARK: - ????
        networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.prefersStatusBarHidden()
        
        loc_container_height.constant = SCREEN_WIDTH * 60.0 / 103.0
        
        fetchDetail()
        
        addVideoView()
        
        configurePlayer()
        
        back_btn = UIButton(frame: CGRectMake(15, 25, 30, 30))
        back_btn .setBackgroundImage(UIImage(named: "cs_fanhui"), forState: .Normal)
        back_btn.addTarget(self,action:#selector(popToBack),forControlEvents:.TouchUpInside)
        back_btn.tintColor = UIColor.whiteColor()
        self.view.addSubview(back_btn)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hidePopView", name: MZPopViewHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackSuccess:", name: YSMoviePlaybackSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackFailed:", name: YSMoviePlaybackFailed, object: nil)
        
        // 将要进入全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillEnterFullscreen:", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        // 将要退出全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillExitFullscreen:", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MZPopViewHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMoviePlaybackSuccess, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMoviePlaybackFailed, object: nil)
        
        // 将要进入全屏
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        // 将要退出全屏
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        
        if !fullscreen {
            stopMoviePlayBack()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    
    /* load detail image */
    func fetchDetailImage() {
        
        if detail == nil {
            return
        }
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {[weak self] () -> Void in
            dispatch_sync(queue, { () -> Void in
                
                if self == nil {
                    return
                }
                
                let urlAsString = self!.detail.video_img_url
                let url = NSURL(string: urlAsString)
                let urlRequest = NSURLRequest(URL: url!)
//                var downloadError: NSError?
                
//                let imageData = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: nil, error: &downloadError)
                do {
                    let imageData = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: nil)
                    if imageData.length > 0 && self != nil {
                        
                        self!.videoImage = UIImage(data: imageData)
                    }
                }catch let error as NSError {
                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                    return
                }
            })
        })
    }
    
    func configureBtnPlay() {
        
//        if img_video == nil {
//            img_video = UIImageView(frame: containerView.bounds)
//            containerView.addSubview(img_video)
//        }
//        if detail != nil || detail.video_img_url != nil {
//            img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(detail.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
//                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
//                
//                if self == nil { return }
//                self!.img_video.image = self!.feiOSHttpImage.loadImageInCache(self!.detail.video_img_url).0
//                })
//        }
//        img_video.contentMode = UIViewContentMode.ScaleAspectFill
//        img_video.clipsToBounds = true
//        img_video.userInteractionEnabled = true
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "tapImageVideo:")
//        img_video.addGestureRecognizer(tapGesture)
        
        handleNetwork()
    }
    
    func configurePlayer() {
        
        if movieController == nil && detail != nil && detail.video_url != nil {
            movieController = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
            movieController.contentURL = NSURL(string: detail.video_url)
            movieController.clickBackHandler = popToBack
            movieController.clickShareHandler = share
            self.addChildViewController(movieController)
            movieController.view.frame = self.containerView.bounds
            self.containerView.addSubview(movieController.view)
//            movieController.setupPlayingVideo()
            movieController.didMoveToParentViewController(self)
        }
    }
    //网络状态检测
    func handleNetwork() {
        
        networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
        configurePlayer()
        
        switch networkStatus {
        case .NotReachable:
            let alertController = UIAlertController(title: nil, message: "网络不给力，请检测网络", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(action)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWWAN:
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续观看?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                if self.movieController.moviePlayer == nil {
                    self.movieController.setupPlayingVideo()
                }
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWiFi:
            
            if self.movieController.moviePlayer == nil {
                self.movieController.setupPlayingVideo()
            }
        default:
            break
        }
    }
    
    // 累计播放次数
    func addVideoView() {
        
        if wid == nil {
            return
        }
        
        YSDiscovery.addVideoView(wid, block: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
        })
    }
    
    // 获取发现详情数据
    func fetchDetail() {
        
        if wid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSDiscoveryDetail.fetchWorkDetail(wid, block: { [weak self] (resp_detail: YSDiscoveryDetail!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.back_btn.hidden = true
            
            self!.detail = resp_detail
            self!.fetchDetailImage()
            self!.configureBtnPlay()
            self!.tableView.reloadData()
        })
    }
    
    func calculateLabelHeight(label: UILabel) -> CGFloat {
        return label.sizeThatFits(CGSize(width: SCREEN_WIDTH - 59, height: 9999)).height
    }
    
    // 终止视频播放
    func stopMoviePlayBack() {
        
        if movieController != nil && movieController.moviePlayer != nil {
            movieController.view.removeFromSuperview()
            self.movieController.stopPlayingVideo()
            self.movieController = nil
        }
    }
    
    // 检测导航栈是否已存在某个View
    func checkNavChildController(uid: String, role_type: Int) -> Bool {
        
        if self.navigationController == nil {
            return false
        }
        
        let childViewControllers = self.navigationController!.childViewControllers
        
        var findFlag = false
        var findViewController: UIViewController? = nil
        
        for viewController in childViewControllers {
            
            if viewController is YSUserPersonalInfoViewController && role_type == 1 {
                (viewController as! YSUserPersonalInfoViewController).fuid = uid
                findViewController = (viewController )
                findFlag = true
                break
            }
            
            if viewController is YSTNJPersonalInfoViewController && role_type != 1 {
                (viewController as! YSTNJPersonalInfoViewController).aid = uid
                findViewController = viewController
                findFlag = true
                break
            }
        }
        
        if findViewController != nil {
            self.navigationController!.popToViewController(findViewController!, animated: true)
        }
        
        return findFlag
    }
    
    // 跳转到普通用户个人主页
    func gotoUserPage(uid: String) {
        
        stopMoviePlayBack()
        
        if checkNavChildController(uid, role_type: 1) {
            return
        }
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSUserPersonalInfoViewController") as! YSUserPersonalInfoViewController
        controller.fuid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到评委个人主页
    func gotoJudgePage(uid: String) {
        
        stopMoviePlayBack()
        
        if checkNavChildController(uid, role_type: 2) {
            return
        }
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.Judge
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到老师个人主页
    func gotoTeacherPage(uid: String) {
        
        stopMoviePlayBack()
        
        if checkNavChildController(uid, role_type: 3) {
            return
        }
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.role_type = RoleType.Tutor
        controller.aid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到既是评委又是老师的个人主页
    func gotoJNTPage(uid: String) {
        
        stopMoviePlayBack()
        
        if checkNavChildController(uid, role_type: 4) {
            return
        }
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.JudgeAndTutor
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //发送评论
    func sendComment() {
        
        self.view.endEditing(true)
        
        if !ysApplication.loginUser.getUser()
        {
           // ysApplication.switchViewController(HOME_VIEWCONTROLLER)
            gotoLogin()
            return
        }
        
        //判断输入内容是否符合要求
        if checkInputEmpty(textView.text) {
            return
        }
        
        if detail == nil || detail.uid_status == nil {
            return
        }
        
        if detail.uid_status.integerValue == 2 {
            tips.showTipsInMainThread(Text: "评委或老师只能评论一次同一个作品")
            return
        }
        
        let tText = textView.text
        //提交评论
        YSDiscovery.comment(detail.wid, content: textView.text) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            //刷新评论列表
            let user_comment = YSDiscoveryComment()
            let image = UIImage(contentsOfFile: MovieFilesManager.getUserLocalAvatarPath()!)
            var imagePath: String? = MovieFilesManager.getUserLocalAvatarPath()!
            if image == nil {
                imagePath = DEFAULT_AVATAR
            }
            user_comment.avatar = imagePath
            user_comment.uid = ysApplication.loginUser.uid
            user_comment.content = tText
//            user_comment.commentator_type = ysApplication.loginUser.role_type.toInt()!
            user_comment.commentator_type = Int(ysApplication.loginUser.role_type)
            user_comment.username = (ysApplication.loginUser.nickName == nil) ? "易赛用户" : ysApplication.loginUser.nickName
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            user_comment.update_time = formatter.stringFromDate(NSDate())
            
            if self!.detail.uid_status == nil {
                
            }
            
            let handleRoleType: Bool = (self!.detail.uid_status.integerValue == 1 && (ysApplication.loginUser.role_type == UserRoleType.Judge.rawValue || ysApplication.loginUser.role_type == UserRoleType.Teacher.rawValue || ysApplication.loginUser.role_type == UserRoleType.TeacherAndJudge.rawValue))
            if handleRoleType {
                self!.detail.uid_status =
                    NSNumber(integer: 2)
                self!.detail.lst_comment_judge_teacher.insert(user_comment, atIndex: 0)
            } else {
                self!.detail.lst_comment_normal.insert(user_comment, atIndex: 0)
            }
            
            self!.tableView.reloadData()
        }
        
        textView.text = ""
        loc_bottomView_height.constant = 51
    }
    //友盟分享
    func gotoUMSocial(sender: UIButton!) {

        if detail == nil || wid == nil {
            return
        }
        
        popView.hide()
        
        /* the video image isn't here */
        if videoImage == nil {
            return
        }
        
        if sender.tag - 1000 == 2 || sender.tag - 1000 == 4 {
            // 没有安装QQ
            if !QQApiInterface.isQQInstalled() {
                let alertView = UIAlertView(title: "温馨提示", message: "您的设备没有安装腾讯QQ", delegate: nil, cancelButtonTitle: "确定")
                UIApplication.sharedApplication().keyWindow?.addSubview(alertView)
                alertView.show()
                return
            }
        }
        
        var shareText = "我是“\(detail.username)” ，我表演的“\(detail.title)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
//        var shareTitle = ""
        let snsNameArray = [UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQzone, UMShareToSina, UMShareToQQ]
        let snsName = snsNameArray[sender.tag - 1000]
        let shareURL = "http://www.eysai.com:8014/share/workDetail/workDetail.html?wid=\(wid)"
        switch (sender.tag - 1000) {
        case 0:
//            shareText = "么么哒"
            UMSocialData.defaultData().extConfig.wechatSessionData.title = "【易赛】" + self.detail.title
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareURL
        case 1:
            UMSocialData.defaultData().extConfig.wechatTimelineData.title = "【易赛】" + self.detail.title
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareURL
        case 2:
//            shareText = "么么哒"
            UMSocialData.defaultData().extConfig.qzoneData.title = "【易赛】" + self.detail.title
            UMSocialData.defaultData().extConfig.qzoneData.url = shareURL
        case 3:
//            shareText = "【\(self.detail.title)】" + shareURL + "#易赛#"
            UMSocialData.defaultData().urlResource.url = shareURL
            shareText += shareURL
        default:
//            shareText = "么么哒"
            UMSocialData.defaultData().extConfig.qqData.title = "【易赛】" + self.detail.title
            UMSocialData.defaultData().extConfig.qqData.url = shareURL
        }
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(snsName)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: videoImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(snsName)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            if detail == nil || detail.lst_comment_judge_teacher == nil {
                return 0
            }
            return detail.lst_comment_judge_teacher.count
        default:
            return detail != nil && detail.lst_comment_normal != nil ? detail.lst_comment_normal.count : 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let topCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryTopCell")
            
            if detail == nil {
                return topCell!
            }
            
            let img_avatar = topCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_username = topCell!.contentView.viewWithTag(12) as! UILabel
            let lab_title = topCell!.contentView.viewWithTag(13) as! UILabel
            let btn_clickPraise = topCell!.contentView.viewWithTag(21) as! UIButton
            let img_praise = topCell!.contentView.viewWithTag(22) as! UIImageView
            let lab_praise = topCell!.contentView.viewWithTag(23) as! UILabel
            let lab_video_view = topCell!.contentView.viewWithTag(31) as! UILabel
            let lab_update_date = topCell!.contentView.viewWithTag(32) as! UILabel
            let lab_tag = topCell!.contentView.viewWithTag(33) as! UILabel
            
            img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(detail.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.detail.avatar).0
                })
            lab_username.text = detail.username
            lab_title.text = detail.title
            img_praise.image = UIImage(named: detail.praise_status.integerValue == 0 ? "xqy_zan" : "xqy_zanhongxin")
            btn_clickPraise.addTarget(self, action: "praise:", forControlEvents: .TouchUpInside)
            objc_setAssociatedObject(btn_clickPraise, &AssociatedKeys.GetTopCell, topCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            lab_praise.text = "\(detail.praise_count)"
            lab_video_view.text = detail.video_view
            lab_update_date.text = handleTime(detail.update_time, style: 1)
            lab_tag.text = detail.category_name
            
            return topCell!
            
        } else if indexPath.section == 1 {
            
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryNormalCell")
            
            if detail == nil && detail.lst_comment_judge_teacher != nil {
                return normalCell!
            }
            
            let comment_judge_teacher = detail.lst_comment_judge_teacher[indexPath.row]
            let img_avatar = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_username = normalCell!.contentView.viewWithTag(12) as! UILabel
            let lab_content = normalCell!.contentView.viewWithTag(13) as! UILabel
            let lab_date = normalCell!.contentView.viewWithTag(14) as! UILabel
            let btn_avatar = normalCell!.contentView.viewWithTag(15) as! UIButton
            
            //jason 
            
            if ysApplication.loginUser.uid != nil
            {
                if comment_judge_teacher.uid == ysApplication.loginUser.uid
                {
                    img_avatar.image = UIImage(named: MovieFilesManager.getUserLocalAvatarPath()!)
                }
                else
                {
                    img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(comment_judge_teacher.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        img_avatar.image = self!.feiOSHttpImage.loadImageInCache(comment_judge_teacher.avatar).0
                        })

                }
            } else {
                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(comment_judge_teacher.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(comment_judge_teacher.avatar).0
                    })
            }
            
            btn_avatar.addTarget(self, action: "touchNormalCellAvatar:", forControlEvents: .TouchUpInside)
            
            objc_setAssociatedObject(btn_avatar, &AssociatedKeys.GetCommentUser, comment_judge_teacher, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            lab_username.text = comment_judge_teacher.username
            lab_content.text = comment_judge_teacher.content
            for constraint in lab_content.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = lab_content.sizeThatFits(CGSize(width: SCREEN_WIDTH - 59, height: 15)).height
                    break
                }
            }
            lab_date.text = comment_judge_teacher.update_time
            
            return normalCell!
            
        } else {
            
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryNormalCell")
            
            if detail == nil && detail.lst_comment_normal != nil {
                return normalCell!
            }
            
            let comment_normal = detail.lst_comment_normal[indexPath.row]
            let img_avatar = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_username = normalCell!.contentView.viewWithTag(12) as! UILabel
            let lab_content = normalCell!.contentView.viewWithTag(13) as! UILabel
            let lab_date = normalCell!.contentView.viewWithTag(14) as! UILabel
            let btn_avatar = normalCell!.contentView.viewWithTag(15) as! UIButton
            
            
            if( ysApplication.loginUser.uid  != nil)
            {
                if comment_normal.uid == ysApplication.loginUser.uid {
                    if UIImage(contentsOfFile: MovieFilesManager.getUserLocalAvatarPath()!) == nil {
                        img_avatar.image = UIImage(named: DEFAULT_AVATAR)
                    } else {
                        img_avatar.image = UIImage(contentsOfFile: MovieFilesManager.getUserLocalAvatarPath()!)
                    }
                }
            } else {
                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(comment_normal.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(comment_normal.avatar).0
                    })
            }
            
            lab_username.text = comment_normal.username
            lab_content.text = comment_normal.content
            lab_date.text = comment_normal.update_time
            btn_avatar.addTarget(self, action: "touchNormalCellAvatar:", forControlEvents: .TouchUpInside)
            
            objc_setAssociatedObject(btn_avatar, &AssociatedKeys.GetCommentUser, comment_normal,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            for constraint in lab_content.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = lab_content.sizeThatFits(CGSize(width: SCREEN_WIDTH - 59, height: 15)).height
                    break
                }
            }
            
            return normalCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 87.0
        } else {
            if detail == nil{
                return 0
            }
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 8 - 51, height: 15))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.ByCharWrapping
            label.font = UIFont.systemFontOfSize(15.0)
            var comment: YSDiscoveryComment!
            if indexPath.section == 1 {
                if detail.lst_comment_judge_teacher.count < 1 {
                    return 0
                }
                
                comment = detail.lst_comment_judge_teacher[indexPath.row]
                
            } else {
                if detail.lst_comment_normal.count < 1 {
                    return 0
                }
                
                comment = detail.lst_comment_normal[indexPath.row]
            }
            label.text = comment.content
            let height = calculateLabelHeight(label)
            let resp_height = height <= 19 ? 19 :height
            return 31.0 + resp_height
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            if detail == nil {
                return 0.0
            }
            
            if detail.lst_comment_judge_teacher == nil {
                if section == 1 {
                    
                }
            }
            return 5.0
        }
    }
    
    // MARK: - Actions
    
    func tapImageVideo(tapGesture: UITapGestureRecognizer) {
        
        handleNetwork()
    }
    
    func share() {
        
        /* umsocial */
        if popView == nil {
            popView = MZPopView()
        }
        popView.initView(self.view.bounds)
        self.navigationController?.view.addSubview(popView)
        popView.show()
        for (var i = 0; i < 5; i++) {
            let button = popView.contentView.viewWithTag(1000+i) as! UIButton
            button.addTarget(self, action: "gotoUMSocial:", forControlEvents: .TouchUpInside)
        }
    }
    
    func popToBack() {
        
        stopMoviePlayBack()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func touchTopCellAvatar(button: UIButton) {
        
        if detail == nil || detail.uid == nil {
            return
        }
        
        if !ysApplication.loginUser.getUser()
        {
           // ysApplication.switchViewController(HOME_VIEWCONTROLLER)
             gotoLogin()
            return
        }
        
        if detail.uid == ysApplication.loginUser.uid {
            return
        }
        
        //gotoUserPage(detail.uid)
        switch detail.workuid_role {
        case 1:
            gotoUserPage(detail.uid)
        case 2:
            gotoJudgePage(detail.uid)
        case 3:
            gotoTeacherPage(detail.uid)
        case 4:
            gotoJNTPage(detail.uid)
        default:
            break
        }

        
    }
    
    @IBAction func touchNormalCellAvatar(button: UIButton) {
        
        let comment = objc_getAssociatedObject(button, &AssociatedKeys.GetCommentUser) as? YSDiscoveryComment
        if comment == nil || comment?.commentator_type == nil || comment?.uid == nil {
            return
        }
        
        if !ysApplication.loginUser.getUser()
        {
            //ysApplication.switchViewController(HOME_VIEWCONTROLLER)
             gotoLogin()
            return
        }
        
        // 0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
        switch comment!.commentator_type {
        case 1:
            gotoUserPage(comment!.uid)
        case 2:
            gotoJudgePage(comment!.uid)
        case 3:
            gotoTeacherPage(comment!.uid)
        case 4:
            gotoJNTPage(comment!.uid)
        default:
            break
        }
    }
 //MARK: - ?????
    func praise(button: UIButton) {
        
        let cell = objc_getAssociatedObject(button, &AssociatedKeys.GetTopCell) as? UITableViewCell
        if cell == nil {
            return
        }
        //未登录
        if ysApplication.loginUser.uid == nil
        {
             //ysApplication.switchViewController(HOME_VIEWCONTROLLER)
             gotoLogin()
            return
        }
        
        let view = cell!.contentView.viewWithTag(20)
        let img_praise = view!.viewWithTag(22) as! UIImageView
        let lab_praise = view!.viewWithTag(23) as! UILabel
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            img_praise.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                img_praise.transform = CGAffineTransformIdentity
            })
        })
        
        if detail == nil {
            return
        }
        
        var status = detail.praise_status.integerValue
        
        if !praiseStatus {
            
            praiseStatus = true
            YSDiscovery.praise(status, wid: detail.wid, block: { [weak self] (errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                self!.detail.praise_status = NSNumber(integer: self!.detail.praise_status.integerValue == 0 ? 1 : 0)
                lab_praise.text = "\((lab_praise.text! as NSString).integerValue + (status == 0 ? 1 : -1))"
                status = self!.detail.praise_status.integerValue
                img_praise.image = UIImage(named: status == 0 ? "xqy_zan" : "xqy_zanhongxin")
                
                self!.praiseStatus = false
            })
        }
    }

    @IBAction func sendComment(sender: AnyObject) {
        
        sendComment()
    }
    
    // MARK: Notification
    
    func keyboardWillShow(notification: NSNotification) {
        
        let kbSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
//        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.loc_bottomView_bottom.constant = kbSize!.height

        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
//        let kbSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
//        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.loc_bottomView_bottom.constant = 0
        }, completion: nil)
    }
    
    // MARK: UITextViewDelegate 
    
    func textViewDidChange(textView: UITextView) {
        
        var height = textView.contentSize.height + 10 + 8
        if height <= 51 {
            height = 51
        } else if height >= maxTextHeight {
            height = maxTextHeight
        }
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            if self == nil {
                return
            }
            
            self!.loc_bottomView_height.constant = height
        })
        
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            sendComment()
        }
        
        return true
    }
    
    // MARK: - Notification
    
    func moviePlayerWillEnterFullscreen(notification: NSNotification) {
        
        fullscreen = true
    }
    
    func moviePlayerWillExitFullscreen(notification: NSNotification) {
        
        fullscreen = false
    }
    
    func hidePopView() {
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
    }
    
    func playbackSuccess(notification: NSNotification) {
        
        // 播放成功
        MobClick.event("video_loaded", attributes: ["result": "success"])
    }
    
    func playbackFailed(notification: NSNotification) {
        
        // 播放失败
        MobClick.event("video_loaded", attributes: ["result": "failure"])
    }
    
    // MARK: - UMSocial Delegate
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        //        if (response.responseCode == UMSResponseCode.UMSResponseCodeSuccess) {
        //
        //        }
    }
    
    func gotoLogin() {
        
        //   ysApplication.switchViewController(HOME_VIEWCONTROLLER)
        
        // print("hahahah")
        let controller = YSLoginViewController()
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        
        self.navigationController!.view.layer .addAnimation(transition, forKey: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
}
