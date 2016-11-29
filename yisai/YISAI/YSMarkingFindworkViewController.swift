//
//  YSMarkingFindworkViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/22.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMarkingFindworkViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var tips: FETips = FETips()
    var lst_marking_info: [YSMarkingCompetitionInfo]!
    var scoring_criteria: String!
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YSBudge.setMarked("0")
        
        tLabel.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 52, height: 19)
        tLabel.font = UIFont.systemFontOfSize(15)
        tLabel.numberOfLines = 0
        tLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        tips = FETips()
        tips.duration = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        
        fetchMarkingFindworkData()
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
    func fetchMarkingFindworkData() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getMarkingFindworkInfo(resp: { [weak self] (resp_lst_marking_info: [YSMarkingCompetitionInfo]!, resp_scoring_criteria: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if resp_lst_marking_info.count < 1 {
                self!.tips.showTipsInMainThread(Text: "没有需要评分的比赛作品")
            }
            
            self!.lst_marking_info = resp_lst_marking_info
            self!.scoring_criteria = resp_scoring_criteria
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
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMarkingFindworkTopCell", forIndexPath: indexPath)
            
            if scoring_criteria == nil {
                return cell
            }
            
            let lab_markingCriterion = cell.contentView.viewWithTag(11) as! UILabel
            
            lab_markingCriterion.text = scoring_criteria
            
            let lheight = lab_markingCriterion.sizeThatFits(CGSize(width: SCREEN_WIDTH - 26 * 2, height: 9999)).height
            for constraint in lab_markingCriterion.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = lheight
                }
            }
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMarkingFindworkShowAllCell", forIndexPath: indexPath)
            
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMarkingFindworkCell", forIndexPath: indexPath)
            
            let collectionView = cell.contentView.viewWithTag(11) as! UICollectionView
            collectionView.reloadData()
            
            return cell
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
    
            tLabel.text = scoring_criteria
            return tLabel.sizeThatFits(CGSize(width: tLabel.bounds.width, height: 9999)).height + 37 + 15
        case 1:
            return 53
        default:
            
            if lst_marking_info == nil || lst_marking_info.count < 1 {
                return 0.0
            }
            
            let itemHeight = (SCREEN_WIDTH - 15) / 2.0 * 3.0 / 4.0 + 18.0
            
            return 32.0 + (itemHeight + 5) * CGFloat((lst_marking_info.count - 1) / 2 + 1)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            print("进入查看评分详情网页", terminator: "")
        }
    }
    
    // MARK: UICollectionViewDelegate & DataSource & DelegateDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lst_marking_info == nil ? 0 : lst_marking_info.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("YSMarkingFindworkCollectionCell", forIndexPath: indexPath)
        
        if lst_marking_info == nil || lst_marking_info.count < 1 {
            return collectionCell
        }
        
        let findwork = lst_marking_info[indexPath.row]
        let img_video = collectionCell.contentView.viewWithTag(11) as! UIImageView
        let img_avatar = collectionCell.contentView.viewWithTag(12) as! UIImageView
        let lab_title = collectionCell.contentView.viewWithTag(13) as! UILabel
        let lab_name = collectionCell.contentView.viewWithTag(14) as! UILabel
        
        img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_video.image = self!.feiOSHttpImage.loadImageInCache(findwork.video_img_url).0
            })

        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(findwork.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_avatar.image = self!.feiOSHttpImage.loadImageInCache(findwork.avatar).0
            })
        
        lab_title.text = findwork.title
        lab_name.text = findwork.username
        
        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if lst_marking_info == nil || lst_marking_info.count < 1 {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMarkingDetailViewController") as! YSMarkingDetailViewController
        controller.crid = lst_marking_info[indexPath.row].crid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
        let itemWidth = (SCREEN_WIDTH - 15) / 2
        return CGSize(width: itemWidth, height: itemWidth * 3 / 4 + 18)
    }
}
