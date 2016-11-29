//
//  YSCustomPayViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/13.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol YSCustomPayViewDelegate: NSObjectProtocol {
    
    func gotoAliPay()
    func gotoWXPay()
}

class YSCustomPayViewController: UIViewController {
    
    var delegate: YSCustomPayViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPayView() {
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.view.alpha = 1
        })
    }
    
    private func hideView() {
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.view.alpha = 0
        })
    }
    
    @IBAction func gotoWXPay(sender: AnyObject) {
        
        if (self.delegate != nil) && (self.delegate.respondsToSelector("gotoWXPay")) {
            self.delegate.gotoWXPay()
        }
        hideView()
    }
    
    @IBAction func gotoAliPay(sender: AnyObject) {
        
        if (self.delegate != nil) && (self.delegate.respondsToSelector("gotoAliPay")) {
            self.delegate.gotoAliPay()
        }
        hideView()
    }

    @IBAction func cancel(sender: AnyObject) {
        
         hideView()
    }
}
