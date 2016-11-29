//
//  YSCompetitionDetailViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/23.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MessageUI

class YSCompetitionDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MFMessageComposeViewControllerDelegate, UMSocialUIDelegate {
    
    private struct AssociatedObject {
        static var GetTopCell = "GetTopCell"
        static var GetShowIntroBtn = "GetShowIntroBtn"
        static var GetShowRulesBtn = "GetShowRulesBtn"
    }



    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_competition: UIButton!

    
    var cpid: String! // 赛事ID
    var competitionDetail: YSCompetitionDetail!
    var showAllIntro: Bool = false
    var showAllRules: Bool = false
    var errorText: String!
    var videoImage: UIImage!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var popView: MZPopView!
    
    let judgeViewWidth = SCREEN_WIDTH / 4
    let judgeViewHeight = SCREEN_WIDTH / 4 - 20 + 5 + 8 + 14 + 11 + 8

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.duration = 1
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        errorText = nil
        
        tableView.reloadData()
        
        fetchDetail()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - YSReuseImageNotification

    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchDetail() {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getCompetitionDetail(cpid, resp: { [weak self] (resp_detail: YSCompetitionDetail!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.competitionDetail = resp_detail
            self!.fetchDetailImage()
            self!.configureCompetitionBtn()
            self!.tableView.reloadData()
        })
    }
    
    /* load detail image */
    func fetchDetailImage() {
        
        if competitionDetail == nil {
            return
        }
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {[weak self] () -> Void in
            dispatch_sync(queue, { () -> Void in
                
                if self == nil {
                    return
                }
                
                let urlAsString = self!.competitionDetail.institution_logo
                
                guard let url = NSURL(string: urlAsString) else { return }
                
                let urlRequest = NSURLRequest(URL: url)
//                var downloadError: NSError?
                
//                let imageData = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: nil, error: &downloadError)
                let imageData:NSData?
                do {
                    imageData = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: nil)
                    if self != nil && imageData != nil && imageData?.length > 0 {
                        self!.videoImage = UIImage(data: imageData!)
                    }
                }catch let error as NSError {
                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                    return
                }
            })
        })
    }
    
    func configureCompetitionBtn() {
        
        if competitionDetail == nil || competitionDetail.competition_process == nil {
            return
        }
        
        var titleText = ""
        switch competitionDetail.competition_process.integerValue {
        case 0:
            
            titleText = "赛事尚未开始"
            btn_competition.enabled = true
            errorText = "赛事尚未开始"
            btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
        case 1:
            
            btn_competition.enabled = true
            // 不是普通用户
            titleText = "我要参赛"
            
//            if competitionDetail.competition_type == "1" {
//                
//                errorText = "该赛事为线下赛事"
//                btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
//            }
            if !ysApplication.loginUser.getUser()
            {
               btn_competition.addTarget(self, action: "gotoLogin", forControlEvents: .TouchUpInside)
                break
            }
            
            
            if  ysApplication.loginUser.role_type == "2" {
                
                errorText = "评委无法报名"
                btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                break
            } else if competitionDetail.user_competing_process == nil {
                break
            }
            
            btn_competition.removeTarget(self, action: "gotoLogin", forControlEvents: UIControlEvents.TouchUpInside)
            
            // 当前登录角色为普通用户
            if (competitionDetail.user_competing_process.integerValue == 0) {
                //参加比赛
                if ysApplication.loginUser.role_type == "1"
                {
                    btn_competition.addTarget(self, action: "gotoCompetition:", forControlEvents: .TouchUpInside)
                }
                else
                {
                    titleText = "帮学生报名"
                    btn_competition.addTarget(self, action: "gotoStudent:", forControlEvents: .TouchUpInside)
                    
                    
                }
                
            } else if competitionDetail.user_competing_process.integerValue == 1
            {
                if competitionDetail.competition_type == nil {
                    break
                }
                
                if ysApplication.loginUser.role_type == "1"
                {
                    if competitionDetail.competition_type == "1" {
                        // 线下赛事
                       // titleText = "报名成功"
                      //  errorText = "该赛事已报名"
                      //  btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                       // btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                        
                        titleText = "未支付"
                        btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                        btn_competition.addTarget(self, action: "gotoPay:", forControlEvents: .TouchUpInside)
                        
                        

                        break
                    }
                    else
                    {
                      let dic = fe_std_data_get_json("YSUploadState", key: ysApplication.loginUser.uid +  competitionDetail.cpid)
                        
                        if(dic == nil)
                        {
                            // 报名成功但没有提交作品
                            titleText = "赛事作品尚未提交"
                            btn_competition.addTarget(self, action: "gotoPublish:", forControlEvents: .TouchUpInside)
                        }
                        else
                        {
                            titleText = "作品已上传，请等候"
                            errorText = "该赛事已上传视频"
                            btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                            btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)

                        }
                    }
                }
                else
                {
                    titleText = "帮学生报名"
                    btn_competition.addTarget(self, action: "gotoStudent:", forControlEvents: .TouchUpInside)
                    break
                }
                //  } else if competitionDetail.user_competing_process.integerValue == 3 {
                
    
                

            }
            else if competitionDetail.user_competing_process.integerValue == 3 {
                
                if competitionDetail.competition_type == nil {
                    break
                }
                
                if ysApplication.loginUser.role_type == "1"
                {
                    if competitionDetail.user_upload_status.integerValue == 0
                    {
                        if competitionDetail.competition_type == "1" {
                            // 线下赛事
                            titleText = "未支付"
                            btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                            btn_competition.addTarget(self, action: "gotoPay:", forControlEvents: .TouchUpInside)
                            
                            break
                        }else{
                        // 报名成功但没有提交作品
                        //titleText = "赛事作品尚未提交"
                        //btn_competition.addTarget(self, action: "gotoPublish:", forControlEvents: .TouchUpInside)
                            let dic = fe_std_data_get_json("YSUploadState", key: ysApplication.loginUser.uid +  competitionDetail.cpid) as? Dictionary<String,String>
                            
                            
                            
                            if(dic != nil)
                            {
                                // 报名成功但没有提交作品
                                titleText = "作品已上传，请等候"
                                errorText = "该赛事已上传视频"
                                btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                                btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                                
                            }
                            else
                            {
                                
                                titleText = "赛事作品尚未提交"
                                btn_competition.addTarget(self, action: "gotoPublish:", forControlEvents: .TouchUpInside)
                                
                            }

                        }
                    }
                    else
                    {
                        titleText = "未支付"
                        btn_competition.addTarget(self, action: "gotoPay:", forControlEvents: .TouchUpInside)
                        
                    }
                }
                else
                {
                     titleText = "帮学生报名"
                     btn_competition.addTarget(self, action: "gotoStudent:", forControlEvents: .TouchUpInside)
                }
                
            } else if competitionDetail.user_competing_process.integerValue == 4 {
                if ysApplication.loginUser.role_type == "1"
                {
                    if competitionDetail.competition_type == "1" {
                        // 线下赛事
                        titleText = "报名成功"
                        errorText = "该赛事已报名"
                        btn_competition.removeTarget(self, action: "gotoCompetition:", forControlEvents: UIControlEvents.TouchUpInside)
                        btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                        
                    }
                    else
                    {
                        titleText = "资料已提交，请等待评分结果"
                        errorText = "资料已提交，请等待评分结果"
                        btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                    }
                }
                else
                {
                    titleText = "帮学生报名"
                    btn_competition.addTarget(self, action: "gotoStudent:", forControlEvents: .TouchUpInside)
                }
            }
        case 2:
            
            titleText = "赛事评分阶段"
            btn_competition.enabled = true
            if ysApplication.loginUser.role_type != nil
            {
                if ysApplication.loginUser.role_type == "1" || ysApplication.loginUser.role_type == "3" {
                    errorText = "赛事正在评分"
                    btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                    break
                }
                
                if ysApplication.loginUser.role_type == "2" || ysApplication.loginUser.role_type == "4" {
                    if competitionDetail == nil || competitionDetail.cpid == nil {
                        break
                    }
                    
                    if competitionDetail.judge_competition_status.integerValue == 0 {
                        errorText = "你不是该赛事的评委，不能评分"
                        btn_competition.addTarget(self, action: "showTipsView", forControlEvents: .TouchUpInside)
                        break
                    }
                    
                    btn_competition.addTarget(self, action: "gotoMarking:", forControlEvents: .TouchUpInside)
                }
            }
        default:
            
            titleText = "赛事已结束,查看排名"
            btn_competition.enabled = true
            btn_competition.addTarget(self, action: "gotoRank:", forControlEvents: .TouchUpInside)
        }
        
        
        btn_competition.setTitle(titleText, forState: .Normal)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
//        if result == MessageComposeResultCancelled {
//            println("取消发送")
//        } else if result == MessageComposeResultSent {
//            println("发送成功")
//        } else {
//            println("发送失败")
//        }
    }
    
    // MARK: - Actions
    
    func showTipsView() {
        if errorText == nil {
            return
        }
        tips.showTipsInMainThread(Text: errorText)
    }
    
    func tapAvatar(tap: UITapGestureRecognizer) {
        
        if tap.view == nil {
            return
        }
        
        let index = tap.view!.tag - 100
        let judge = competitionDetail.lst_competition_judge[index]
        
        if judge.uid == nil {
            return
        }
        
        let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSJudgeIntroductionViewController") as! YSJudgeIntroductionViewController
        controller.fuid = judge.uid
        controller.title = judge.realname
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func share(sender: AnyObject) {

        /* umsocial */
        if popView == nil {
            popView = MZPopView()
            popView.style = 1
        }
        popView.initView(self.navigationController!.view.bounds)
        self.navigationController?.view.addSubview(popView)
        popView.show()
        for (var i = 0; i < 6; i++) {
            
            let button = popView.contentView.viewWithTag(1000+i) as! UIButton
            if i == 5 {
                
                button.addTarget(self, action: "gotoiMessage:", forControlEvents: .TouchUpInside)
            } else {
                button.addTarget(self, action: "gotoUMSocial:", forControlEvents: .TouchUpInside)
            }
        }
    }
    
    func gotoiMessage(sender: UIButton) {
        
        popView.hide()
        
        if competitionDetail == nil {
            return
        }
        
        let controller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            controller.body = "易赛天下:http://www.eysai.com:8014/share/competition_info/competition_info.html?cpid=\(competitionDetail.cpid)，快报名参加吧！"
            controller.messageComposeDelegate = self
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func gotoUMSocial(sender: UIButton!) {
        
        popView.hide()
        
        if competitionDetail == nil {
            return
        }
        
        /* the video image isn't here */
        if videoImage == nil {
            tips.showTipsInMainThread(Text: "分享图正在下载")
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
        
//        var shareText = "易赛天下:\(competitionDetail.match_name)，开始报名啦，快来参加吧！"
        var shareText = "随时随地参加比赛，一起学习，一起快乐"
//        var shareTitle = ""
        let snsNameArray = [UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQzone, UMShareToSina, UMShareToQQ]
        let snsName = snsNameArray[sender.tag - 1000]
        let shareURL = "http://www.eysai.com:8014/share/competition_info/competition_info.html?cpid=\(competitionDetail.cpid)"
        switch (sender.tag - 1000) {
        case 0:
            UMSocialData.defaultData().extConfig.wechatSessionData.title = "【易赛】" + "\(competitionDetail.match_name)，快报名参加吧！"
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareURL
        case 1:
            UMSocialData.defaultData().extConfig.wechatTimelineData.title = "【易赛】" + "\(competitionDetail.match_name)，快报名参加吧！"
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareURL
        case 2:
            UMSocialData.defaultData().extConfig.qzoneData.title = "【易赛】" + "\(competitionDetail.match_name)，快报名参加吧！"
            UMSocialData.defaultData().extConfig.qzoneData.url = shareURL
        case 3:
//            shareText = "【\(competitionDetail.match_name)】" + shareURL + "#易赛#"
            UMSocialData.defaultData().urlResource.url = shareURL
            shareText += shareURL
        default:
            UMSocialData.defaultData().extConfig.qqData.title = "【易赛】" + "\(competitionDetail.match_name)，快报名参加吧！"
            UMSocialData.defaultData().extConfig.qqData.url = shareURL
        }
//          let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(snsName)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: videoImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(snsName)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    func showAll(button: UIButton) {
        let showIntroBtn = objc_getAssociatedObject(button, &AssociatedObject.GetShowIntroBtn) as? UIButton
        let showRulesBtn = objc_getAssociatedObject(button, &AssociatedObject.GetShowRulesBtn) as? UIButton
        if showIntroBtn != nil && showIntroBtn?.hidden == false {
            showAllIntro = true
            self.tableView.reloadData()
        } else if showRulesBtn != nil && showRulesBtn?.hidden == false {
            showAllRules = true
            self.tableView.reloadData()
        }
    }
    

    
    func gotoCompetition(button: UIButton) {
        
        if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        
      /*  let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSCompetitionConfirmViewController") as! YSCompetitionConfirmViewController
        controller.competition_type = competitionDetail.competition_type
        controller.cpid = competitionDetail.cpid
 */
        
         let controller = YSCompetitionConditonViewController()
        controller.cpid = competitionDetail.cpid
        controller.competition_type = competitionDetail.competition_type
        
 
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoPublish(button: UIButton) {
        
        if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        
       /* let controller = UIStoryboard(name: "YSPublish", bundle: nil).instantiateViewControllerWithIdentifier("YSPublishViewController") as! YSPublishViewController
        controller.matchName = competitionDetail.match_name
        controller.cpid = competitionDetail.cpid
        controller.type = .Competition
        */
        
        let controller = YSCameraViewController()
        controller.matchName = competitionDetail.match_name
        controller.cpid = competitionDetail.cpid
        controller.type = .Competition
        controller.competition_type = competitionDetail.competition_type
        
        
        controller.hidesBottomBarWhenPushed = true
        
        
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
        
        self.navigationController?.navigationBarHidden = true
        
        self.navigationController!.pushViewController(controller, animated: false)
        
      //  let navController = UINavigationController(rootViewController: controller)
       // ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
       // self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func gotoPay(button: UIButton) {
        
        if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        
        let controller = YSPulishPayViewController()
        controller.cpid = self.cpid
        controller.match_name = competitionDetail.match_name
        controller.application_fee = competitionDetail.application_fee
        controller.competition_type = competitionDetail.competition_type
        
        self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    func gotoStudent(button: UIButton) {
        let controller = YSCompetionStudentViewController()
        controller.cpid = self.cpid
        controller.application_fee = competitionDetail.pay_amount
        controller.benefit_price =  competitionDetail.benefit_price
        controller.real_price = competitionDetail.application_fee
        controller.match_name = competitionDetail.match_name
        controller.competition_type = competitionDetail.competition_type
        
        
        self.navigationController?.pushViewController(controller, animated: true)
        

    }
    
    func gotoRank(button: UIButton) {
        
        if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSCompetitionRankViewController") as! YSCompetitionRankViewController
        controller.matchName = competitionDetail.match_name
        controller.cpid = competitionDetail.cpid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoMarking(button: UIButton) {
        
        if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        
        let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSMarkingFindworkViewController") as! YSMarkingFindworkViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoUpload(button: UIButton) {
        
        let storyBoard = UIStoryboard(name: "YSMine", bundle: nil)
        let uploadController = storyBoard.instantiateViewControllerWithIdentifier("YSUploadManageTableViewController") as! YSUploadManageTableViewController
        let navController : UINavigationController? = ysApplication.tabbarController.viewControllers?[2] as? UINavigationController
        navigationController?.popToRootViewControllerAnimated(false)
        navController?.popToRootViewControllerAnimated(false)
        navController?.pushViewController(uploadController, animated: true)
        ysApplication.tabbarController.selectedIndex = 2
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
        
        controller.hidesBottomBarWhenPushed = true
        self.navigationController!.view.layer .addAnimation(transition, forKey: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return competitionDetail == nil ? 0 :4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 8
        default:
            return 15
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cpIntroHeight: CGFloat = 0.0
        var cpRulesHeight: CGFloat = 0.0
        if competitionDetail != nil {
  
            
            
            let font = UIFont.systemFontOfSize(15);
            var attributes = [NSFontAttributeName: font]
            
            var size = CGRect();
            var size2 = CGSizeMake(SCREEN_WIDTH-44,CGFloat.max)
            
            let options = Utils.combine()
            
            size = competitionDetail.constitution_introduction.boundingRectWithSize(size2, options: options, attributes: attributes, context: nil);
            
            
     
            
            cpIntroHeight = size.height + 250
            
            if SCREEN_WIDTH  == 320
            {
                cpIntroHeight += 350
            }
            
             size = competitionDetail.competition_rules.boundingRectWithSize(size2, options: options, attributes: attributes, context: nil);
            
            
            cpRulesHeight =  size.height +  250
            
            if SCREEN_WIDTH  == 320
            {
                cpRulesHeight += 500
            }
            
        }
        switch indexPath.section {
        case 0:
            return SCREEN_WIDTH * 77 / 150 + 76
        case 1:
            if (competitionDetail == nil || competitionDetail.lst_competition_judge.count < 1) {
                return 42.0
            } else {
                return CGFloat((competitionDetail.lst_competition_judge.count - 1) / 4 + 1) * judgeViewHeight + 29 + 8
            }
        case 2:
            if cpIntroHeight < 75 || showAllIntro {
                return 37 + cpIntroHeight + 20
            }
            return 37 + 75 + 62
        default:
            if cpRulesHeight < 75 || showAllRules {
                return 37 + cpRulesHeight + 20
            }
            return 37 + 75 + 62
            
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...
        switch indexPath.section {
        case 0:
            let topCell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionTopCell")
            if competitionDetail == nil {
                return topCell!
            }
            
            let scrollView = topCell!.contentView.viewWithTag(21) as! UIScrollView
            let pageControl = topCell!.contentView.viewWithTag(22) as! UIPageControl
            let bgView = topCell!.contentView.viewWithTag(1)!
            let imageView = bgView.viewWithTag(12) as! UIImageView
            let lab_title = bgView.viewWithTag(13) as! UILabel
            let lab_conduct = bgView.viewWithTag(14) as! UILabel
            let lab_date = bgView.viewWithTag(15) as! UILabel
            

            imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(competitionDetail.institution_logo, defaultImageName:DEFAULT_IMAGE_NAME_SQUARE, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                
                if self == nil {
                    return
                }
                
                imageView.image = self!.feiOSHttpImage.loadImageInCache(self!.competitionDetail.institution_logo).0
            })
            
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            if competitionDetail.lst_publicity_pic.count > 0 {
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(competitionDetail.lst_publicity_pic.count), height: 0)
                pageControl.numberOfPages = competitionDetail.lst_publicity_pic.count
                
                for index in 0..<competitionDetail.lst_publicity_pic.count {
                    let publicity_pic = competitionDetail.lst_publicity_pic[index]
                    let img_publicity_pic = UIImageView(frame: CGRect(x: SCREEN_WIDTH * CGFloat(index), y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 77 / 150))
                    img_publicity_pic.image = feiOSHttpImage.asyncHttpImageInUIThread(publicity_pic, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        
                        if self == nil {
                            return
                        }
                        
                        img_publicity_pic.image = self!.feiOSHttpImage.loadImageInCache(publicity_pic).0
                    })
                    img_publicity_pic.clipsToBounds = true
                    img_publicity_pic.contentMode = .ScaleAspectFill
                    scrollView.addSubview(img_publicity_pic)
                }
            }
            
            lab_title.text = competitionDetail.match_name
            lab_conduct.text = competitionDetail.institution_name
            let tempString = NSAttributedString(string: "报名时间：\(competitionDetail.start_time)-\(competitionDetail.last_time)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.lightGrayColor()])
            let atbString1 = NSMutableAttributedString(attributedString: tempString)
            let atbString2 = NSAttributedString(string: "        已有\(competitionDetail.register_number)人参赛", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.redColor()])
            atbString1.insertAttributedString(atbString2, atIndex: atbString1.length)
            lab_date.attributedText = atbString1
            lab_date.minimumScaleFactor = 0.5
            
            objc_setAssociatedObject(self, &AssociatedObject.GetTopCell, topCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return topCell!
        case 1:
            let judgeCell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionJudgeCell")
            if (competitionDetail == nil || competitionDetail.lst_competition_judge.count < 1) {
                return judgeCell!
            }
            
            let bgView = judgeCell!.contentView.viewWithTag(100)
            
            for subView in bgView!.subviews {
                subView.removeFromSuperview()
            }
            
            let imgWidth = judgeViewWidth - 10
            for index in 0..<competitionDetail.lst_competition_judge.count {
//                let competition_judge = competitionDetail.lst_competition_judge[index]
                let cp_judge = competitionDetail.lst_competition_judge[index]
                
                let t_view = UIView(frame: CGRect(x: judgeViewWidth * CGFloat(index % 4), y: judgeViewHeight * CGFloat(index / 4), width: judgeViewWidth, height: judgeViewHeight))
                view.backgroundColor = UIColor.clearColor()
                bgView!.addSubview(t_view)
                
                let img_judge = UIImageView(frame: CGRect(x: 5, y: 10, width: imgWidth, height: imgWidth))
                img_judge.userInteractionEnabled = true
                img_judge.layer.cornerRadius = imgWidth / 2
                img_judge.clipsToBounds = true
                img_judge.tag = 100 + index
                img_judge.contentMode = .ScaleAspectFit
                img_judge.image = feiOSHttpImage.asyncHttpImageInUIThread(cp_judge.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    
                    if self == nil {
                        return
                    }
                    let temp_image = self!.feiOSHttpImage.loadImageInCache(cp_judge.avatar).0
                    print(temp_image.size.width,temp_image.size.height)
                    img_judge.image = temp_image
                })
                t_view.addSubview(img_judge)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "tapAvatar:")
                img_judge.addGestureRecognizer(tapGesture)
                
                let lab_name = UILabel(frame: CGRect(x: 0, y: 5 + imgWidth + 8, width: judgeViewWidth, height: 14))
                lab_name.font = UIFont.systemFontOfSize(14)
                lab_name.textAlignment = NSTextAlignment.Center
                lab_name.text = cp_judge.realname
                t_view.addSubview(lab_name)
                
                let lab_intro = UILabel(frame: CGRect(x: 0, y: 5 + imgWidth + 8 + 14, width: judgeViewWidth, height: 11))
                lab_intro.font = UIFont.systemFontOfSize(11)
                lab_intro.textAlignment = NSTextAlignment.Center
                lab_intro.textColor = UIColor.lightGrayColor()
                lab_intro.text = cp_judge.introduction
                t_view.addSubview(lab_intro)
            }
            
        
            
            for constraint in bgView!.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = CGFloat((competitionDetail.lst_competition_judge.count - 1) / 4 + 1) * judgeViewHeight
                }
            }
            
            return judgeCell!
        case 2:
            let cpintroCell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionIntroCell")
            if competitionDetail == nil {
                return cpintroCell!
            }
            let lab_sectionTitle = cpintroCell!.contentView.viewWithTag(11) as! UILabel
            lab_sectionTitle.text = "赛事章程"
            
            let lab_intro = cpintroCell!.contentView.viewWithTag(12) as! UILabel
            lab_intro.text = competitionDetail.constitution_introduction
            let show_view = cpintroCell!.contentView.viewWithTag(13)
            
          
            var font = UIFont.systemFontOfSize(15);
            var attributes = [NSFontAttributeName: font]
            
            var size = CGRect();
            var size2 = CGSizeMake(SCREEN_WIDTH-44,CGFloat.max)
            let options = Utils.combine()
            
            size = competitionDetail.constitution_introduction.boundingRectWithSize(size2, options: options, attributes: attributes, context: nil);
            
            
            
            
          
          
            
           var  labHeight = size.height + 250
            
            if SCREEN_WIDTH  == 320
            {
                labHeight += 350
            }
          //  let labHeight = lab_intro.sizeThatFits(CGSize(width: SCREEN_WIDTH-44, height: 9999)).height + 50
            
            
            for constraint in lab_intro.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    if labHeight <= 75 || showAllIntro {
                        constraint.constant = labHeight
                    } else {
                        constraint.constant = 75.0
                    }
//                    break
                }
            }
//            introHeight.constant = labHeight
            if labHeight < 75 {
                show_view!.hidden = true
            } else {
                show_view!.hidden = showAllIntro
                let btn_show = show_view!.viewWithTag(11) as! UIButton
                objc_setAssociatedObject(btn_show, &AssociatedObject.GetShowIntroBtn, btn_show, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn_show.addTarget(self, action: "showAll:", forControlEvents: .TouchUpInside)
            }
            
            return cpintroCell!
        default:
            if indexPath.row == 0 {
                let cpintroCell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionIntroCell")
                
                if competitionDetail == nil {
                    return cpintroCell!
                }
                
                let lab_sectionTitle = cpintroCell!.contentView.viewWithTag(11) as! UILabel
                lab_sectionTitle.text = "赛事规则"
                
                let lab_intro = cpintroCell!.contentView.viewWithTag(12) as! UILabel
                
                lab_intro.text = competitionDetail.competition_rules
                
                let show_view = cpintroCell!.contentView.viewWithTag(13)
                
                
                var font = UIFont.systemFontOfSize(15);
                var attributes = [NSFontAttributeName: font]
                
                var size = CGRect();
                var size2 = CGSizeMake(SCREEN_WIDTH-44,CGFloat.max)
                
                let options = Utils.combine()
                
                size = competitionDetail.competition_rules.boundingRectWithSize(size2, options: options, attributes: attributes, context: nil);
               
                
              
                
                var labHeight = size.height +  250
                
                if SCREEN_WIDTH  == 320
                {
                    labHeight += 500
                }
                
                
                lab_intro.bounds.size = CGSize(width: SCREEN_WIDTH-44, height: labHeight)
                for constraint in lab_intro.constraints {
                    if constraint.firstAttribute == NSLayoutAttribute.Height {
                        if labHeight <= 75 || showAllRules {
                            constraint.constant = labHeight
                        } else {
                            constraint.constant = 75.0
                        }
                    }
                }
                if labHeight < 75 {
                    show_view!.hidden = true
                } else {
                    show_view!.hidden = showAllRules
                    let btn_show = show_view!.viewWithTag(11) as! UIButton
                    objc_setAssociatedObject(btn_show, &AssociatedObject.GetShowRulesBtn, btn_show, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    btn_show.addTarget(self, action: "showAll:", forControlEvents: .TouchUpInside)
                }
                
                return cpintroCell!
            } else {
                let goCpCell = tableView.dequeueReusableCellWithIdentifier("YSGoCompetitionCell")
                if competitionDetail == nil {
                    return goCpCell!
                }
//                let btn = goCpCell!.contentView.viewWithTag(11) as! UIButton
                
                
                return goCpCell!
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if objc_getAssociatedObject(self, &AssociatedObject.GetTopCell) == nil {
            return
        }
        let cell = objc_getAssociatedObject(self, &AssociatedObject.GetTopCell) as! UITableViewCell
        let pageControl = cell.contentView.viewWithTag(22) as! UIPageControl
        pageControl.currentPage = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
    }
    
    // MARK: - UMSocial Delegate
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        //        if (response.responseCode == UMSResponseCode.UMSResponseCodeSuccess) {
        //
        //        }
    }
}
