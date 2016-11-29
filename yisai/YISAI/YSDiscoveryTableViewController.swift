//
//  YSDiscoveryTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSDiscoveryTableViewController: UITableViewController {
    public class SCCamera{
        
        /**
         当前设备的相机是否可用
         
         :returns: 可用返回true，否则返回false
         */
        public class func isAvailable()->Bool{
            return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        }
    }
    
    private struct AssociatedKeys {
        static var GetTopCell = "GetTopCell"
        static var GetFindWork = "GetFindWork"
        static var GetRecordButton = "GetRecordButton"
        static var GetSlide = "GetSlide"
    }
    
    
    var arr_findWork: [YSDiscoveryMainFindWork]!
    var arr_slide: [YSDiscoveryMainSlide]!
    var loadFindWorkIndex: Int = 0
    var isLoadMore: Bool = false
    var isLoading: Bool = false
    var originTableViewFooterOrigin: CGPoint = CGPoint(x: 0, y: 0)
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var retainLeftItem: UIBarButtonItem!
    var retainRightItem: UIBarButtonItem!
    var guideView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = FETips()
        tips.duration = 1
        
        configureRefreshView()
        
        if retainLeftItem == nil {
//
            retainLeftItem = navigationItem.leftBarButtonItem!
        }
        
        if retainRightItem == nil {
            retainRightItem = navigationItem.rightBarButtonItem!
        }
        
        loadFindWorkIndex = 0
        fetchUIData(true)
        loadFindWorkIndex += 20
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if YSGuide.getUserGuideDiscovery() == 0 {
            configureGuideView()
        }
        

        
        self.navigationController?.navigationBarHidden = false
        
        self.tabBarController?.tabBar.hidden = false
        
//        let handleRoleType = (ysApplication.loginUser.role_type == nil || ysApplication.loginUser.role_type == UserRoleType.Judge.rawValue || ysApplication.loginUser.role_type == UserRoleType.Teacher.rawValue || ysApplication.loginUser.role_type == UserRoleType.TeacherAndJudge.rawValue)
        let handleRoleType = ysApplication.loginUser.role_type == nil
        
      //  if handleRoleType {
          //  navigationItem.leftBarButtonItem = nil
       // } else {
            if navigationItem.leftBarButtonItem == nil {
                navigationItem.leftBarButtonItem = retainLeftItem
            }
            
            // 用户配置(发现拍摄功能，搜索功能)
            let conf = ysApplication.loginUser.conf
            if conf == nil {
                return
            }
            
            let discovery_recording = conf["discovery_recording"] as? Int
            let discovery_search = conf["discovery_search"] as? Int
            
            if discovery_recording == nil || discovery_search == nil {
                return
                
            }
            
            if discovery_recording! == 0 {
                navigationItem.leftBarButtonItem = nil
            } else {
                navigationItem.leftBarButtonItem = retainLeftItem
            }
            
            if discovery_search! == 0 {
                navigationItem.rightBarButtonItem = nil
            } else {
                navigationItem.rightBarButtonItem = retainRightItem
            }
       // }
        
       
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "tableRefreshView", name: YSDiscoveryReflashNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
       // NSNotificationCenter.defaultCenter().removeObserver(self, name: YSDiscoveryReflashNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    


    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchUIData(shouldCache: Bool) {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSDiscovery.findModule(shouldCache, startIndex: loadFindWorkIndex, fetchNum: 20) { [weak self] (resp_lst_findWork: [YSDiscoveryMainFindWork]!, resp_lst_slide: [YSDiscoveryMainSlide]!, errorMsg: String!) -> Void in
            
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
                
                if resp_lst_findWork == nil || resp_lst_findWork.count < 1 {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                    return
                }
                
                if resp_lst_findWork != nil {
                    for findWork in resp_lst_findWork {
                        self!.arr_findWork.append(findWork)
                    }
                    
                    self!.tableView.reloadData()
                } else {
                    self!.tableView.footer!.state = MJRefreshFooterStateNoMoreData
                }
                return
            }
            
            self!.arr_findWork = resp_lst_findWork
            self!.arr_slide = resp_lst_slide
            self!.tableView.footer!.frame.origin = self!.originTableViewFooterOrigin
            self!.tableView.footer!.state = MJRefreshFooterStateIdle
            self!.tableView.reloadData()
        }
    }
    
    // MARK: - Configurations
    
    func configureGuideView() {
        
        if guideView != nil {
            return
        }
        
        if ysApplication.loginUser.role_type != "1" {
            return
        }
        
        guideView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        if SCREEN_WIDTH == 320 {
            guideView.image = UIImage(named: "guide_discovery_320")
        } else if SCREEN_WIDTH == 375 {
            guideView.image = UIImage(named: "guide_discovery_375")
        } else if SCREEN_WIDTH == 414 {
            guideView.image = UIImage(named: "guide_discovery_414")
        }
        guideView.contentMode = UIViewContentMode.TopLeft
        guideView.userInteractionEnabled = true
        guideView.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGuideView:")
        guideView.addGestureRecognizer(tapGesture)
        
        ysApplication.tabbarController.view.addSubview(guideView)
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
            
            self!.fetchUIData(true)
            
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
            
            self!.fetchUIData(false)
            
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

    
    func tableRefreshView()  {
        
         self.fetchUIData(true)
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
        var num = 0
        if arr_slide != nil {
            num += 1
        }
        
        if arr_findWork != nil {
            num += (arr_findWork.count + 1) / 2
        }
        return num
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let topCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryTopCell")
            
            if arr_slide != nil {
                let scrollView = topCell!.contentView.viewWithTag(10) as! UIScrollView
                let pageControl = topCell!.contentView.viewWithTag(11) as! UIPageControl
                
                scrollView.delegate = self
                
                for subview in scrollView.subviews {
                    subview.removeFromSuperview()
                }
                
                for i in 0 ..< arr_slide.count {
                    let slide = arr_slide[i]
                    let imageView = UIImageView(frame: CGRect(x: SCREEN_WIDTH * CGFloat(i), y: 0, width: SCREEN_WIDTH, height: scrollView.bounds.size.height))
                    
                    imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(slide.photo, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                        [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                        if self == nil { return }
                        imageView.image = self!.feiOSHttpImage.loadImageInCache(slide.photo).0
                        })
                    
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.userInteractionEnabled = true
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: "tapSlide:")
                    imageView.addGestureRecognizer(tapGesture)
                    
//                    objc_setAssociatedObject(tapGesture, &AssociatedKeys.GetSlide, slide, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    objc_setAssociatedObject(tapGesture, &AssociatedKeys.GetSlide, slide, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    
                    
                    scrollView.addSubview(imageView)
                }
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(arr_slide.count), height: 0)
                pageControl.numberOfPages = arr_slide.count
                objc_setAssociatedObject(self, &AssociatedKeys.GetTopCell, topCell,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return topCell!
        }
        
        
        let normalCell = tableView.dequeueReusableCellWithIdentifier("YSDiscoveryNormalCell", forIndexPath: indexPath)
        
        if arr_findWork == nil {
            return normalCell
        }
            
        let index = 2 * indexPath.row - 2
        if index <= arr_findWork.count - 1 {
            let findwork = arr_findWork[index]
            let l_btn_toDetail = normalCell.contentView.viewWithTag(11) as! UIButton
            let l_img_video = normalCell.contentView.viewWithTag(12) as! UIImageView
            let l_img_avatar = normalCell.contentView.viewWithTag(13) as! UIImageView
            let l_lab_title = normalCell.contentView.viewWithTag(14) as! UILabel
            let l_lab_praise = normalCell.contentView.viewWithTag(15) as! UILabel
            
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
        
        let r_bgView = normalCell.contentView.viewWithTag(20)
        let r_btn_toDetail = normalCell.contentView.viewWithTag(21) as! UIButton
        let r_img_video = normalCell.contentView.viewWithTag(22) as! UIImageView
        let r_img_avatar = normalCell.contentView.viewWithTag(23) as! UIImageView
        let r_lab_title = normalCell.contentView.viewWithTag(24) as! UILabel
        let r_lab_praise = normalCell.contentView.viewWithTag(25) as! UILabel
        
        if index + 1 <= arr_findWork.count - 1 {
            r_bgView?.hidden = false
            
            let findwork = arr_findWork[index+1]
            
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
            r_bgView?.hidden = true
        }
        
        return normalCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return SCREEN_WIDTH * 160 / 414
        }
        
        return (SCREEN_WIDTH / 2 - 8) * 245 / 292 + 5
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if objc_getAssociatedObject(self, &AssociatedKeys.GetTopCell) == nil {
            return
        }
        let cell = objc_getAssociatedObject(self, &AssociatedKeys.GetTopCell) as! UITableViewCell
        let pageControl = cell.contentView.viewWithTag(11) as! UIPageControl
        pageControl.currentPage = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
    }
    
    // MARK: - Actions
    
    func tapSlide(tapGesture: UITapGestureRecognizer) {
        
        let slide = objc_getAssociatedObject(tapGesture, &AssociatedKeys.GetSlide) as? YSDiscoveryMainSlide
        if slide == nil {
            return
        }
        
        if slide!.type == nil {
            return
        }
        
        if slide!.type == 0 {
            // web链接
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
            controller.requestUrl = NSURL(string: slide!.advertisement_url)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            
        } else {
            
            let controller = UIStoryboard(name: "YSCompetition", bundle: nil).instantiateViewControllerWithIdentifier("YSCompetitionDetailViewController") as! YSCompetitionDetailViewController
            controller.cpid = slide!.advertisement_cpid
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tapGuideView(tapGesture: UITapGestureRecognizer) {
        
        guideView.hidden = true
        guideView.removeFromSuperview()
        
        YSGuide.setUserGuideDiscovery(1)
    }
    
    func gotoDetail(button: UIButton) {
        
        let findwork = objc_getAssociatedObject(button, &AssociatedKeys.GetFindWork) as? YSDiscoveryMainFindWork
        if findwork == nil {
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSDiscoveryDetailViewController") as! YSDiscoveryDetailViewController
        controller.wid = findwork!.wid
        controller.movieURL = findwork!.video_url
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func gotoRecord(sender: AnyObject) {
        
//        let controller = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
//        controller.cameraMovieStyle = .Discovery
        
       
        //未登录
        if ysApplication.loginUser.uid == nil
        {
            //ysApplication.switchViewController(HOME_VIEWCONTROLLER)
            gotoLogin()
            return
        }else{
            //--------------张继忠--------------------
            
            if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == AVAuthorizationStatus.NotDetermined
            {
                self.tips.showTipsInMainThread(Text: "请打开摄像头权限")
                return
            }
       
            
            //--------------张继忠--------------------
       
        }
    
        let controller  = YSCameraViewController()
        
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
        
        controller.type = .Discovery
        controller.hidesBottomBarWhenPushed = true
        
        self.navigationController?.navigationBarHidden = true
        
        self.navigationController!.pushViewController(controller, animated: false)
        
        
      //  ysApplication.tabbarController.presentViewController(controller, animated: true, completion: nil)
    }
    
    func gotoLogin() {
        
        //   ysApplication.switchViewController(HOME_VIEWCONTROLLER)
        
        // print("hahahah")
        let controller = YSLoginViewController()
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        
        controller.hidesBottomBarWhenPushed = true
        
        self.navigationController!.view.layer .addAnimation(transition, forKey: nil)
      //  self.navigationController
        
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
}
