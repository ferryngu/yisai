//
//  YSMyFindworkViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/3.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyFindworkViewController: UITableViewController {

    private let NewestColor = UIColor(red: 232.0/255.0, green: 158.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private let OldColor = UIColor(red: 167.0/255.0, green: 214.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    
    private struct AssociatedKeys {
        static var GetFindWork = "GetFindWork"
    }
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var lst_findwork: [YSDiscoveryMainFindWork]!
    var lst_filter_findwork: [[YSDiscoveryMainFindWork]]!
    var loadFindWorkIndex: Int = 0
    var isLoadMore: Bool = false
    var isLoading: Bool = false
    var originTableViewFooterOrigin: CGPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tips.duration = 1
        
        configureRefreshView()
        fetchMyFindwork(true)
        loadFindWorkIndex += 20
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
    func fetchMyFindwork(shouldCache: Bool) {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSMyFindwork.fetchMyFindwork(shouldCache, startIndex: loadFindWorkIndex, fetchNum: 20) { [weak self] (resp_lst_findwork: [YSDiscoveryMainFindWork]!, errorMsg: String!) -> Void in
            
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
                
                if resp_lst_findwork == nil || resp_lst_findwork.count < 1 {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                    return
                }
                
                if resp_lst_findwork != nil {
                    for findWork in resp_lst_findwork {
                        self!.lst_findwork.append(findWork)
                    }
                    self!.filterFindwork()
                } else {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                }
                return
            }

            self!.lst_findwork = resp_lst_findwork
            self!.tableView.footer!.frame.origin = self!.originTableViewFooterOrigin
            self!.tableView.footer!.state = MJRefreshFooterStateIdle
            self!.filterFindwork()
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
            
            self!.fetchMyFindwork(true)
            
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
            
            self!.fetchMyFindwork(false)
            
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
    
    /** 计算同一发表时间的作品，同一时间的制成列表 */
    func filterFindwork() {
        
        if lst_findwork.count < 1 {
            return
        }
        
        if lst_filter_findwork != nil {
            lst_filter_findwork.removeAll(keepCapacity: false)
        } else {
            lst_filter_findwork = [[YSDiscoveryMainFindWork]]()
        }
        
        var baseFindwork = lst_findwork[0]
        var t_lst_findwork = [YSDiscoveryMainFindWork]()
        
        for index in 0..<lst_findwork.count {
            let findwork = lst_findwork[index]
            if !isSameDay(NSDate(timeIntervalSince1970: baseFindwork.update_time!.doubleValue / 1000.0), theOtherDay: NSDate(timeIntervalSince1970: findwork.update_time!.doubleValue / 1000.0)) {
                lst_filter_findwork.append(t_lst_findwork)
                t_lst_findwork.removeAll(keepCapacity: false)
                t_lst_findwork.append(findwork)
                baseFindwork = findwork
            } else {
                t_lst_findwork.append(findwork)
            }
            
            if index == lst_findwork.count - 1 && t_lst_findwork.count > 0{
                lst_filter_findwork.append(t_lst_findwork)
            }
        }
            self.tableView.reloadData()
    }
        
    
    // MARK: - Actions
    
    func gotoDetail(button: UIButton) {
        
        let findwork = objc_getAssociatedObject(button, &AssociatedKeys.GetFindWork) as? YSDiscoveryMainFindWork
        if findwork == nil {
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
        return lst_filter_findwork == nil ? 0 : lst_filter_findwork.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lst_filter_findwork == nil || lst_filter_findwork.count < 1 ? 0 : (lst_filter_findwork[section].count + 1) / 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (SCREEN_WIDTH - 90) * 0.5 * 70 / 83 + 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if lst_findwork == nil || lst_findwork.count < 1 {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40))
        view.backgroundColor = UIColor.clearColor()
        
        let line = UIView(frame: CGRect(x: 40, y: 0, width: 1, height: 40))
        line.backgroundColor = section == 0 ? NewestColor : OldColor
        view.addSubview(line)
        
        let img_point = UIImageView(frame: CGRect(x: 30, y: 15, width: 20, height: 20))
        img_point.image = UIImage(named: section == 0 ? "cs_shijianzhouhongdian" : "cs_shijianzhoulandian")
        view.addSubview(img_point)
        
        let findwork = lst_filter_findwork[section][0]
        let lab_date = UILabel(frame: CGRect(x: 80, y: 15, width: 100, height: 20))
        lab_date.font = UIFont.systemFontOfSize(15.0)
        lab_date.textColor = UIColor.darkGrayColor()
        lab_date.text = formatTimeInterval(findwork.update_time!.doubleValue, type: 0)
        view.addSubview(lab_date)
        
        return view
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if lst_findwork == nil || lst_findwork.count < 1 {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 15))
        view.backgroundColor = UIColor.clearColor()
        
        let line = UIView(frame: CGRect(x: 40, y: 0, width: 1, height: 15))
        line.backgroundColor = section == 0 ? NewestColor : OldColor
        view.addSubview(line)
        
        return view
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("YSMyFindworkNormalCell")

        if lst_findwork == nil || lst_findwork.count < 1 {
            return cell!
        }
        
        let view = cell!.contentView.viewWithTag(1)
        if indexPath.section == 0 {
            view?.backgroundColor = NewestColor
        } else {
            view?.backgroundColor = OldColor
        }
        
        let index = 2 * (indexPath.row + 1) - 2
        if index <= lst_filter_findwork[indexPath.section].count - 1 {
            let findwork = lst_filter_findwork[indexPath.section][index]
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
            objc_setAssociatedObject(l_btn_toDetail, &AssociatedKeys.GetFindWork, findwork, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

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
        
        if index + 1 <= lst_filter_findwork[indexPath.section].count - 1 {
            r_bgView!.hidden = false
            
            let findwork = lst_filter_findwork[indexPath.section][index+1]
            
            r_btn_toDetail.addTarget(self, action: "gotoDetail:", forControlEvents: .TouchUpInside)
            objc_setAssociatedObject(r_btn_toDetail, &AssociatedKeys.GetFindWork, findwork, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            

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
            r_bgView!.hidden = true
//            r_btn_toDetail.hidden = true
        }
        
        return cell!
    }
}
