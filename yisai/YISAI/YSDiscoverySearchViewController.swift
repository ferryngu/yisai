//
//  YSDiscoverySearchViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/18.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSDiscoverySearchViewController: UITableViewController, UISearchBarDelegate {
    
    private struct AssociatedKeys {
        static var GetFindWork = "GetFindWork"
        static var GetKeyword = "GetKeyword"
    }
    @IBOutlet weak var searchBarBgView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lst_findWork: [YSDiscoveryMainFindWork]!
    var lst_hot_search: [YSDiscoveryHotSearch]!

    var enterSearch: Bool = false
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    private let btn_hotViewOriginX = 10
    private let btn_hotViewOriginY = 45
    private var btn_hotWidth: CGFloat = 0.0
    private var btn_hotHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tips = FETips()
        tips.duration = 1
        
        btn_hotWidth = (SCREEN_WIDTH - 10 * 2 - 5 * 4) / 5
        btn_hotHeight = (SCREEN_WIDTH - 10 * 2 - 5 * 4) / 5 * 0.45
        
        fetchHotSearch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchBarBgView.bounds.size = CGSize(width: SCREEN_WIDTH - 16 - 54, height: self.searchBarBgView.bounds.size.height)

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
    func fetchHotSearch() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSDiscovery.getHotSearch() { [weak self] (resp_lst_hot_search: [YSDiscoveryHotSearch]!, errorMsg: String!) -> Void in
            
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
            
            self!.lst_hot_search = resp_lst_hot_search
            self!.tableView.reloadData()
        }
    }
    
    func fetchSearch(searchTitle:String) {

       /////////////////////
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSDiscovery.searchFindWork(searchTitle, startIndex: 0, fetchNum: 100, resp: { [weak self] (resp_lst_findWork: [YSDiscoveryMainFindWork]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_findWork = resp_lst_findWork
            self!.tableView.reloadData()
            
            if self!.lst_findWork.count < 1 {
                if self!.navigationController != nil {
                    self!.tips.showTipsInMainThread(Text: "没有作品")
                }
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func closeView(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goSearch(button: UIButton) {
        
        enterSearch = true
        let keyword = objc_getAssociatedObject(button, &AssociatedKeys.GetKeyword) as! String
        self.searchBar.text = keyword
        fetchSearch(keyword)
    }
    
    func gotoDetail(button: UIButton) {
        
        let findwork = objc_getAssociatedObject(button, &AssociatedKeys.GetFindWork) as? YSDiscoveryMainFindWork
        if findwork == nil {
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSDiscoveryDetailViewController") as! YSDiscoveryDetailViewController
        controller.wid = findwork!.wid
        controller.movieURL = findwork!.video_url
        print(controller.wid)
        print(controller.movieURL)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if enterSearch {
            return lst_findWork != nil ? (lst_findWork.count + 1) / 2 : 0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let hotCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoverySearchHotCell")
        let normalCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryNormalCell")

        // Configure the cell...
        if enterSearch {
            
            if lst_findWork != nil {
                
                let index = 2 * (indexPath.row + 1) - 2
                
                if index <= lst_findWork.count - 1 {
                    let findwork = lst_findWork[index]
                    let l_btn_toDetail = normalCell!.contentView.viewWithTag(11) as! UIButton
                    let l_img_video = normalCell!.contentView.viewWithTag(12) as! UIImageView
                    let l_img_avatar = normalCell!.contentView.viewWithTag(13) as! UIImageView
                    let l_lab_title = normalCell!.contentView.viewWithTag(14) as! UILabel
                    let l_lab_praise = normalCell!.contentView.viewWithTag(15) as! UILabel
                    
                    l_btn_toDetail.addTarget(self, action: #selector(YSDiscoverySearchViewController.gotoDetail(_:)), forControlEvents: .TouchUpInside)
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
                
                let r_bgView = normalCell!.contentView.viewWithTag(20)
                let r_btn_toDetail = normalCell!.contentView.viewWithTag(21) as! UIButton
                let r_img_video = normalCell!.contentView.viewWithTag(22) as! UIImageView
                let r_img_avatar = normalCell!.contentView.viewWithTag(23) as! UIImageView
                let r_lab_title = normalCell!.contentView.viewWithTag(24) as! UILabel
                let r_lab_praise = normalCell!.contentView.viewWithTag(25) as! UILabel
                
                if index + 1 <= lst_findWork.count - 1 {
                    r_bgView?.hidden = false
                    
                    let findwork = lst_findWork[index+1]
                    
                    r_btn_toDetail.addTarget(self, action: #selector(YSDiscoverySearchViewController.gotoDetail(_:)), forControlEvents: .TouchUpInside)
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
                    r_bgView?.hidden = true
                }
            }

            
            return normalCell!
        } else {
            
            if lst_hot_search != nil {
                for index in 0..<lst_hot_search.count{
                    let hot_search = lst_hot_search[index]
                    let btnOriginY = btn_hotViewOriginY + (8 + Int(btn_hotHeight)) * (index / 5)
                    let btnOriginX = btn_hotViewOriginX + (5 + Int(btn_hotWidth)) * (index % 5)
                    
                    let btn_hot = UIButton(frame: CGRect(x: btnOriginX, y: btnOriginY, width: Int(btn_hotWidth), height: Int(btn_hotHeight)))
                    btn_hot.addTarget(self, action: #selector(YSDiscoverySearchViewController.goSearch(_:)), forControlEvents: .TouchUpInside)
                    objc_setAssociatedObject(btn_hot, &AssociatedKeys.GetKeyword, hot_search.keyword, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    btn_hot.setAttributedTitle(NSAttributedString(string: hot_search.keyword, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(btn_hotHeight - 15)]), forState: .Normal)
                    btn_hot.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    btn_hot.setBackgroundImage(UIImage(named: "ssy_diwen"), forState: .Normal)
                    hotCell!.contentView.addSubview(btn_hot)
                }
            }

            
                
                
//                for (index, hot_search) in enumerate(lst_hot_search) {
//                    
//                    let btnOriginY = btn_hotViewOriginY + (8 + Int(btn_hotHeight)) * (index / 5)
//                    let btnOriginX = btn_hotViewOriginX + (5 + Int(btn_hotWidth)) * (index % 5)
//
//                    let btn_hot = UIButton(frame: CGRect(x: btnOriginX, y: btnOriginY, width: Int(btn_hotWidth), height: Int(btn_hotHeight)))
//                    btn_hot.addTarget(self, action: "goSearch:", forControlEvents: .TouchUpInside)
//                    objc_setAssociatedObject(btn_hot, &AssociatedKeys.GetKeyword, hot_search.keyword, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                    if #available(iOS 8.2, *) {
//                        btn_hot.setAttributedTitle(NSAttributedString(string: hot_search.keyword, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(btn_hotHeight - 15, weight: 2.0)]), forState: .Normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                    btn_hot.setTitleColor(UIColor.blackColor(), forState: .Normal)
//                    btn_hot.setBackgroundImage(UIImage(named: "ssy_diwen"), forState: .Normal)
//                    hotCell!.contentView.addSubview(btn_hot)
//                }
            
            return hotCell!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if enterSearch {
            return SCREEN_WIDTH / 2 * 173 / 207
        } else {
            if lst_hot_search == nil || lst_hot_search.count < 1 {
                return 44.0
            } else {
                return CGFloat(44 + (8 + Int(btn_hotHeight)) * ((lst_hot_search.count - 1) / 3 + 1))
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        enterSearch = true
        searchBar.endEditing(true)
        
        if searchBar.text == nil || checkInputEmpty(searchBar.text) {
            searchBar.text = nil
            enterSearch = false
            self.tableView.reloadData()
            return
        }
        
        fetchSearch(searchBar.text!)
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        if searchBar.text == nil || checkInputEmpty(searchBar.text) {
            searchBar.text = nil
            enterSearch = false
            self.tableView.reloadData()
        }
        
        return true
    }
}
