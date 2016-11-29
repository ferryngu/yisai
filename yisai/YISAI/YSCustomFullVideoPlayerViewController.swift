//
//  YSCustomFullVideoPlayerViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/19.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCustomFullVideoPlayerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var movieController: MoviePlayerController!
    var contentURLStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configurePlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configurePlayer() {
        
        movieController = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
        movieController.style = .None
        movieController.contentURL = NSURL(string: contentURLStr)
        self.addChildViewController(movieController)
        movieController.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 80.0 / 207.0)
        self.containerView.addSubview(movieController.view)
        movieController.setupPlayingVideo()
        movieController.didMoveToParentViewController(self)
    }
    
    @IBAction func tapView(sender: AnyObject) {
        
        if movieController != nil {
            movieController.stopPlayingVideo()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
