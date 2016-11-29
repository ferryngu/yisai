//
//  MoviePlayerContainerViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/6.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum PlayerContainerType {
    case Discovery
    case Competition
}

class MoviePlayerContainerViewController: UIViewController {

    var movieController: MoviePlayerController!
    @IBOutlet weak var containerView: UIView!
    var movieName: String!
    var contentURLStr: String!
    var type: PlayerContainerType!
    var cpid: String!
    var crid: String!
    var recordTouchStatus: Bool = false
    var commitTouchStatus: Bool = false
    var matchName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configurePlayer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configurePlayer() {
        
        movieController = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
        movieController.style = .None
        movieController.contentURL = NSURL(fileURLWithPath: contentURLStr)
        self.addChildViewController(movieController)
        movieController.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 480.0 / 864.0)
        self.containerView.addSubview(movieController.view)
        movieController.setupPlayingVideo()
        movieController.didMoveToParentViewController(self)
    }
    
    // MARK: - Actions
    
    @IBAction func closeView(sender: AnyObject) {
        
        if movieController != nil {
            movieController.stopPlayingVideo()
        }
      //  self.dismissViewControllerAnimated(true, completion: nil)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }

    @IBAction func goToRecord(sender: AnyObject) {
        
        if recordTouchStatus {
            return
        }
        
        recordTouchStatus = true
        
        let controller = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
        if type == .Discovery {
            controller.cameraMovieStyle = .Discovery
        } else {
            controller.cpid = cpid
            controller.crid = crid
            controller.cameraMovieStyle = .Competition
            controller.matchName = matchName
        }
       // self.dismissViewControllerAnimated(false, completion: { [weak self] () -> Void in
         //   self!.movieController.stopPlayingVideo()
       // })
        //ysApplication.tabbarController.presentViewController(controller, animated: true, completion: nil)
        
        let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
        
        nav.popToRootViewControllerAnimated(true)
        

        controller.hidesBottomBarWhenPushed = true
            
        nav.pushViewController(controller, animated: false)
            
            
      
    }
    
    @IBAction func commitMovie(sender: AnyObject) {
        
        if commitTouchStatus {
            return
        }
        
        commitTouchStatus = true
        
        self.dismissViewControllerAnimated(false, completion: { [weak self] () -> Void in
            self!.movieController.stopPlayingVideo()
        })
        
       // let publishViewController = UIStoryboard(name: "YSPublish", bundle: nil).instantiateViewControllerWithIdentifier("YSPublishViewController") as! YSPublishViewController
        let publishViewController = YSPulishInformationViewController()
        
        if type == .Discovery {
            publishViewController.type = .Discovery
        } else {
            publishViewController.cpid = cpid
            publishViewController.type = .Competition
            publishViewController.crid = crid
            if matchName != nil {
                publishViewController.matchName = matchName
            }
        }
        print("container movieName: \(movieName) \n moviePath = \(contentURLStr)", terminator: "")
       // let navController = UINavigationController(rootViewController: publishViewController)
        publishViewController.contentURLStr = contentURLStr
        publishViewController.movieName = movieName
        
        
        let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
        
        nav.popToRootViewControllerAnimated(true)
        
        
        publishViewController.hidesBottomBarWhenPushed = true
        
        nav.pushViewController(publishViewController, animated: false)
    }
    
    @IBAction func playMovie(sender: AnyObject) {
        movieController.moviePlayer.stop()
        movieController.moviePlayer.play()
    }
}
