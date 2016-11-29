//
//  YSHomeViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSHomeViewController: UIViewController {
    
    
    var groupSelectViewController: YSHomeSelectViewController! // 身份选择
    var loginSelectViewController: YSHomeSelectViewController! // 选择登录注册
    var currentController: YSHomeSelectViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       // navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.createImageWithColor(UIColor.clearColor()), forBarMetrics: UIBarMetrics.Default)
    self.navigationController?.navigationBar.translucent = true

        
      //  self.navigationController?.navigationBar.backItem?.leftBarButtonItem?.setBackgroundImage(UIImage(named: "return_"), forState: .Normal, barMetrics: UIBarMetrics.Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
       // navigationController?.navigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.createImageWithColor(UIColor(red: 241.0/255.0, green: 87.0/255.0, blue: 81.0/255.0, alpha: 1)), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectUser(sender: AnyObject) {
        
        gotoHomeSelectViewController(1)
    }
    
    @IBAction func selectTeacher(sender: AnyObject) {
        
        gotoHomeSelectViewController(2)
    }
    
    @IBAction func selectJudge(sender: AnyObject) {
        
        gotoHomeSelectViewController(3)
    }
    
    @IBAction func tapBackItem(sender: UIBarButtonItem) {
        //dismissViewControllerAnimated(true, completion: nil)
        
         ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
    }
    
    func gotoHomeSelectViewController(role_type: Int) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSHomeSelectViewController") as! YSHomeSelectViewController
        controller.role_type = role_type
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
