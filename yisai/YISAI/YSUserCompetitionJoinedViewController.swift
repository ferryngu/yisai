//
//  YSUserCompetitionJoinedViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/3.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSUserCompetitionJoinedViewController: UITableViewController {

    private let NewestColor = UIColor(red: 232.0/255.0, green: 158.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private let OldColor = UIColor(red: 167.0/255.0, green: 214.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    private let ExperienceInfoWidth = SCREEN_WIDTH - 115.0 - 25.0
    
    var tips: FETips = FETips()
    var fuid: String! // 用户ID
    var lst_competition_info: [YSChildCompetitionInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tips.duration = 1
        
        fetchUserCompetitionJoinedData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserCompetitionJoinedData() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSChildExperience.fetchUserExperience(fuid, startIndex: 0, num: 99) { [weak self] (resp_lst_competition_info: [YSChildCompetitionInfo]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
            }
            
            self!.lst_competition_info = resp_lst_competition_info
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
        return lst_competition_info == nil ? 0 : lst_competition_info.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if lst_competition_info == nil {
            return 0.0
        }
        
        let experienceInfo = lst_competition_info[indexPath.row]
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ExperienceInfoWidth, height: 17))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        label.text = experienceInfo.competition_name
        var labelHeight1 = label.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
        labelHeight1 = (labelHeight1 >= 17 ? labelHeight1 : 17)
        label.text = "作品名：" + experienceInfo.work_title
        var labelHeight2 = label.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
        labelHeight2 = (labelHeight2 >= 17 ? labelHeight2 : 17)
        return 40 + 21 + 8 + labelHeight1 + 5 + 17 + labelHeight2 + 5 + 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSUserExperienceNormalCell")

        if lst_competition_info == nil || lst_competition_info.count < 0 {
            return cell!
        }
        
        let experienceInfo = lst_competition_info[indexPath.row]
        let leftLine = cell!.contentView.viewWithTag(11)!
        let leftDot = cell!.contentView.viewWithTag(12) as! UIImageView
        let lab_date = cell!.contentView.viewWithTag(13) as! UILabel
        let lab_competitionName = cell!.contentView.viewWithTag(14) as! UILabel
        let lab_rank = cell!.contentView.viewWithTag(15) as! UILabel
        let lab_title = cell!.contentView.viewWithTag(16) as! UILabel
        let img_contentBg = cell!.contentView.viewWithTag(17) as! UIImageView
        
        if indexPath.row == 1 {
            leftLine.backgroundColor = NewestColor
            leftDot.image = UIImage(named: "cs_shijianzhouhongdian")
            img_contentBg.image = UIImage(named: "hj_wenbenkuang")
        } else {
            leftLine.backgroundColor = OldColor
            leftDot.image = UIImage(named: "cs_shijianzhoulandian")
            img_contentBg.image = UIImage(named: "hj_wenbenkuanglan")
        }
        
        lab_date.text = experienceInfo.update_time
        lab_competitionName.text = experienceInfo.competition_name
        
        var labelHeight = lab_competitionName.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
        for constraint in lab_competitionName.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = labelHeight > 17 ? labelHeight : 17
            }
        }
        
        lab_rank.text = experienceInfo.ranking.integerValue < 1 ? "未获得名次" : "比赛名次：第\(experienceInfo.ranking)名"
        lab_title.text = "作品名：" + experienceInfo.work_title
        
        labelHeight = lab_title.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 9999)).height
        for constraint in lab_title.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = labelHeight > 17 ? labelHeight : 17
            }
        }
        
        return cell!
    }
}
