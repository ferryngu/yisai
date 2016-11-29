//
//  YSMarkingDetailViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/22.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMarkingDetailViewController: UIViewController  {
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var movieController: MoviePlayerController!
    var containerTableViewController: YSMarkingDetailTableViewController!

    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView: UIView!
    
    var crid: String!
    var marking_info: YSMarkingCompetitionInfo!
    var txf_score: UITextField!
    var txv_comment: UITextView!
    var lab_commentTextCount: UILabel!
    var commentText: String!
    var isConfirm: Bool = false
    var networkStatus: AFNetworkReachabilityStatus = .ReachableViaWiFi
    var img_video: UIImageView!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = FETips()
        tips.duration = 1
        
    
        
        fetchMarkingDetail()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    
    func configureBtnPlay() {
        
//        if img_video == nil {
//            img_video = UIImageView(frame: containerView.bounds)
//            containerView.addSubview(img_video)
//        }
//        if marking_info != nil || marking_info.video_img_url != nil {
//            img_video.image = feiOSHttpImage.asyncHttpImageInUIThread(marking_info.video_img_url, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
//                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
//                if self == nil { return }
//                self!.img_video.image = self!.feiOSHttpImage.loadImageInCache(self!.marking_info.video_img_url).0
//                })
//        }
//        img_video.contentMode = UIViewContentMode.ScaleAspectFill
//        img_video.clipsToBounds = true
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "tapImageVideo:")
//        img_video.addGestureRecognizer(tapGesture)
        
        handleNetwork()
    }
    
    func configurePlayer() {
        
        if movieController == nil && marking_info != nil && marking_info.video_url != nil {
            movieController = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
            movieController.contentURL = NSURL(string: marking_info.video_url)
            self.addChildViewController(movieController)
            movieController.view.frame = self.containerView.bounds
            movieController.clickBackHandler = popToLastNavigate
            self.containerView.addSubview(movieController.view)
//            movieController.setupPlayingVideo()
            movieController.didMoveToParentViewController(self)
        }
    }
    
    func configureTableView() {
//        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMarkingDetailTableViewController") as! YSMarkingDetailTableViewController
        
        guard let controller = self.containerTableViewController else { return }
        
        controller.marking_info = marking_info
        controller.crid = crid
        
        controller.configureTableView()
        
//        controller.tableView.reloadData()
    }
    
    func handleNetwork() {
        
        networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
        configurePlayer()
        
        switch networkStatus {
        case .NotReachable:
            let alertController = UIAlertController(title: nil, message: "网络不给力，请检测网络", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(action)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWWAN:
            self.networkStatus = AFNetworkReachabilityStatus.ReachableViaWWAN
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续观看?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                if self.movieController.moviePlayer == nil {
                    self.movieController.setupPlayingVideo()
                }
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWiFi:

            if self.movieController.moviePlayer == nil {
                self.movieController.setupPlayingVideo()
            }
        default:
            break
        }
    }
    
    func fetchMarkingDetail() {
        
        if crid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getMarkingDetailInfo(crid, resp: { [weak self] (resp_marking_info: YSMarkingCompetitionInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.marking_info = resp_marking_info
            self!.configureBtnPlay()
            self!.configureTableView()
        })
    }
    
    // MARK: - Actions
    
    func popToLastNavigate() {
        
        if movieController != nil && movieController.moviePlayer != nil {
            self.movieController.stopPlayingVideo()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tapImageVideo(tapGesture: UITapGestureRecognizer) {
        handleNetwork()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "WithMarkingDetailViewController" {
            
            guard let controller = segue.destinationViewController as? YSMarkingDetailTableViewController else {
                return
            }
            
            containerTableViewController = controller
        }
    }
}
