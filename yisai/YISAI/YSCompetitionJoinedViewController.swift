//
//  YSCompetitionJoinedViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/27.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionJoinedViewController: UITableViewController {
    
    var lst_competition_joined: [YSCompetitionJoinedInfo]!
    var lst_local_findwork: [YSFindwork]!
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tips.duration = 1
        
        lst_local_findwork = YSFindwork.getAllFindworks()
        
        YSBudge.setEnterCompetition("0")
        
        fetchCompetitionJoined()
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
    
    // MARK: - YSReuseImageNotification
   
    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchCompetitionJoined() {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getParticipatedCompetitionInfo(true, startIndex: 0, fetchNum: 999) { [weak self] (resp_lst_competition_joined: [YSCompetitionJoinedInfo]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                if self!.navigationController != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                }
                return
            }
            
            self!.lst_competition_joined = resp_lst_competition_joined
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
        return lst_competition_joined == nil ? 0 : lst_competition_joined.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (SCREEN_WIDTH - 10) * 53 / 102 + 94
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionJoinedCell", forIndexPath: indexPath)

        if lst_competition_joined == nil {
            return cell
        }
        // Configure the cell...
        let competition_joined = lst_competition_joined[indexPath.row]
        let img_cover = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_matchName = cell.contentView.viewWithTag(12) as! UILabel
        let lab_matchDate = cell.contentView.viewWithTag(13) as! UILabel
        let lab_matchProcess = cell.contentView.viewWithTag(14) as! UILabel
        
        img_cover.image = feiOSHttpImage.asyncHttpImageInUIThread(competition_joined.cover_plan, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            
            if self == nil {
                return
            }
            
            img_cover.image = self!.feiOSHttpImage.loadImageInCache(competition_joined.cover_plan).0
        })
        lab_matchName.text = competition_joined.match_name
        lab_matchDate.text = competition_joined.start_time + "-" + competition_joined.last_time
//        if competition_joined.competition_process.integerValue == 1 {
//            lab_matchProcess.text = "评委评分正在进行中。"
//            return cell
//        } else if competition_joined.competition_process.integerValue == 2 {
//            lab_matchProcess.text = "赛事结束，排名已公布。"
//            return cell
//        } else if competition_joined.user_competing_status.integerValue == 3 {
//            lab_matchProcess.text = "报名成功，已提交参赛视频和作品资料。"
//            return cell
//        }
        
        switch competition_joined.competition_process {
        case 0:
            lab_matchProcess.text = "赛事尚未开始。"
            return cell
        case 1:
            switch competition_joined.user_competing_status {
            case 0:
                lab_matchProcess.text = "赛事报名费用待支付。"
                return cell
            case 1:
                lab_matchProcess.text = "报名成功。"
                return cell
            case 2:
                lab_matchProcess.text = "已提交参赛视频。"
                return cell
            case 3:
                lab_matchProcess.text = "已提交参赛作品资料。"
                return cell
            case 4:
                lab_matchProcess.text = "已提交参赛视频和作品资料。"
                return cell
            default:
                break
            }
        case 2:
            lab_matchProcess.text = "赛事正在评分。"
            return cell
        case 3:
            if competition_joined.ranking.characters.count == 0 || competition_joined.ranking == "N" {
                lab_matchProcess.text = "没有获得名次。"
            } else {
                lab_matchProcess.text = "获得第\(competition_joined.ranking)名。"
            }
            return cell
        default:
            return cell
        }
        
//        // 还没提交参赛数据
//        if lst_local_findwork != nil {
//            for local_findwork in lst_local_findwork {
//                if local_findwork.cpid == competition_joined.cpid {
//                    
//                    if count(local_findwork.movieName) < 1 {
//                        lab_matchProcess.text = "报名成功，待提交参赛视频。"
//                        break
//                    }
//                    
//                    if count(local_findwork.title) < 1 || count(local_findwork.categoryId) < 1 {
//                        lab_matchProcess.text = "报名成功，待提交参赛作品资料。"
//                        break
//                    }
//                }
//            }
//        } else {
//            lab_matchProcess.text = "报名成功，待提交参赛作品资料。"
//        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let competition_joined = lst_competition_joined[indexPath.row]
        
        let controller = UIStoryboard(name: "YSCompetition", bundle: nil).instantiateViewControllerWithIdentifier("YSCompetitionDetailViewController") as! YSCompetitionDetailViewController
        controller.cpid = competition_joined.cpid
        navigationController?.pushViewController(controller, animated: true)
    }
}
