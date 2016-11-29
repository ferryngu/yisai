//
//  YSCompetitionRankMainViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/27.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionRankMainViewController: UITableViewController {
    
    var cpid: String!
    var cgid: String!
    var lst_rank_info: [YSCompetitionRankInfo]!
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.duration = 1

        self.tableView.rowHeight = 82
        
        fetchRank()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    func fetchRank() {
        
        if cpid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getRankInfo(true, cpid: cpid, cgid: cgid, startIndex: 0, fetchNum: 99) { [weak self] (resp_lst_rank_info: [YSCompetitionRankInfo]!, resp_lst_group_info: [YSCompetitionGroupInfo]!, resp_user_rank_info: YSCompetitionRankInfo!, resp_status: Int!, resp_user_rank_status: Int!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            let controller = self!.parentViewController as? YSCompetitionRankViewController
            if controller == nil {
                return
            }
            
            if controller?.navigationController == nil {
                return
            }
            
            if errorMsg != nil {
                controller!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_rank_info = resp_lst_rank_info
            controller!.lst_competition_group = resp_lst_group_info
            controller!.tbv_competition_group.reloadData()
            controller!.cgStatus = resp_status
            controller!.user_comptition_rank_status = resp_user_rank_status
            if resp_user_rank_status == 0 {
                controller!.user_rank_info = nil
            } else {
                controller!.user_rank_info = resp_user_rank_info
            }
            controller!.configureUserRankView()
            
            self!.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lst_rank_info == nil ? 0 : lst_rank_info.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionRankCell", forIndexPath: indexPath) 

        if lst_rank_info == nil {
            return cell
        }
        
        let rankInfo = lst_rank_info[indexPath.row]
        let img_videoBg = cell.contentView.viewWithTag(11) as! UIImageView
        let img_rank = cell.contentView.viewWithTag(12) as! UIImageView
        let lab_rank = cell.contentView.viewWithTag(13) as! UILabel
        let lab_realname = cell.contentView.viewWithTag(14) as! UILabel
        let lab_title = cell.contentView.viewWithTag(15) as! UILabel
        let lab_score = cell.contentView.viewWithTag(16) as! UILabel

        img_videoBg.image = feiOSHttpImage.asyncHttpImageInUIThread(rankInfo.video_img_url,defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            
            if self == nil {
                return
            }
            
            img_videoBg.image = self!.feiOSHttpImage.loadImageInCache(rankInfo.video_img_url).0
        })
        
        var rank_image_name = "phb_hg"
        switch (rankInfo.ranking as NSString).integerValue {
        case 1:
            rank_image_name = "phb_gj"
        case 2:
            rank_image_name = "phb_yj"
        case 3:
            rank_image_name = "phb_jj"
        case 4:
            rank_image_name = "phb_dj"
        default:
            rank_image_name = "phb_hg"
        }
        img_rank.image = UIImage(named: rank_image_name)
        lab_rank.text = "第\(rankInfo.ranking)名"
        lab_realname.text = rankInfo.realname
        lab_title.text = rankInfo.title
        
        let tScore = (rankInfo.score == nil) ? "0" : rankInfo.score
        let score = (tScore as NSString).floatValue
        let format_score = NSString(format: "%.2f", score)
        lab_score.text = "\(format_score)分"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if lst_rank_info == nil || lst_rank_info.count < 1 {
            return
        }
        
        let rank_info = lst_rank_info[indexPath.row]
        
        if rank_info.work_uid_status == nil {
            return
        }
        
        if rank_info.work_uid_status == "0" {
            
            tips.showTipsInMainThread(Text: "该用户不是易赛在线用户")
            return
        }
        
        let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSDiscoveryDetailViewController") as! YSDiscoveryDetailViewController
        controller.wid = rank_info.wid
        controller.movieURL = rank_info.video_url
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
