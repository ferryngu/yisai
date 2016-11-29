//
//  PSPopView.swift
//  YISAI
//
//  Created by 周超创 on 16/9/9.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class PSPopView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    private let SCREENWIDTHRATIO: CGFloat = SCREEN_WIDTH / 320.0
    
    var bgView: UIView!
    var contentView: UIView!
    var style: Int = 0
    
    func initView(frame: CGRect) {
        
        //frame.height = SCREEN_HEIGHT+65
        self.frame = frame
    }
    
    func contentViewHeight() -> CGFloat {
        
        let buttonWidth: CGFloat = (SCREEN_WIDTH - 8*2) / 4
        return 64.0 + buttonWidth * 2 + 30.0
    }
    
    private func setup() {
        
        self.bgView = UIView(frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+65))
        bgView.backgroundColor = UIColor.blackColor()
        bgView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: "hide")
        bgView.addGestureRecognizer(tapGesture)
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: "hide")
        upSwipeGesture.direction = UISwipeGestureRecognizerDirection.Up
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: "hide")
        downSwipeGesture.direction = UISwipeGestureRecognizerDirection.Down
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: "hide")
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirection.Left
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: "hide")
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirection.Right
        //        upSwipeGesture.direction = UISwipeGestureRecognizerDirection.Up | UISwipeGestureRecognizerDirection.Down | UISwipeGestureRecognizerDirection.Left | UISwipeGestureRecognizerDirection.Right
        
        struct direction{
            let up = UISwipeGestureRecognizerDirection.Up
            let down = UISwipeGestureRecognizerDirection.Down
            let left = UISwipeGestureRecognizerDirection.Left
            let right = UISwipeGestureRecognizerDirection.Right
        }
        
        bgView.addGestureRecognizer(upSwipeGesture)
        bgView.addGestureRecognizer(downSwipeGesture)
        bgView.addGestureRecognizer(leftSwipeGesture)
        bgView.addGestureRecognizer(rightSwipeGesture)
        self.addSubview(bgView)
        
        setupContentView()
    }
    
    private func setupContentView() {
        
        contentView = UIView(frame: CGRect(x: 15, y: SCREEN_HEIGHT, width: SCREEN_WIDTH-30, height: contentViewHeight()))
        contentView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.addSubview(contentView)
        
 
    }
    
   
    func show() {
        
        setup()
        UIView.animateWithDuration(0.25, animations: {[weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.bgView.alpha = 0.4
            self!.contentView.frame = CGRect(x: 0, y: self!.frame.size.height-self!.contentViewHeight(), width: self!.frame.size.width, height: self!.contentViewHeight())
            })
    }
    
    func hide() {
        
      //  NSNotificationCenter.defaultCenter().postNotificationName(MZPopViewHideNotification, object: nil)
        UIView.animateWithDuration(0.25, animations: {[weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.bgView.alpha = 0.0
            self!.contentView.frame = CGRect(x: 0, y: self!.frame.size.height, width: self!.frame.size.width, height: self!.contentViewHeight())
            
        }) {[weak self] (completed: Bool) -> Void in
            
            if self == nil {
                return
            }
            
            self!.contentView.removeFromSuperview()
            self!.bgView.removeFromSuperview()
            self!.removeFromSuperview()
        }
    }
    

}
