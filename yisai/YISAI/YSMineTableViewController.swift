//
//  YSMineTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMineTableViewController: UITableViewController {
    
    var tips: FETips = FETips()
    var userInfo: YSUserInfo!
    var remoteUserInfo: [NSObject : AnyObject]!
    
    var isShowFindworkBudge = false
    var isShowCompetitionBudge = false
    var isShowUploadBudge = false
    var guideView: UIImageView!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSApplicationDidReceiveRemoteNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tips = FETips()
        tips.duration = 1
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveRemoteNotification:", name: YSApplicationDidReceiveRemoteNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        
        if YSGuide.getUserGuideMine() == 0 {
            configureGuideView()
        }
        
        handleBudge()
        
        tableView.reloadData()
        
        if ysApplication.loginUser.role_type == nil {
            return
        } else {
            fetchMyInfo()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureGuideView() {
        
        if guideView != nil {
            return
        }
        
        if ysApplication.loginUser.role_type != "1" {
            return
        }
        
        guideView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        guideView.image = UIImage(named: "wd_yingdao")
        if SCREEN_WIDTH == 320 {
            guideView.image = UIImage(named: "guide_mine_320")
        } else if SCREEN_WIDTH == 375 {
            guideView.image = UIImage(named: "guide_mine_375")
        } else if SCREEN_WIDTH == 414 {
            guideView.image = UIImage(named: "guide_mine_414")
        }
        guideView.contentMode = UIViewContentMode.TopLeft
        guideView.userInteractionEnabled = true
        guideView.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGuideView:")
        guideView.addGestureRecognizer(tapGesture)
        
        ysApplication.tabbarController.view.addSubview(guideView)
    }
    
    func handleBudge() {
        
        isShowUploadBudge = false
        isShowCompetitionBudge = false
        
        let lst_uploadMovies = YSMovie.getUploadMoviesAboutUID()
        if lst_uploadMovies != nil && lst_uploadMovies!.count > 0 {
            for movie in lst_uploadMovies! {
                if movie.progress < 0.999 {
                    isShowUploadBudge = true
                    break
                }
            }
        } else {
            isShowUploadBudge = false
        }
        
        let budge = YSBudge.getBudge()
        if budge != nil && (budge!.isEnterCompetition == "1" && budge!.isEnterCompetition == "1") {
            isShowCompetitionBudge = true
            self.tabBarItem.badgeValue = ""
        } else {
            isShowCompetitionBudge = false
        }
        
        if YSBudge.getBudgeShowState() || isShowUploadBudge {
            self.tabBarController?.tabBar.showBadgeOnItemIndex(2)
            return
        }
        
        let findworkTutor = YSFindworkTutor.getTutor()
        if findworkTutor?.isChange != nil && findworkTutor!.isChange == 1 {
            self.tabBarController?.tabBar.showBadgeOnItemIndex(2)
            return
        }
        
        self.tabBarController?.tabBar.hideBadgeOnItemIndex(2)
    }
    
    func fetchMyInfo() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSUserHomePage.getMyHomePageInfo(ysApplication.loginUser.role_type) { [weak self] (resp_userInfo: YSUserInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.userInfo = resp_userInfo
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let data = NSData(contentsOfURL: NSURL(string: resp_userInfo.avatar)!)
                if data != nil {
                    if !NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Documents/Image") {
                        do {
                            try NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Image", withIntermediateDirectories: true, attributes: nil)
                        }catch let error as NSError {
                            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                            return
                        }
                    }
                    let imgpath = NSHomeDirectory() + "/Documents/Image/\(ysApplication.loginUser.tel)_avatar.png"
                    print(imgpath)
                    data!.writeToFile(imgpath, atomically: true)
                }
                
                
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    
                    if self == nil {
                        return
                    }
                    self!.tableView.reloadData()
                })
            })
            self!.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if ysApplication.loginUser.role_type == nil {
            return 0
        }
        
        if ysApplication.loginUser.role_type == UserRoleType.User.rawValue {
            return 5
        } else {
            return 4
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if ysApplication.loginUser.role_type == nil {
            return 0
        }
        
        if ysApplication.loginUser.role_type == UserRoleType.User.rawValue {
            // 普通用户
            switch section {
            case 0, 2:
                return 2
            default:
                return 1
            }
        } else if ysApplication.loginUser.role_type == UserRoleType.Judge.rawValue {
            // 评委
            switch section {
            case 3:
                return 1
            default:
                return 2
            }
        } else if ysApplication.loginUser.role_type == UserRoleType.Teacher.rawValue {
            // 老师
            switch section {
            case 1, 3:
                return 1
            default:
                return 2
            }
        } else {
            // 评委和老师
            switch section {
            case 0:
                return 2
            case 1:
                return 3
            case 2:
                return 2
            default:
                return 1
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...
        switch indexPath.section {
        case 0:
            
            if indexPath.row == 0 {
                let topCell = tableView.dequeueReusableCellWithIdentifier("YSMineTopCell")
//                let btn_avatar = topCell!.contentView.viewWithTag(11) as! UIButton
                
                let img_avatar = topCell!.contentView.viewWithTag(12) as! UIImageView
                img_avatar.layer.cornerRadius = SCREEN_WIDTH/4.0/2.0
                
                 let imgpath = NSHomeDirectory() + "/Documents/Image/\(ysApplication.loginUser.tel)_avatar.png"
                print(imgpath)
                let image = UIImage(contentsOfFile: imgpath)
                img_avatar.image = image == nil ? UIImage(named: DEFAULT_AVATAR) : image
                
                if userInfo == nil {
                    return topCell!
                }
                
                let lab_username = topCell!.contentView.viewWithTag(13) as! UILabel
                let lab_level = topCell!.contentView.viewWithTag(14) as! UILabel

//                let concernView = topCell.contentView.viewWithTag(20)
//                let fansView = topCell.contentView.viewWithTag(30)
//                let locationView = topCell.contentView.viewWithTag(40)
                
//                let lab_concern = concernView!.viewWithTag(21) as! UILabel
//                let lab_fans = fansView!.viewWithTag(31) as! UILabel
//                let lab_location = locationView!.viewWithTag(41) as! UILabel
                
                let lab_states = topCell!.contentView.viewWithTag(15) as! UILabel
                
                lab_username.text = userInfo.username
                
                lab_states.text = "关注: \(userInfo.count_user_concern)  粉丝: \(userInfo.count_user_fan)  所在地区: \(userInfo.region)"
//                lab_concern.text = userInfo.count_user_concern
//                lab_fans.text = userInfo.count_user_fan
//                lab_location.text = userInfo.region
                
                switch ysApplication.loginUser.role_type {
                case UserRoleType.User.rawValue:
                    lab_level.text = "Lv.\(userInfo.level) \(userInfo.level_name)"
                case UserRoleType.Judge.rawValue:
                    lab_level.text = "评委"
                case UserRoleType.Teacher.rawValue:
                    lab_level.text = "老师"
                case UserRoleType.TeacherAndJudge.rawValue:
                    lab_level.text = "老师&评委"
                default:
                    lab_level.text = ""
                }
                
                for constraint in lab_username.constraints {
                    if constraint.firstAttribute == NSLayoutAttribute.Width {
                        constraint.constant = lab_username.sizeThatFits(CGSize(width: 100, height: 15)).width
                    }
                }
                
                for constraint in lab_level.constraints {
                    if constraint.firstAttribute == NSLayoutAttribute.Width {
                        constraint.constant = lab_level.sizeThatFits(CGSize(width: 200, height: 15)).width + 8
                    }
                }
                
                return topCell!
            } else {
                let categoryCell = tableView.dequeueReusableCellWithIdentifier("YSMineCategoryCell")
                
                let findworkView = categoryCell!.contentView.viewWithTag(10)
                let compView = categoryCell!.contentView.viewWithTag(20)
                let winView = categoryCell!.contentView.viewWithTag(30)
                let uploadView = categoryCell!.contentView.viewWithTag(40)
                
                let budgeview_findwork = categoryCell!.contentView.viewWithTag(100)
                let budgeview_competition = categoryCell!.contentView.viewWithTag(101)
                let budgeview_upload = categoryCell!.contentView.viewWithTag(102)
                
                // 20150928 改动需求
                let roleTypeFlag = ysApplication.loginUser.role_type == "2" || ysApplication.loginUser.role_type == "3" || ysApplication.loginUser.role_type == "4"
                
                if roleTypeFlag {
                    
                    for constraint in findworkView!.constraints {
                        if constraint.firstAttribute == NSLayoutAttribute.Width {
                            constraint.constant = SCREEN_WIDTH / 2
                        }
                    }
                    
                    for constraint in uploadView!.constraints {
                        if constraint.firstAttribute == NSLayoutAttribute.Width {
                            constraint.constant = SCREEN_WIDTH / 2
                        }
                    }
                    
                    compView?.hidden = true
                    winView?.hidden = true
                    
                } else {
                    
                    for constraint in findworkView!.constraints {
                        if constraint.firstAttribute == NSLayoutAttribute.Width {
                            constraint.constant = SCREEN_WIDTH / 4
                        }
                    }
                    
                    for constraint in uploadView!.constraints {
                        if constraint.firstAttribute == NSLayoutAttribute.Width {
                            constraint.constant = SCREEN_WIDTH / 4
                        }
                    }
                    
                    compView?.hidden = false
                    winView?.hidden = false
                }
                
                if isShowCompetitionBudge {
                    budgeview_competition!.hidden = false
                } else {
                    budgeview_competition!.hidden = true
                }
                
                if isShowFindworkBudge {
                    budgeview_findwork!.hidden = false
                } else {
                    budgeview_findwork!.hidden = true
                }
                
                if isShowUploadBudge {
                    budgeview_upload!.hidden = false
                } else {
                    budgeview_upload!.hidden = true
                }
                
//                if userInfo == nil || userInfo.integral_quantity == nil {
//                    return categoryCell
//                }
                
//                let lab_score = categoryCell.contentView.viewWithTag(11) as! UILabel
//                lab_score.text = "\(userInfo.integral_quantity!.integerValue)"
                
                return categoryCell!
            }
        case 1:
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSMineNormalCell")
            
            let img_left = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_text = normalCell!.contentView.viewWithTag(12) as! UILabel
            let bottomLine = normalCell!.contentView.viewWithTag(21)
            let budgeView = normalCell!.contentView.viewWithTag(31)
            
            var tImageName: String? = nil
            var tText: String? = nil
            switch indexPath.row {
            case 0:
                
                switch ysApplication.loginUser.role_type {
                case UserRoleType.Judge.rawValue:
                    tImageName = "wd_ls&pwyh_jiaru"
                    tText = "加入过的主办方"
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isInstitutionInvitation != nil && budge!.isInstitutionInvitation == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                    
                case UserRoleType.Teacher.rawValue, UserRoleType.TeacherAndJudge.rawValue:
                    tImageName = "wd_ls&pwyh_wdxs"
                    tText = "我的学生"
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isBindTutor != nil && budge!.isBindTutor == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                    
                default:
//                    tImageName = "wd_wodejingli"
//                    tText = "我的获奖"
                    tImageName = "wd_xiaoxi"
                    tText = "消息"
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isReceivedMsg != nil && budge!.isReceivedMsg == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                }
                
            case 1:
                
                switch ysApplication.loginUser.role_type {
                case UserRoleType.Judge.rawValue:
                    tImageName = "wd_ls&pwyh_zppf"
                    tText = "作品评分"
                    bottomLine!.hidden = false
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isMarked != nil && budge!.isMarked == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                    
                case UserRoleType.TeacherAndJudge.rawValue:
                    tImageName = "wd_ls&pwyh_jiaru"
                    tText = "加入过的主办方"
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isInstitutionInvitation != nil && budge!.isInstitutionInvitation == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                    
                default:
                    tImageName = "wd_wodejiating"
                    tText = "我的家庭"
                }
                
            default:
                
                switch ysApplication.loginUser.role_type {
                case UserRoleType.TeacherAndJudge.rawValue:
                    tImageName = "wd_ls&pwyh_zppf"
                    tText = "作品评分"
                    
                    let budge = YSBudge.getBudge()
                    if budge != nil && (budge!.isMarked != nil && budge!.isMarked == "1") {
                        budgeView!.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView!.hidden = true
                    }
                    
                default:
                    tImageName = "wd_wodelaoshi"
                    tText = "我的老师"
                    
                    let findworkTutor = YSFindworkTutor.getTutor()
                    if findworkTutor?.isChange != nil && findworkTutor!.isChange == 1 {
                        budgeView?.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView?.hidden = true
                    }
                }
                
                bottomLine!.hidden = false
            }
            img_left.image = UIImage(named: tImageName!)
            lab_text.text = tText
            
            return normalCell!
            
        case 2:
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSMineNormalCell")
            
            let img_left = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_text = normalCell!.contentView.viewWithTag(12) as! UILabel
            let bottomLine = normalCell!.contentView.viewWithTag(21)
            let budgeView = normalCell!.contentView.viewWithTag(31)
            
            var tImageName: String? = nil
            var tText: String? = nil
            switch indexPath.row {
            case 0:
                
                tImageName = ysApplication.loginUser.role_type == UserRoleType.User.rawValue ? "wd_wodehaoyou" : "wd_ls&pwyh_wdhy"
                tText = "我的好友"
                
                bottomLine!.hidden = true
                
                let budge = YSBudge.getBudge()
                if budge != nil && (budge!.isConcerned != nil && budge!.isConcerned == "1") {
                    budgeView!.hidden = false
                    self.tabBarItem.badgeValue = ""
                } else {
                    budgeView!.hidden = true
                }
                
            default:
                
//                tImageName = "wd_xiaoxi"
//                tText = "消息"
                bottomLine!.hidden = false
                
//                let budge = YSBudge.getBudge()
//                if budge != nil && (budge!.isReceivedMsg != nil && budge!.isReceivedMsg == "1") {
//                    budgeView!.hidden = false
//                    self.tabBarItem.badgeValue = ""
//                } else {
//                    budgeView!.hidden = true
//                }
                
                if ysApplication.loginUser.role_type == nil {
                    break
                }
                
                if ysApplication.loginUser.role_type == "1" {
                    
                    tImageName = "wd_wodelaoshi"
                    tText = "我的老师"
                    
                    let findworkTutor = YSFindworkTutor.getTutor()
                    if findworkTutor?.isChange != nil && findworkTutor!.isChange == 1 {
                        budgeView?.hidden = false
                        self.tabBarItem.badgeValue = ""
                    } else {
                        budgeView?.hidden = true
                    }
                } else {
                    
                    tImageName = "wd_xiaoxi"
                    tText = "消息"
                }
                
            }
            img_left.image = UIImage(named: tImageName!)
            lab_text.text = tText
            
            return normalCell!
            
        case 3:
            
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSMineNormalCell")
            
            let img_left = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_text = normalCell!.contentView.viewWithTag(12) as! UILabel
            let bottomLine = normalCell!.contentView.viewWithTag(21)
            
            
            if ysApplication.loginUser.role_type == nil {
                return normalCell!
            }
            
            if ysApplication.loginUser.role_type == "1" {
            
                img_left.image = UIImage(named: "wd_jifen")
                lab_text.text = "我的积分"
                
            } else {
                
                img_left.image = UIImage(named: "wd_shezhi")
                lab_text.text = "设置"
            }
            
            bottomLine!.hidden = false
            
            return normalCell!
            
        default:
            
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSMineNormalCell")
            
            let img_left = normalCell!.contentView.viewWithTag(11) as! UIImageView
            let lab_text = normalCell!.contentView.viewWithTag(12) as! UILabel
            let bottomLine = normalCell!.contentView.viewWithTag(21)
            
            img_left.image = UIImage(named: "wd_shezhi")
            lab_text.text = "设置"
            bottomLine!.hidden = false
            
            return normalCell!
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
        
            switch ysApplication.loginUser.role_type {
            case UserRoleType.Judge.rawValue:
                
                switch indexPath.row {
                case 0:
                    gotoOrganization()
                default:
                    gotoMarking()
                }
                
            case UserRoleType.Teacher.rawValue:
                
                gotoMyStudents()
                
            case UserRoleType.TeacherAndJudge.rawValue:
                
                switch indexPath.row {
                case 0:
                    gotoMyStudents()
                case 1:
                    gotoOrganization()
                default:
                    gotoMarking()
                }
                
            default:
                
//                switch indexPath.row {
//                case 0:
//                    gotoChildExperience()
//                case 1:
//                    gotoMyFamily()
//                default:
//                    gotoMyTutor()
//                }
                
                gotoMyMessages()
            }
            
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                gotoMyFriends()
            } else {
                
                if ysApplication.loginUser.role_type == nil {
                    return
                }
                
                if ysApplication.loginUser.role_type == "1" {
                    
                    gotoMyTutor()
                } else {
                    gotoMyMessages()
                }
            }
            
        } else if indexPath.section == 3 {
            
            if ysApplication.loginUser.role_type == nil {
                return
            }
            
            
            if ysApplication.loginUser.role_type == "1" {
                
                gotoScore()
            } else {
                
                gotoSetting()
            }
            
            
        } else if indexPath.section == 4 {
            
            gotoSetting()
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 10.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if SCREEN_WIDTH < 500 {
                    return (SCREEN_WIDTH/4.0)*4.0/3.0 + 20.0 + 30.0
                } else {
                    return 275.0
                }
            } else {
                return SCREEN_WIDTH/4.0
            }
        } else {
            return 44.0
        }
    }
    
    // MARK: - 页面跳转
    
    func tapGuideView(tapGesture: UITapGestureRecognizer) {
        
        guideView.hidden = true
        guideView.removeFromSuperview()
        
        YSGuide.setUserGuideMine(1)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "gotoPersonalInfo" {
            if ysApplication.loginUser.role_type == nil {
                return
            }
            
            let controller = segue.destinationViewController as! YSPersonalInfoViewController
            
            if ysApplication.loginUser.role_type == "1" {
                
                controller.userOrJT = true
                
            } else if ysApplication.loginUser.role_type == "2" || ysApplication.loginUser.role_type == "3" || ysApplication.loginUser.role_type == "4" {
                
                controller.userOrJT = false
            }
        }
    }
    
    /** 进入参加过的比赛页 */
    func gotoCompetitionJoined() {
        
        MobClick.event("my_competion", attributes: ["result": "success"])
        
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSCompetitionJoinedViewController") as! YSCompetitionJoinedViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /** 进入上传管理页 */
    @IBAction func gotoUpload() {
        
        // 用户配置(上传管理)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_uploadmanagement = conf["my_uploadmanagement"] as? Int
            if my_uploadmanagement != nil {
                if my_uploadmanagement! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看上传记录")
                    return
                }
            }
        }
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSUploadManageTableViewController") as! YSUploadManageTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /** 进入我的作品页 */
    @IBAction func gotoFindwork() {
        
        // 用户配置(作品)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_work = conf["my_work"] as? Int
            if my_work != nil {
                if my_work! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看我的作品")
                    return
                }
            }
        }
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyFindworkViewController") as! YSMyFindworkViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /** 进入我的获奖经历页 */
    @IBAction func gotoChildExperience() {
        
        // 用户配置(我的获奖)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_awards = conf["my_awards"] as? Int
            if my_awards != nil {
                if my_awards! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看我的获奖记录")
                    return
                }
            }
        }
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSChildExperienceTableViewController") as! YSChildExperienceTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /** 进入我的家庭页 */
    func gotoMyFamily() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyFamilyViewController") as! YSMyFamilyViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /** 进入我的老师页 */
    func gotoMyTutor() {
        
        // 用户配置(我的老师)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_teacher = conf["my_teacher"] as? Int
            if my_teacher != nil {
                if my_teacher! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看我的老师")
                    return
                }
            }
        }
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyTutorViewController") as! YSMyTutorViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /** 进入我的好友页 */
    func gotoMyFriends() {
        
        // 用户配置(我的好友)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_friend = conf["my_friend"] as? Int
            if my_friend != nil {
                if my_friend! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看我的好友")
                    return
                }
            }
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyFriendsViewController") as! YSMyFriendsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入私信页 */
    func gotoMyMessages() {
        
        // 用户配置(私信)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_message = conf["my_message"] as? Int
            if my_message != nil {
                if my_message! == 0 {
                    tips.showTipsInMainThread(Text: "无法查看我的信息")
                    return
                }
            }
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMessageListViewController") as! YSMessageListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入我的学生页 */
    func gotoMyStudents() {
        let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSMyStudentViewController") as! YSMyStudentViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入加入过的主办方页 */
    func gotoOrganization() {
        let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSOrganizationJoinedViewController") as! YSOrganizationJoinedViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入作品评分页 */
    func gotoMarking() {
        let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSMarkingFindworkViewController") as! YSMarkingFindworkViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入设置页 */
    func gotoSetting() {
        
        // 用户配置(设置中心)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let my_setting = conf["my_setting"] as? Int
            if my_setting != nil {
                if my_setting! == 0 {
                    tips.showTipsInMainThread(Text: "无法进入设置中心")
                    return
                }
            }
        }
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSSettingViewController") as! YSSettingViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /** 进入积分页 */
    func gotoScore() {
        
        if userInfo == nil || userInfo.uid == nil {
            return
        }
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
        controller.hidesBottomBarWhenPushed = true
        controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/child_integral/child_integral.html?uid=\(ysApplication.loginUser.uid)&loginkey=\(ysApplication.loginUser.loginKey)")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - YSApplicationDidReceiveRomoteNotification
    
    func didReceiveRemoteNotification(notification: NSNotification) {
        
        self.tableView.reloadData()
    }
}
