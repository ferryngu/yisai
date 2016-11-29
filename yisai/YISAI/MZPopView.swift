//
//  PopView.swift
//  TestCustomShare
//
//  Created by thy on 15/4/7.
//  Copyright (c) 2015年 thy. All rights reserved.
//

import UIKit

let MZPopViewHideNotification = "MZPopViewHideNotification"

class MZPopView: UIView {
    
    private let SCREENWIDTHRATIO: CGFloat = SCREEN_WIDTH / 320.0

    var bgView: UIView!
    var contentView: UIView!
    var style: Int = 0
    
    func initView(frame: CGRect) {
        self.frame = frame
    }
    
    func contentViewHeight() -> CGFloat {
        
        let buttonWidth: CGFloat = (SCREEN_WIDTH - 8*2) / 4
        return 64.0 + buttonWidth * 2 + 30.0
    }
    
    private func setup() {
        
        self.bgView = UIView(frame: self.bounds)
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
        setupButtons()
    }
    
    private func setupContentView() {
        
        contentView = UIView(frame: CGRect(x: 0.0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: contentViewHeight()))
        contentView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.addSubview(contentView)
        
        let topLabel = UILabel(frame: CGRect(x: SCREEN_WIDTH/2-42.0/2, y: 8.0, width: 42.0, height: 21.0))
        topLabel.text = "分享"
        topLabel.textAlignment = NSTextAlignment.Center
        topLabel.font = UIFont.boldSystemFontOfSize(15.0 * SCREENWIDTHRATIO)
        topLabel.textColor = UIColor(red: 244.0/255.0, green: 72.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        contentView.addSubview(topLabel)
        
        let bottomLine = UIView(frame: CGRect(x: 0.0, y: contentView.frame.size.height-35.0, width: SCREEN_WIDTH, height: 1.0))
        bottomLine.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        contentView.addSubview(bottomLine)
        
//        let cancelButton = UIButton.buttonWithType(.System) as! UIButton
        
        let cancelButton = UIButton(type: UIButtonType.System)
        cancelButton.frame = (frame: CGRect(x: 0, y: contentView.frame.size.height-18.0-8.0, width: SCREEN_WIDTH, height: 18.0))
        cancelButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0 * SCREENWIDTHRATIO)
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.tintColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
        cancelButton.addTarget(self, action: "hide", forControlEvents: .TouchUpInside)
        contentView.addSubview(cancelButton)
    }
    
    private func setupButtons() {
        
        let num = (style == 0 ? 5 : 6)
        let buttonWidth: CGFloat = (SCREEN_WIDTH - 8*2) / 4
        let imageWidth: CGFloat = buttonWidth - 20.0 * 2
        let imageNameArray = ["weixin", "pengyouquan", "QQkongjian", "weibo", "fasonghaoyou", "xqy_duanxing"]
        let titleArray = ["微信", "朋友圈", "QQ空间", "新浪微博", "QQ", "短信"]
        for (var i = 0; i <= (num - 1) / 4; i++) {
            
            var innerLoopCount = 4
            if (i == num / 4) {
                innerLoopCount = num % 4
            }
            
            for (var j = 0; j < innerLoopCount; j++) {
                
                let xorigin = 8.0 + buttonWidth * CGFloat(j)
                let yorigin = 44.0 + buttonWidth * CGFloat(i)
                let button = UIButton(frame: CGRectMake(xorigin, yorigin, buttonWidth, buttonWidth))
                button.tag = 1000 + 4*i + j
                button.backgroundColor = UIColor.clearColor()
                button.clipsToBounds = true
                self.contentView.addSubview(button)
            }
        }
        
        for (var i = 0; i < num; i += 1) {
            
            let button = self.contentView.viewWithTag(1000+i)
            let imageView = UIImageView(frame: CGRect(x: buttonWidth/2.0-imageWidth/2.0, y: buttonWidth/2.0-imageWidth/2.0-8.0, width: imageWidth, height: imageWidth))
            imageView.image = UIImage(named: imageNameArray[i])
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.clipsToBounds = true
            button?.addSubview(imageView)
            
            let label = UILabel(frame: CGRect(x: buttonWidth/2.0-buttonWidth/2.0, y: imageView.frame.origin.y+imageWidth+8.0, width: buttonWidth, height: 15.0 * SCREENWIDTHRATIO))
            label.text = titleArray[i]
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor(red: 122.0/255.0, green: 122.0/255.0, blue: 122.0/255.0, alpha: 1.0)
            label.font = UIFont.boldSystemFontOfSize(11.0 * SCREENWIDTHRATIO)
            button?.addSubview(label)
        }
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(MZPopViewHideNotification, object: nil)
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
