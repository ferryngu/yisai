//
//  YSJudgeIntroductionViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/25.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSJudgeIntroductionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let NewestColor = UIColor(red: 232.0/255.0, green: 158.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private let OldColor = UIColor(red: 167.0/255.0, green: 214.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    private let ExperienceInfoWidth = SCREEN_WIDTH - 81.0 - 25.0
    
    var tips: FETips = FETips()
    var fuid: String!
    var judge_qualification: YSJudgeQualification!
    var tLabel: UILabel!
    var movieController: MoviePlayerController!
    var networkStatus: AFNetworkReachabilityStatus = .ReachableViaWiFi
    var img_video: UIImageView!
    var feiOSHttpImage:FEiOSHttpImage = FEiOSHttpImage()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        tLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ExperienceInfoWidth, height: 21))
        tLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        tLabel.numberOfLines = 0
        
        fetchJudgeIntro()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configurePlayer()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if movieController != nil && movieController.moviePlayer != nil {
            movieController.stopPlayingVideo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func gotoWebview(sender: AnyObject) {
        
        if fuid == nil {
            return
        }
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
        controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/judge_introduction/judge_introduction.html?uid=\(ysApplication.loginUser.uid)&loginkey=\(ysApplication.loginUser.loginKey)&fuid=\(fuid)")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchJudgeIntro() {
        
        if fuid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchJudgeQualification(fuid, block: { [weak self] (resp_judge_qualification: YSJudgeQualification!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.judge_qualification = resp_judge_qualification
            self!.configureContainerView()
            self?.tableView.reloadData()
        })
    }
    
    func configureContainerView() {
        
        if judge_qualification == nil {
            return
        }
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        if judge_qualification.video_url != nil && judge_qualification.video_url != "" {
            
            configureBtnPlay()
            
        } else {
            
            if judge_qualification.lst_picture == nil || judge_qualification.lst_picture.count < 1 {
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: containerView.bounds.size.height))
                imageView.image = UIImage(named: DEFAULT_IMAGE_NAME_RECTANGLE)
                imageView.clipsToBounds = true
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                containerView.addSubview(imageView)
                return
            }
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.containerView.bounds.size.height))
            
            scrollView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(judge_qualification.lst_picture.count), height: self.containerView.bounds.size.height)
            
            for index in 0..<judge_qualification.lst_picture.count {
                let picture = judge_qualification.lst_picture[index]
                let imageView = UIImageView(frame: CGRect(x: SCREEN_WIDTH * CGFloat(index), y: 0, width: SCREEN_WIDTH, height: self.containerView.bounds.size.height))
                imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(picture, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    imageView.image = self!.feiOSHttpImage.loadImageInCache(picture).0
                    })
                imageView.clipsToBounds = true
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                scrollView.pagingEnabled = true
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.showsVerticalScrollIndicator = false
                scrollView.bounces = false
                scrollView.addSubview(imageView)
            }
            containerView.addSubview(scrollView)
        }
    }
    
    func configureBtnPlay() {
        
//        if img_video == nil {
//            img_video = UIImageView(frame: containerView.bounds)
//            containerView.addSubview(img_video)
//        }
//        if judge_qualification != nil || judge_qualification.video_img_url != nil {
//            
//            img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(judge_qualification.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
//                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
//                if self == nil { return }
//                self!.img_video.image = self!.feiOSHttpImage.loadImageInCache(self!.judge_qualification.video_img_url).0
//                })
//            
//        }
//        img_video.contentMode = UIViewContentMode.ScaleAspectFill
//        img_video.clipsToBounds = true
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "tapImageVideo:")
//        img_video.addGestureRecognizer(tapGesture)
        
        handleNetwork()
    }
    
    func configurePlayer() {
        
        if movieController == nil && judge_qualification != nil && judge_qualification.video_url != nil && judge_qualification.video_url != "" {
        
            movieController = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
            movieController.contentURL = NSURL(string: judge_qualification.video_url)
            self.addChildViewController(movieController)
            movieController.view.frame = self.containerView.bounds
            self.containerView.addSubview(movieController.view)
//            movieController.setupPlayingVideo()
            movieController.didMoveToParentViewController(self)
        }
    }
    
    func handleNetwork() {
        
        networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
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
            self.networkStatus = AFNetworkReachabilityStatus.ReachableViaWWAN
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续观看?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
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
    
    func tapImageVideo(tapGesture: UITapGestureRecognizer) {
        handleNetwork()
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return judge_qualification == nil ? 0 : 1 + judge_qualification.lst_qualification.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("YSJudgeIntroTopCell", forIndexPath: indexPath)
            
            if judge_qualification == nil {
                return cell
            }
            
            let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
            let lab_name = cell.contentView.viewWithTag(12) as! UILabel
            let lab_intro = cell.contentView.viewWithTag(13) as! UILabel
            
            img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(judge_qualification.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.judge_qualification.avatar).0
                })
            
            lab_name.text = judge_qualification.realname
            lab_intro.text = judge_qualification.introduction
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSJudgeIntroNormalCell", forIndexPath: indexPath) 
            
            if judge_qualification == nil || judge_qualification.lst_qualification == nil || judge_qualification.lst_qualification.count < 1 {
                return cell
            }
            
            let qualification = judge_qualification.lst_qualification[indexPath.row - 1]
            
            let leftLine = cell.contentView.viewWithTag(11)!
            let leftDot = cell.contentView.viewWithTag(12) as! UIImageView
            let lab_date = cell.contentView.viewWithTag(13) as! UILabel
            let lab_competitionName = cell.contentView.viewWithTag(14) as! UILabel
            let img_contentBg = cell.contentView.viewWithTag(15) as! UIImageView
            
            if indexPath.row == 1 {
                leftLine.backgroundColor = NewestColor
                leftDot.image = UIImage(named: "cs_shijianzhouhongdian")
                img_contentBg.image = UIImage(named: "hj_wenbenkuang")
            } else {
                leftLine.backgroundColor = OldColor
                leftDot.image = UIImage(named: "cs_shijianzhoulandian")
                img_contentBg.image = UIImage(named: "hj_wenbenkuanglan")
            }
            
            lab_date.text = qualification.update_time
            lab_competitionName.text = qualification.match_name
            
            let labelHeight = lab_competitionName.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
            for constraint in lab_competitionName.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = labelHeight > 17 ? labelHeight : 17
                }
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            if judge_qualification == nil {
                return 68.0
            }
            
            let introduction = judge_qualification.introduction
            tLabel.font = UIFont.systemFontOfSize(16.0)
            tLabel.text = introduction
            
            let labelHeight = tLabel.sizeThatFits(CGSize(width: SCREEN_WIDTH - 88, height: 9999)).height
            
            return labelHeight + 48
            
        } else {
            
            if judge_qualification == nil || judge_qualification.lst_qualification.count < 1 {
                return 0
            }
            
            let qualification = judge_qualification.lst_qualification[indexPath.row - 1]
            tLabel.font = UIFont.systemFontOfSize(17.0)
            tLabel.text = qualification.match_name
            let labelHeight = tLabel.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
            return 69 + labelHeight + 10
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if judge_qualification == nil || judge_qualification.lst_qualification.count < 1 {
            return 0
        }
        return 60
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if judge_qualification == nil || judge_qualification.lst_qualification.count < 1 {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        view.backgroundColor = UIColor.clearColor()
        
        let leftView = UIView(frame: CGRect(x: 46, y: 0, width: 1, height: 60))
        
        if judge_qualification.lst_qualification.count == 1 {
            leftView.backgroundColor = NewestColor
        } else {
            leftView.backgroundColor = OldColor
        }
        
        view.addSubview(leftView)
        
        return view
    }
}
