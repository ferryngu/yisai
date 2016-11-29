//
//  YSStudentPrizeViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/25.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSStudentPrizeViewController: UITableViewController {

    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var fuid: String!
    
    var lst_prize: [YSStudentPrize]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        tableView.rowHeight = 79.0
        
        fetchStudentPrize()
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
    func fetchStudentPrize() {
        
        if fuid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchStudentPrize(fuid, block: { [weak self] (resp_lst_prize: [YSStudentPrize]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_prize = resp_lst_prize
            self!.tableView.reloadData()
        })
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
        return lst_prize == nil ? 0 : lst_prize.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSStudentPrizeCell", forIndexPath: indexPath)
        if lst_prize == nil || lst_prize.count < 1 {
            return cell
        }
        
        let prize = lst_prize[indexPath.row]
        let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_name = cell.contentView.viewWithTag(12) as! UILabel
        let lab_matchName = cell.contentView.viewWithTag(13) as! UILabel
        let lab_rank = cell.contentView.viewWithTag(14) as! UILabel
        let lab_date = cell.contentView.viewWithTag(15) as! UILabel
        
        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(prize.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_avatar.image = self!.feiOSHttpImage.loadImageInCache(prize.avatar).0
            })
        lab_name.text = prize.realname
        lab_matchName.text = prize.work_title
        lab_rank.text = (prize.ranking != nil && prize.ranking.integerValue > 0) ? "第\(prize.ranking)名" : "暂无名次"
        lab_date.text = prize.update_time

        return cell
    }
}
