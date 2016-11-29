//
//  YSTNJPersonalInfoViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/1.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum RoleType {
    case Judge
    case Tutor
    case JudgeAndTutor
}

class YSTNJPersonalInfoViewController: UITableViewController {

    private struct AssociatedObject {
        static var GetStudent = "GetStudent"
        static var GetAttentStatus = "GetAttentStatus"
    }
    
    var role_type: RoleType!
    var aid: String! // 导师或评委ID
    var tutorOrJudge: YSTutor_Judge! // 导师或评委数据
    var lst_student: [YSTutorStudent]!
    var prizeCount: YSStudentPrizeCount!
    private var avatarUrl: String!
    
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.view.backgroundColor = UIColor.whiteColor()
         tips.duration = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchInfo()
  
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
    
    func fetchInfo() {
        
        if aid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchJudgeTeacherInfo(aid, startIndex: 0, num: 20) { [weak self] (resp_tutor_judge: YSTutor_Judge!, resp_lst_student: [YSTutorStudent]!, resp_prize_count: YSStudentPrizeCount!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if resp_tutor_judge == nil || resp_tutor_judge.role_type == nil {
                return
            }
            
            switch resp_tutor_judge.role_type.integerValue {
            case 0:
                // 评委
                self!.role_type = RoleType.Judge
            case 1:
                // 老师
                self!.role_type = RoleType.Tutor
            default:
                // 评委&老师
                self!.role_type = RoleType.JudgeAndTutor
            }
            self!.tutorOrJudge = resp_tutor_judge
            self!.lst_student = resp_lst_student
            self!.prizeCount = resp_prize_count
            
            self!.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    func gotoSMS(button: UIButton) {
        
        if aid == nil || tutorOrJudge == nil {
            return
        }
        
        if navigationController == nil {
            return
        }
        
        let childViewControllers = navigationController!.childViewControllers
        var findFlag = false
        
        for viewController in childViewControllers {
            
            if viewController is YSMyMessageViewController {
                
                findFlag = true
                
                (viewController as! YSMyMessageViewController).fuid = aid
                if tutorOrJudge.role_type != nil {
                    (viewController as! YSMyMessageViewController).role_type = tutorOrJudge.role_type.integerValue
                } else {
                    (viewController as! YSMyMessageViewController).role_type = 3
                }
                (viewController as! YSMyMessageViewController).avatarUrlStr = tutorOrJudge.avatar
                (viewController as! YSMyMessageViewController).title = tutorOrJudge.username
                
                self.navigationController?.popToViewController(viewController, animated: true)
                
                break
            }
        }
        
        if findFlag {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyMessageViewController") as! YSMyMessageViewController
        controller.fuid = aid
        switch role_type! {
        case RoleType.Judge:
            controller.role_type = 2
        case RoleType.Tutor:
            controller.role_type = 3
        case RoleType.JudgeAndTutor:
            controller.role_type = 4
        default:
            controller.role_type = 0
        }
        if tutorOrJudge != nil {
            controller.avatarUrlStr = tutorOrJudge.avatar
            controller.title = tutorOrJudge.username
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoBigAvatar(button: UIButton) {
        //----------张继忠-------------
        let controller = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomFullImageViewController") as! YSCustomFullImageViewController
        if controller.imgUrl == nil{
         return
        }
//        -----------------------
        controller.imgUrl = avatarUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func attent(button: UIButton) {
        
        var status = objc_getAssociatedObject(button, &AssociatedObject.GetAttentStatus) as? NSNumber
        if status == nil {
            return
        }
        
        YSConcern.concern(ConcernStatus(rawValue: status!.integerValue)!, fuid: tutorOrJudge.fuid) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            status = NSNumber(integer: status == 0 ? 1 : 0)
            self!.tutorOrJudge.user_concern_status = status
            objc_setAssociatedObject(button, &AssociatedObject.GetAttentStatus, status, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let cell = self!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            let img_attentionStatus = cell!.contentView.viewWithTag(21) as! UIImageView
            let lab_attentionStatus = cell!.contentView.viewWithTag(22) as! UILabel
            
            if status!.integerValue == 0 {
                // 没关注
                img_attentionStatus.image = UIImage(named: "zdls_guanzhu")
                lab_attentionStatus.text = "关注"
            } else {
                // 已关注
                img_attentionStatus.image = UIImage(named: "zdls_quxiaoguanzhu")
                lab_attentionStatus.text = "取消关注"
            }
        }
    }
    
    func gotoStudentInfo(button: UIButton) {
        
        let student = objc_getAssociatedObject(button, &AssociatedObject.GetStudent) as? YSTutorStudent
        if student == nil {
            return
        }
        
        if self.navigationController == nil {
            return
        }
        
//        let childViewController = self.navigationController!.childViewControllers
        var findFlag = false
        
        for viewController in childViewControllers {
            
            if viewController is YSUserPersonalInfoViewController {
                (viewController as! YSUserPersonalInfoViewController).fuid = student!.uid
                findFlag = true
                break
            }
        }
        
        if findFlag {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSUserPersonalInfoViewController") as! YSUserPersonalInfoViewController
        controller.fuid = student!.uid
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tutorOrJudge == nil ? 0 : 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 2
        case 1:
            if role_type == nil {
                return 0
            }
            
            if role_type! == .JudgeAndTutor {
                return 2
            } else {
                return 1
            }
        default:
            if role_type == nil {
                return 0
            }
            
            if role_type! == .JudgeAndTutor || role_type! == .Tutor {
                if lst_student == nil && lst_student.count < 1 {
                    return 1
                } else {
                    return (lst_student.count - 1) / 5 + 1 + 1
                }
            } else {
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 10.0
        default:
            return 0.01
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 16 + 55 + SCREEN_WIDTH * 108 / 414
            } else {
                return 49
            }
        case 1:
            return 44
        default:
            if role_type == nil || role_type! == .Judge {
                return 0
            } else {
                if indexPath.row == 0 {
                    return 50
                } else {
                    return SCREEN_WIDTH / 5 - 16 + 15 + 44
                }
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("YSTNJTopCell")
                
                if tutorOrJudge == nil {
                    return cell!
                }
                
                let img_avatar = cell!.contentView.viewWithTag(11) as! UIImageView
                let lab_name = cell!.contentView.viewWithTag(12) as! UILabel
                let lab_roleType = cell!.contentView.viewWithTag(13) as! UILabel
                let btn_gotoBigImage = cell!.contentView.viewWithTag(14) as! UIButton
                
                img_avatar.layer.cornerRadius = SCREEN_WIDTH * 108 / 414 / 2
                avatarUrl = tutorOrJudge.avatar == nil ? "" : tutorOrJudge.avatar
                btn_gotoBigImage.addTarget(self, action: "gotoBigAvatar:", forControlEvents: .TouchUpInside)

                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(tutorOrJudge.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.tutorOrJudge.avatar).0
                    })
                lab_name.text = tutorOrJudge.realname
                var tText: String? = nil
                switch role_type! {
                case .Judge:
                    tText = "评委"
                case .Tutor:
                    tText = "老师"
                default:
                    tText = "老师&评委"
                }
                lab_roleType.text = tText
                
                for constraint in lab_roleType.constraints {
                    if constraint.firstAttribute == NSLayoutAttribute.Width {
                        constraint.constant = lab_roleType.sizeThatFits(CGSize(width: 100, height: 15)).width + 8
                        lab_roleType.backgroundColor = UIColor(patternImage: UIImage(named: "zdls_diwen")!)
                        break
                    }
                }

                return cell!
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSTNJFunctionCell")
                
                if tutorOrJudge == nil {
                    return cell!
                }
                
                let btn_sms = cell!.contentView.viewWithTag(11) as! UIButton
                let btn_attention = cell!.contentView.viewWithTag(12) as! UIButton
                let img_attentionStatus = cell!.contentView.viewWithTag(21) as! UIImageView
                let lab_attentionStatus = cell!.contentView.viewWithTag(22) as! UILabel
                
                btn_sms.addTarget(self, action: "gotoSMS:", forControlEvents: .TouchUpInside)
                objc_setAssociatedObject(btn_attention, &AssociatedObject.GetAttentStatus, tutorOrJudge.user_concern_status, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn_attention.addTarget(self, action: "attent:", forControlEvents: .TouchUpInside)
                if tutorOrJudge.user_concern_status.integerValue == 0 {
                    // 没关注
                    img_attentionStatus.image = UIImage(named: "zdls_guanzhu")
                    lab_attentionStatus.text = "关注"
                } else {
                    // 已关注
                    img_attentionStatus.image = UIImage(named: "zdls_quxiaoguanzhu")
                    lab_attentionStatus.text = "取消关注"
                }
                
                return cell!
            }
        case 1:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSTNJSelectionCell")
            
            if tutorOrJudge == nil {
                return cell!
            }
            
            let img_icon = cell!.contentView.viewWithTag(11) as! UIImageView
            let lab_text = cell!.contentView.viewWithTag(12) as! UILabel
            let bottomView = cell!.contentView.viewWithTag(21)
            let prizeView = cell!.contentView.viewWithTag(30)
            let lab_champion_count = prizeView!.viewWithTag(31) as! UILabel
            let lab_runner_up_count = prizeView!.viewWithTag(32) as! UILabel
            let lab_bronze_count = prizeView!.viewWithTag(33) as! UILabel
            let lab_rear_guard_count = prizeView!.viewWithTag(34) as! UILabel
            
            var imgName: String? = nil
            var tText: String? = nil
            
            if indexPath.row == 0 {
                
                if role_type! == .Tutor {
                    imgName = "zdls_jiangbei"
                    tText = "学生奖项"
                    
                    prizeView!.hidden = false
                    
                    if prizeCount == nil {
                        return cell!
                    }
                    
                    lab_champion_count.text = prizeCount.champion_count
                    lab_runner_up_count.text = prizeCount.runner_up_count
                    lab_bronze_count.text = prizeCount.bronze_count
                    lab_rear_guard_count.text = prizeCount.rear_guard_count
                    
                } else {
                    imgName = "zdls_pingweizizhi"
                    tText = "评委资历"
                    bottomView?.hidden = true
                    
                    prizeView!.hidden = true
                }
            } else {
                imgName = "zdls_jiangbei"
                tText = "学生奖项"
                
                prizeView!.hidden = false
                
                if prizeCount == nil {
                    return cell!
                }
                
                lab_champion_count.text = prizeCount.champion_count
                lab_runner_up_count.text = prizeCount.runner_up_count
                lab_bronze_count.text = prizeCount.bronze_count
                lab_rear_guard_count.text = prizeCount.rear_guard_count
            }
            
            img_icon.image = UIImage(named: imgName!)
            lab_text.text = tText
            
            return cell!
        default:
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSTNJStudentHeadCell")
                
                if lst_student == nil {
                    return cell!
                }
                
                let lab_studentNum = cell!.contentView.viewWithTag(11) as! UILabel
                lab_studentNum.text = "(\(lst_student.count))"
                
                return cell!
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSTNJStudentNormalCell")
                
                if tutorOrJudge == nil {
                    return cell!
                }
                
                for i in 1...5 {
                    
                    if 5 * (indexPath.row - 1) + i > lst_student.count {
                        break
                    }
                    
                    let tView = cell!.contentView.viewWithTag(i)
                    tView?.hidden = false
                    
                    let student = lst_student[5 * (indexPath.row - 1) + i - 1]
                    let img_avatar = tView?.viewWithTag(11) as! UIImageView
                    let lab_name = tView?.viewWithTag(12) as! UILabel
                    let lab_date = tView?.viewWithTag(13) as! UILabel
                    let btn_tutor = tView?.viewWithTag(14) as! UIButton
                    
                    img_avatar.layer.cornerRadius = (SCREEN_WIDTH / 5 - 16) / 2

                    img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(student.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        img_avatar.image = self!.feiOSHttpImage.loadImageInCache(student.avatar).0
                        })
                    lab_name.text = student.realname
                    lab_date.text = student.username
                    // 如果学生是自己，则不能点击头像图标
                    if student.uid == ysApplication.loginUser.uid {
                        continue
                    }
                    objc_setAssociatedObject(btn_tutor, &AssociatedObject.GetStudent, student, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    btn_tutor.addTarget(self, action: "gotoStudentInfo:", forControlEvents: .TouchUpInside)
                }
                
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tutorOrJudge == nil || tutorOrJudge.fuid == nil {
            return
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 && (role_type == .Judge || role_type == .JudgeAndTutor) {
                
                let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSJudgeIntroductionViewController") as! YSJudgeIntroductionViewController
                controller.fuid = tutorOrJudge.fuid
                controller.title = tutorOrJudge.realname
                navigationController?.pushViewController(controller, animated: true)
                
            } else {
                
                let controller = UIStoryboard(name: "YSJudge", bundle: nil).instantiateViewControllerWithIdentifier("YSStudentPrizeViewController") as! YSStudentPrizeViewController
                controller.fuid = tutorOrJudge.fuid
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
