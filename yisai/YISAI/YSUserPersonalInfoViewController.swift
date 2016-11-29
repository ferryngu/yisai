//
//  YSUserPersonalInfoViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/2.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSUserPersonalInfoViewController: UITableViewController {

    private struct AssociatedObject {
        static var GetStudent = "GetStudent"
        static var GetAttentStatus = "GetAttentStatus"
        static var GetFindWork = "GetFindWork"
    }
    
    var fuid: String! // 用户ID
    var userInfo: YSUserInfo! // 用户主页数据
    var lst_findwork: [YSDiscoveryMainFindWork]! // 用户作品列表
    var findworkNum: Int = 0 // 作品数量
    private var avatarUrl: String!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.duration = 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserInfo()
        

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
    func fetchUserInfo() {
        
        if fuid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSUserHomePage.getUserHomePageInfo(fuid, resp: { [weak self] (resp_userInfo: YSUserInfo!, resp_lst_findwork: [YSDiscoveryMainFindWork]!, resp_findWorkNum: NSNumber!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.userInfo = resp_userInfo
            self!.lst_findwork = resp_lst_findwork
            self!.findworkNum = resp_findWorkNum.integerValue
            self!.tableView.reloadData()
        })
    }
    
    // MARK: - Actions
    
    func gotoSMS(button: UIButton) {
        
        if fuid == nil || userInfo == nil {
            return
        }
        
        if self.navigationController == nil {
            return
        }
        
        let childViewControllers = navigationController!.childViewControllers
        var findFlag = false
        
        for viewController in childViewControllers {
            
            if viewController is YSMyMessageViewController {
                
                findFlag = true
                
                (viewController as! YSMyMessageViewController).fuid = fuid
                (viewController as! YSMyMessageViewController).role_type = 1
                (viewController as! YSMyMessageViewController).avatarUrlStr = userInfo.avatar
                (viewController as! YSMyMessageViewController).title = userInfo.username
                
                self.navigationController?.popToViewController(viewController, animated: true)
                
                break
            }
        }
        
        if findFlag {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyMessageViewController") as! YSMyMessageViewController
        controller.fuid = fuid
        controller.role_type = 1
        controller.avatarUrlStr = userInfo.avatar
        controller.title = userInfo.username
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoBigAvatar(button: UIButton) {
            
        let controller = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomFullImageViewController") as! YSCustomFullImageViewController
        controller.imgUrl = avatarUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func attent(button: UIButton) {
        
        var status = objc_getAssociatedObject(button, &AssociatedObject.GetAttentStatus) as? NSNumber
        if status == nil {
            return
        }
        
        YSConcern.concern(ConcernStatus(rawValue: status!.integerValue)!, fuid: userInfo.fuid) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            status = NSNumber(integer: status == 0 ? 1 : 0)
            self!.userInfo.user_concern_status = status
            objc_setAssociatedObject(button, &AssociatedObject.GetAttentStatus, status,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    func gotoDetail(button: UIButton) {
        
        let findwork = objc_getAssociatedObject(button, &AssociatedObject.GetFindWork) as? YSDiscoveryMainFindWork
        if findwork == nil {
            return
        }
        
        if self.navigationController == nil {
            return
        }
        
        let childViewControllers = self.navigationController!.childViewControllers
        var findFlag = false
        
        for viewController in childViewControllers {
            
            if viewController is YSDiscoveryDetailViewController {
                
                findFlag = true
                
                (viewController as! YSDiscoveryDetailViewController).wid = findwork!.wid
                (viewController as! YSDiscoveryDetailViewController).hidesBottomBarWhenPushed = true
                
                self.navigationController?.popToViewController(viewController, animated: true)
                break
            }
        }
        
        if findFlag {
            return
        }
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSDiscoveryDetailViewController") as! YSDiscoveryDetailViewController
        controller.wid = findwork!.wid
        controller.movieURL = findwork!.video_url
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return (lst_findwork == nil || lst_findwork.count < 1) ? 1 : ((lst_findwork.count - 1) / 2 + 1 + 1)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10 : 0
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
            if indexPath.row == 0 {
                return 50
            } else {
                return (SCREEN_WIDTH / 2 - 8) * 245 / 292 + 5
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("YSUserHPTopCell")
                if userInfo == nil {
                    return cell!
                }
                
                let img_avatar = cell!.contentView.viewWithTag(11) as! UIImageView
                let lab_name = cell!.contentView.viewWithTag(12) as! UILabel
                let lab_level = cell!.contentView.viewWithTag(13) as! UILabel
                let btn_gotoBigImage = cell!.contentView.viewWithTag(14) as! UIButton
                
                img_avatar.layer.cornerRadius = SCREEN_WIDTH * 108 / 414 / 2
                avatarUrl = userInfo.avatar == nil ? "" : userInfo.avatar
                btn_gotoBigImage.addTarget(self, action: "gotoBigAvatar:", forControlEvents: .TouchUpInside)
                

                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(userInfo.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.userInfo.avatar).0
                    })
                
                lab_name.text = userInfo.username
                lab_level.text = "Lv.\(userInfo.level)  \(userInfo.level_name)"
                
                for constraint in lab_level.constraints {
                    if constraint.firstAttribute == NSLayoutAttribute.Width {
                        constraint.constant = lab_level.sizeThatFits(CGSize(width: 200, height: 15)).width + 8
                        lab_level.backgroundColor = UIColor(patternImage: UIImage(named: "zdls_diwen")!)
                        break
                    }
                }
                
                return cell!
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSUserHPFunctionCell")
                
                if userInfo == nil {
                    return cell!
                }
                
                let btn_sms = cell!.contentView.viewWithTag(11) as! UIButton
                let btn_attention = cell!.contentView.viewWithTag(12) as! UIButton
                let img_attentionStatus = cell!.contentView.viewWithTag(21) as! UIImageView
                let lab_attentionStatus = cell!.contentView.viewWithTag(22) as! UILabel
                
                btn_sms.addTarget(self, action: "gotoSMS:", forControlEvents: .TouchUpInside)
                objc_setAssociatedObject(btn_attention, &AssociatedObject.GetAttentStatus, userInfo.user_concern_status, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn_attention.addTarget(self, action: "attent:", forControlEvents: .TouchUpInside)
                if userInfo.user_concern_status!.integerValue == 0 {
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSUserHPSelectionCell")
            return cell!
        default:
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSUserHPFindworkHeadCell")
                
                if lst_findwork == nil {
                    return cell!
                }
                
                let lab_studentNum = cell!.contentView.viewWithTag(11) as! UILabel
                lab_studentNum.text = "(\(findworkNum))"
                
                return cell!
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSUserHPFindworkCell")
                
                if lst_findwork == nil {
                    return cell!
                }
                
                let index = 2 * indexPath.row - 2
                if index <= lst_findwork.count - 1 {
                    let findwork = lst_findwork[index]
                    let l_btn_toDetail = cell!.contentView.viewWithTag(11) as! UIButton
                    let l_img_video = cell!.contentView.viewWithTag(12) as! UIImageView
                    let l_img_avatar = cell!.contentView.viewWithTag(13) as! UIImageView
                    let l_lab_title = cell!.contentView.viewWithTag(14) as! UILabel
                    let l_lab_praise = cell!.contentView.viewWithTag(15) as! UILabel
                    
                    l_img_video.image = nil
                    l_img_avatar.image = nil
                    l_lab_title.text = nil
                    l_lab_praise.text = nil
                    
                    l_btn_toDetail.addTarget(self, action: "gotoDetail:", forControlEvents: .TouchUpInside)
                    objc_setAssociatedObject(l_btn_toDetail, &AssociatedObject.GetFindWork, findwork, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    

                    l_img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        l_img_video.image = self!.feiOSHttpImage.loadImageInCache(findwork.video_img_url).0
                        })

                    l_img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        l_img_avatar.image = self!.feiOSHttpImage.loadImageInCache(findwork.avatar).0
                        })
                    
                    l_lab_title.text = findwork.title
                    l_lab_praise.text = "\(findwork.praise_count)"
                    
                }
                
                let r_bgView = cell!.contentView.viewWithTag(20)
                let r_btn_toDetail = cell!.contentView.viewWithTag(21) as! UIButton
                let r_img_video = cell!.contentView.viewWithTag(22) as! UIImageView
                let r_img_avatar = cell!.contentView.viewWithTag(23) as! UIImageView
                let r_lab_title = cell!.contentView.viewWithTag(24) as! UILabel
                let r_lab_praise = cell!.contentView.viewWithTag(25) as! UILabel
                
                r_img_video.image = nil
                r_img_avatar.image = nil
                r_lab_title.text = nil
                r_lab_praise.text = nil
                
                if index + 1 <= lst_findwork.count - 1 {
                    r_bgView?.hidden = false
                    
                    let findwork = lst_findwork[index+1]
                    
                    r_btn_toDetail.addTarget(self, action: "gotoDetail:", forControlEvents: .TouchUpInside)
                    objc_setAssociatedObject(r_btn_toDetail, &AssociatedObject.GetFindWork, findwork, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    
                    r_img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        r_img_video.image = self!.feiOSHttpImage.loadImageInCache(findwork.video_img_url).0
                        })
                    r_img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        r_img_avatar.image = self!.feiOSHttpImage.loadImageInCache(findwork.avatar).0
                        })
                    
                    r_lab_title.text = findwork.title
                    r_lab_praise.text = "\(findwork.praise_count)"
                } else {
                    r_bgView?.hidden = true
//                    r_btn_toDetail.hidden = true
                }
                
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if fuid == nil {
            return
        }
        
        if indexPath.section == 1 {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSUserCompetitionJoinedViewController") as! YSUserCompetitionJoinedViewController
            controller.fuid = fuid
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
