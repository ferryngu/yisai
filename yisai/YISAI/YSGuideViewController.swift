//
//  YSGuideViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSGuideViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH * 4, height: SCREEN_HEIGHT)
        
        setupImageViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupImageViews() {
        
        let imagePaths = ["tu_guide1", "tu_guide2", "tu_guide3", "tu_guide4"]
        
        for var i = 0; i < 4; i++ {
            let imageView = UIImageView(frame: CGRect(x: SCREEN_WIDTH * CGFloat(i), y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: imagePaths[i])
            imageView.userInteractionEnabled = true
            
            if i == 3 {
                
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 207, height: 40))
                button.setImage(UIImage(named: "start_app_btn"), forState: .Normal)
                button.center = CGPoint(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT - 75.0 * SCREEN_HEIGHT / 480)
                button.addTarget(self, action: "enterMainViewController", forControlEvents: .TouchUpInside)
                imageView.addSubview(button)
            }
            
            scrollView.addSubview(imageView)
        }
    }
    
    // MARK: - Action
    
    func enterMainViewController() {
        
        ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
    }
}
