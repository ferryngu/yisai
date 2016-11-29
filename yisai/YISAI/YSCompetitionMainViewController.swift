//
//  YSCompetitionMainViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/19.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionMainViewController: UITableViewController {

    
    var wcid: String!
    var lst_competitionInfo: [YSMainCompetitionInfo]!
    var loadFindWorkIndex: Int = 0
    var isLoadMore: Bool = false
    var isLoading: Bool = false
    var originTableViewFooterOrigin: CGPoint = CGPoint(x: 0, y: 0)
    let lab_noCompetion = UILabel()
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var type: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // 需求变动前
//        YSCompetitionMainReuseImageNotification = "YSCompetitionMainReuseImageNotification" + "_\(wcid)"
        // ---------
        // 需求变动后
   
        // ---------
        
        tips.duration = 1
        
        configureNoCompLab()
        
        configureRefreshView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        
        self.tabBarController?.tabBar.hidden = false
        
        // 需求变动前
//        type = nil
        // -----
        // 需求变动后
        // ------
        loadFindWorkIndex = 0
        isLoadMore = false
        fetchCompetitionInfo(true, type: type)
        loadFindWorkIndex += 20
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

    func configureNoCompLab() {
        
        lab_noCompetion.frame = CGRect(x: 0, y: 0, width: 200, height: 19)
        lab_noCompetion.center = CGPoint(x: view.center.x, y: 50)
        lab_noCompetion.text = "没有该状态的赛事"
        lab_noCompetion.textColor = UIColor.darkTextColor()
        lab_noCompetion.textAlignment = NSTextAlignment.Center
        lab_noCompetion.font = UIFont.boldSystemFontOfSize(15.0)
        view.addSubview(lab_noCompetion)
        lab_noCompetion.hidden = true
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
            
            self!.fetchCompetitionInfo(true, type: self!.type)
            
            self!.loadFindWorkIndex += 20
            
            self!.tableView.header!.endRefreshing()
        }
        
        self.tableView.header!.setTitle("下拉可以刷新", forState: MJRefreshHeaderStateIdle)
        self.tableView.header!
            .setTitle("松开进行刷新", forState: MJRefreshHeaderStatePulling)
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
            
            self!.fetchCompetitionInfo(false, type: self!.type)
            
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

    
    func fetchCompetitionInfo(shouldCache: Bool, type: Int!) {
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getMainCompetitionInfo(shouldCache, wcid: wcid, type: type, startIndex: loadFindWorkIndex, fetchNum: 20) { [weak self] (resp_competition_info: [YSMainCompetitionInfo]!, errorMsg: String!) -> Void in
            
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
                
                if self!.lst_competitionInfo == nil {
                    return
                }
                
                if resp_competition_info == nil || resp_competition_info.count < 1 {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                    return
                }
                
                if resp_competition_info != nil {
                    for competitionInfo in resp_competition_info {
                        self!.lst_competitionInfo.append(competitionInfo)
                    }
                    
                    self!.tableView.reloadData()
                } else {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                }
                
                return
            }
            
            // 赛事列表为空
            if resp_competition_info.count < 1 {
                self!.lab_noCompetion.hidden = false
            } else {
                self!.lab_noCompetion.hidden = true
            }
            
            self!.lst_competitionInfo = resp_competition_info
            self!.tableView.footer!.frame.origin = self!.originTableViewFooterOrigin
            self!.tableView.footer!.state = MJRefreshFooterStateIdle
            self!.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lst_competitionInfo != nil ? lst_competitionInfo.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSCompetitionMainCell")

        // Configure the cell...
        if lst_competitionInfo.count < 1 {
            return cell!
        }
        
        let imageView = cell!.contentView.viewWithTag(11) as! UIImageView
        let lab_match_name = cell!.contentView.viewWithTag(12) as! UILabel
        let lab_other_info = cell!.contentView.viewWithTag(13) as! UILabel
        let img_competition_state = cell!.contentView.viewWithTag(14) as! UIImageView
        
        let competitionInfo = lst_competitionInfo[indexPath.row]

        // 比赛状态
        if competitionInfo.competition_process != nil {
            
            var imageName = ""
            switch competitionInfo.competition_process {
            case "0":
                imageName = "cs_jijiangkaishi"
            case "1":
                imageName = "cs_kaishibaoming"
            case "2":
                imageName = "cs_bisaijingxing"
            case "3":
                imageName = "cs_bisaijieshu"
            default:
                break
            }
            img_competition_state.image = UIImage(named: imageName)
        }
        

        imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(competitionInfo.cover_plan, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            
            if self == nil {
                return
            }
            
            imageView.image = self!.feiOSHttpImage.loadImageInCache(competitionInfo.cover_plan).0
            })
        
        lab_match_name.text = competitionInfo.match_name
        lab_other_info.text = "报名时间：" + competitionInfo.start_time + "-" + competitionInfo.last_time + "                    " + "已有\(competitionInfo.register_number)人报名"
        

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (SCREEN_WIDTH - 5 * 2) * 53 / 102 + 65
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if lst_competitionInfo.count < 1 {
            return
        }
        
        MobClick.event("competion_detail", attributes: ["result": "success"])
        
        
        let competitionInfo = lst_competitionInfo[indexPath.row]
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("YSCompetitionDetailViewController") as! YSCompetitionDetailViewController
        controller.cpid = competitionInfo.cpid
        controller.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController!.pushViewController(controller, animated: true)
    }
}
