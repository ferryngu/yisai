//
//  YSChildExperienceTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSChildExperienceTableViewController: UITableViewController {

    private let NewestColor = UIColor(red: 232.0/255.0, green: 158.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private let OldColor = UIColor(red: 167.0/255.0, green: 214.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    private let ExperienceInfoWidth = SCREEN_WIDTH - 115.0 - 25.0
    
    var childExperience: YSChildPersonalExperience!
    var lst_experienceInfo: [YSChildCompetitionInfo]!
    var loadFindWorkIndex: Int = 0
    var isLoadMore: Bool = false
    var isLoading: Bool = false
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var originTableViewFooterOrigin: CGPoint = CGPoint(x: 0, y: 0)
    var retainRightItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tips.duration = 1
        
        configureRefreshView()
        fetchChildInfo(true)
        loadFindWorkIndex += 20
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 用户配置(导出功能)
        let conf = ysApplication.loginUser.conf
        if conf == nil {
            return
        }
        
        let export_my_winning_comp = conf["export_my_winning_comp"] as? Int
        
        if export_my_winning_comp == nil {
            return
        }
        
        if export_my_winning_comp! == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = retainRightItem
        }
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
    func fetchChildInfo(shouldCache: Bool) {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSChildExperience.fetchChildExperience(shouldCache, startIndex: loadFindWorkIndex, num: 20) { [weak self] (resp_child_experience: YSChildPersonalExperience!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if self!.originTableViewFooterOrigin.y == 0 {
                self!.originTableViewFooterOrigin = self!.tableView.footer!.frame.origin
            }
            
            self!.isLoading = false
            
            if self!.isLoadMore {

                if resp_child_experience == nil || resp_child_experience.lst_child_competition_info.count < 1 {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                    return
                }
                
                if resp_child_experience != nil {
                    for competitionInfo in resp_child_experience.lst_child_competition_info {
                        self!.lst_experienceInfo.append(competitionInfo)
                    }
                    
                    self!.tableView.reloadData()
                } else {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                }
                
                return
            }
            
            self!.childExperience = resp_child_experience
            self!.lst_experienceInfo = resp_child_experience.lst_child_competition_info
            self!.tableView.footer!.frame.origin = self!.originTableViewFooterOrigin
            self!.tableView.footer!.state = MJRefreshFooterStateIdle
            self!.tableView.reloadData()
        }
    }
    
    func configureRefreshView() {
        
        self.tableView.addLegendHeaderWithRefreshingBlock { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            if self!.isLoading {
                return
            }
            
            self!.isLoadMore = false
            self!.isLoading = true
            
            self!.loadFindWorkIndex = 0
            
            self!.fetchChildInfo(true)
            
            self!.loadFindWorkIndex += 20
            
            self!.tableView.header!.endRefreshing()
        }
        
        self.tableView.header!.setTitle("下拉可以刷新", forState: MJRefreshHeaderStateIdle)
        self.tableView.header!.setTitle("松开进行刷新", forState: MJRefreshHeaderStatePulling)
        self.tableView.header!.setTitle("正在刷新数据中...", forState: MJRefreshHeaderStateRefreshing)
        self.tableView.header!.font = UIFont.systemFontOfSize(13.0)
        self.tableView.header!.textColor = UIColor.lightGrayColor()
        
        self.tableView.addLegendFooterWithRefreshingBlock { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            if self!.isLoading {
                return
            }
            
            self!.isLoadMore = true
            self!.isLoading = true
            
            self!.fetchChildInfo(false)
            
            self!.loadFindWorkIndex += 20
            
            self!.tableView.footer!.endRefreshing()
        }
        
        self.tableView.footer!.automaticallyRefresh = false
        self.tableView.footer!.setTitle("上拉可以刷新", forState: MJRefreshFooterStateIdle)
        self.tableView.footer!.setTitle("已无更多内容", forState: MJRefreshFooterStateNoMoreData)
        self.tableView.footer!.setTitle("正在刷新数据中...", forState: MJRefreshFooterStateRefreshing)
        self.tableView.footer!.font = UIFont.systemFontOfSize(13.0)
        self.tableView.footer!.textColor = UIColor.lightGrayColor()
    }
    
    // MARK: - Actions
    
    @IBAction func output(sender: AnyObject) {
        
        tips.showActivityIndicatorViewInMainThread(self, text: "正在获取获奖信息")
        
        YSCompetition.fetchExperience { [weak self] (resp_pdf_url: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if NSURL(string: resp_pdf_url) == nil {
                self!.tips.showTipsInMainThread(Text: "导出信息有误")
                return
            }
            
            UIApplication.sharedApplication().openURL(NSURL(string: resp_pdf_url)!)
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
        var rowCount = 0
        if childExperience != nil {
            rowCount++
            if lst_experienceInfo.count > 0 {
                rowCount += lst_experienceInfo.count
            }
        }
        return rowCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("YSChildExperienceTopCell", forIndexPath: indexPath)
            
            if childExperience == nil {
                return cell
            }

            let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
            let lab_name = cell.contentView.viewWithTag(12) as! UILabel
            let lab_note = cell.contentView.viewWithTag(13) as! UILabel
            

            img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(childExperience.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                
                if self == nil {
                    return
                }
                
                img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.childExperience.avatar).0
            })
            lab_name.text = childExperience.realname
            lab_note.text = childExperience.personal_profile
            let height = lab_note.sizeThatFits(CGSize(width: SCREEN_WIDTH-160-8, height: 999)).height
            for constraint in lab_note.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint .constant = height > 19 ? height : 19
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("YSChildExperienceNormalCell", forIndexPath: indexPath)
            
            if childExperience == nil || lst_experienceInfo == nil {
                return cell
            }
            
            let experienceInfo = lst_experienceInfo[indexPath.row - 1]
            let leftLine = cell.contentView.viewWithTag(11)!
            let leftDot = cell.contentView.viewWithTag(12) as! UIImageView
            let lab_date = cell.contentView.viewWithTag(13) as! UILabel
            let lab_competitionName = cell.contentView.viewWithTag(14) as! UILabel
            let lab_rank = cell.contentView.viewWithTag(15) as! UILabel
            let lab_title = cell.contentView.viewWithTag(16) as! UILabel
            let img_contentBg = cell.contentView.viewWithTag(17) as! UIImageView
            
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
            
            var labelHeight = lab_competitionName.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 999)).height
            for constraint in lab_competitionName.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = labelHeight > 17 ? labelHeight : 17
                }
            }
            
            if(experienceInfo.rank_status == 0)
            {
                lab_rank.text = "评分中"
            }
            else
            {
                lab_rank.text = experienceInfo.ranking.integerValue < 1 ? "评分中" : "比赛名次：第\(experienceInfo.ranking)名"
            }
            
            lab_title.text = "作品名：" + experienceInfo.work_title
            
            labelHeight = lab_title.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 999)).height
            for constraint in lab_title.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = labelHeight > 17 ? labelHeight : 17
                }
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if childExperience == nil {
            return 0.0
        }
        
        if indexPath.row == 0 {
            
            let minHeight: CGFloat = 20 + 140 + 10
            var height: CGFloat = 15 + 21
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.ByCharWrapping
            label.font = UIFont.systemFontOfSize(15.0)
            label.text = childExperience.personal_profile
            let labelHeight = label.sizeThatFits(CGSize(width: SCREEN_WIDTH-160-8, height: 999)).height
            height +=  labelHeight > 19 ? labelHeight : 19
            return minHeight >= height ? minHeight : height
        } else {
            
            let experienceInfo = lst_experienceInfo[indexPath.row - 1]
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: ExperienceInfoWidth, height: 17))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.ByCharWrapping
            label.font = UIFont.systemFontOfSize(17.0)
            label.text = experienceInfo.competition_name
            var labelHeight1 = label.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 999)).height
            labelHeight1 = (labelHeight1 >= 17 ? labelHeight1 : 17)
            label.text = "作品名：" + experienceInfo.work_title
            var labelHeight2 = label.sizeThatFits(CGSize(width: ExperienceInfoWidth, height: 999)).height
            labelHeight2 = (labelHeight2 >= 17 ? labelHeight2 : 17)
            return 40 + 21 + 8 + labelHeight1 + 5 + 17 + labelHeight2 + 5 + 10
        }
    }
}
