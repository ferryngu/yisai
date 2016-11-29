//
//  YSCompetitionRankViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/27.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionRankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rankMainController: YSCompetitionRankMainViewController!
    var cpid: String! // 赛事ID
    var cgid: String! // 分组ID
    var matchName: String! // 赛事名称
    
    var tips: FETips = FETips()
    
    @IBOutlet weak var btn_category: UIButton!
    @IBOutlet weak var btn_group: UIButton!
    @IBOutlet weak var userRankView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tbv_competition_category: UITableView!
    @IBOutlet weak var tbv_competition: UITableView!
    @IBOutlet weak var tbv_competition_group: UITableView!
    
    var lst_competition_category: [YSWorkCategory]!
    var lst_competition: [YSMainCompetitionInfo]!
    var lst_competition_group: [YSCompetitionGroupInfo]!
    var user_rank_info: YSCompetitionRankInfo!
    var user_comptition_rank_status: Int!
    
    var cgStatus: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        
        tips = FETips()
        tips.duration = 1
        
        btn_category.setTitle(matchName, forState: UIControlState.Normal)
        
        // 搜索分组
        rankMainController.cpid = cpid
        rankMainController.fetchRank()
//        fetchCategory(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCategory(shouldCache: Bool) {
        
        YSPublish.getWorkCategory() { [weak self] (resp_lst_category: [YSWorkCategory]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_competition_category = resp_lst_category
            self!.tbv_competition_category.reloadData()
        }
    }
    
    func fetchCompetition(shouldCache: Bool, wcid: String) {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getMainCompetitionInfo(true, wcid: wcid, type: 1, startIndex: 0, fetchNum: 99) { [weak self] (resp_competition_info: [YSMainCompetitionInfo]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_competition = resp_competition_info
            self!.tbv_competition.reloadData()
        }
    }
    
    func showCompetitionTbv() {
        
        hideGroupTbv()
        
        tbv_competition.hidden = false
        tbv_competition_category.hidden = false
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.tbv_competition.alpha = 1
            self.tbv_competition_category.alpha = 1
        }, completion: nil)
    }
    
    func showGroupTbv() {
        
        hideCompetitionTbv()

        tbv_competition_group.hidden = false
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.tbv_competition_group.alpha = 1
        }, completion: nil)
    }
    
    func hideCompetitionTbv() {
        
        tbv_competition.alpha = 0
        tbv_competition_category.alpha = 0
        
        tbv_competition.hidden = true
        tbv_competition_category.hidden = true
    }
    
    func hideGroupTbv() {
        
        tbv_competition_group.alpha = 0
        tbv_competition_group.hidden = true
    }
    
    func configureUserRankView() {
        
        if ysApplication.loginUser.role_type != UserRoleType.User.rawValue || (user_comptition_rank_status != nil && user_comptition_rank_status == 0) {
            userRankView.hidden = true
            for constraint in userRankView.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = 0
                }
            }
            return
        }
        
        let img_avatar = userRankView.viewWithTag(11) as! UIImageView
        let lab_username = userRankView.viewWithTag(12) as! UILabel
        let lab_title = userRankView.viewWithTag(13) as! UILabel
        let lab_rank = userRankView.viewWithTag(14) as! UILabel
        
        let imageName = UIImage(named: MovieFilesManager.getUserLocalAvatarPath()!) == nil ? DEFAULT_AVATAR : MovieFilesManager.getUserLocalAvatarPath()!
        img_avatar.image = UIImage(named: imageName)
        if ysApplication.loginUser.realName == nil && user_rank_info != nil {
            ysApplication.loginUser.setUserRealName(user_rank_info.realname)
            lab_username.text = user_rank_info.realname
        } else if ysApplication.loginUser.realName != nil {
            lab_username.text = ysApplication.loginUser.realName
        }
        
        if user_rank_info != nil {
            lab_title.text = user_rank_info.title
            lab_rank.text = user_rank_info.ranking
        } else {
            lab_rank.text = "无"
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case tbv_competition_category:
            return lst_competition_category == nil ? 0 : lst_competition_category.count
        case tbv_competition:
            return lst_competition == nil ? 0 : lst_competition.count
        case tbv_competition_group:
            return lst_competition_group == nil ? 0 : lst_competition_group.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("YSRankMenuCell", forIndexPath: indexPath)
        
        let lab_content = cell.contentView.viewWithTag(11) as! UILabel
        
        switch tableView {
        case tbv_competition_category:
            
            if lst_competition_category == nil {
                return cell
            }
            
            let category = lst_competition_category[indexPath.row]
            lab_content.text = category.category_name
            
        case tbv_competition:
            
            if lst_competition == nil {
                return cell
            }
            
            let competition = lst_competition[indexPath.row]
            lab_content.text = competition.match_name
            
        case tbv_competition_group:
            
            if lst_competition_group == nil {
                return cell
            }
            
            let group = lst_competition_group[indexPath.row]
            lab_content.text = group.title
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch tableView {
        case tbv_competition_category:
            
            if lst_competition_category == nil {
                return
            }
            
            let category = lst_competition_category[indexPath.row]
            if category.wcid == nil {
                return
            }
            fetchCompetition(true, wcid: category.wcid)
            
        case tbv_competition:
            
            if lst_competition == nil {
                return
            }
            
            let competition = lst_competition[indexPath.row]
            if competition.cpid == nil {
                return
            }
            cpid = competition.cpid
            rankMainController.cpid = cpid
            rankMainController.fetchRank()
            
            hideCompetitionTbv()
            hideGroupTbv()
            
        case tbv_competition_group:
            
            if lst_competition_group == nil {
                return
            }
            
            let group = lst_competition_group[indexPath.row]
            if group.cgid == nil || cpid == nil {
                return
            }
            
            btn_group.setTitle(group.title, forState: .Normal)
            rankMainController.cpid = cpid
            rankMainController.cgid = group.cgid
            rankMainController.fetchRank()
            
            hideCompetitionTbv()
            hideGroupTbv()
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Actions
    
    @IBAction func share(sender: AnyObject) {
        
        print("进入分享页面", terminator: "")
    }
    
    @IBAction func touchCategory(sender: AnyObject) {
        
        if tbv_competition.hidden == false {
            hideCompetitionTbv()
        } else {
            showCompetitionTbv()
        }
    }
    
    @IBAction func touchGroup(sender: AnyObject) {
        
        if tbv_competition_group.hidden == false {
            hideGroupTbv()
        } else {
            showGroupTbv()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "gotoRankMainController" {
            
            rankMainController = segue.destinationViewController as! YSCompetitionRankMainViewController
            rankMainController.cpid = cpid
            rankMainController.cgid = cgid
        }
    }
}
