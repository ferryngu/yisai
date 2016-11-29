//
//  FETips.swift
//  ch74
//
//  Created by apps on 14/12/3.
//  Copyright (c) 2014年 apps. All rights reserved.
//

import UIKit

//let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
//let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

public class FETips: NSObject {
   
    var tipsView:UIView = UIView()
    var activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    var tipsViewlabel = UILabel()

    var visualEffectView:UIVisualEffectView!
    
    var caneBeCancle:Bool = true

    var visualEffect:Bool = false

    var duration:UInt64 = 15
    
    public override init() {
    
        super.init()
        tipsView.layer.cornerRadius = 6
        tipsViewlabel.textColor = UIColor.whiteColor()
        tipsViewlabel.backgroundColor = UIColor.clearColor()
        tipsViewlabel.font = UIFont.boldSystemFontOfSize(17)
        tipsViewlabel.minimumScaleFactor = 0.3
        
        tipsView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        activityIndicatorView.hidesWhenStopped = true;
        activityIndicatorView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
        
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//        activityIndicatorView.color = UIColor.blackColor()

    }
    
    private func showTips(Text text:String) {

        let rootView = UIApplication.sharedApplication().keyWindow
        
        tipsViewlabel.text = text;
        tipsViewlabel.textColor = UIColor.whiteColor()
        tipsViewlabel.textAlignment = NSTextAlignment.Center
        tipsViewlabel.numberOfLines = 0
        tipsViewlabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        tipsViewlabel.frame.size = CGSize(width: 160, height: 120)

        tipsView.frame.size = CGSizeMake( tipsViewlabel.frame.size.width*1.2, tipsViewlabel.frame.size.height*1.2)
        
        if tipsView.frame.size.width < 160 {
            tipsView.frame.size.width = 160
        }
        
        if tipsView.frame.size.height < 120 {
            tipsView.frame.size.height = 120
        }

        /*这样实现出问题的机率很很多*/
        tipsView.center = CGPointMake(rootView!.frame.size.width/2 , rootView!.frame.size.height/2)
        
        tipsViewlabel.center = CGPointMake(tipsView.frame.size.width/2, tipsView.frame.size.height/2)

        /* 按这个顺序写也可以实现居中，不过super View frame 发生改变就可能会出问题
        tipsView.layer.cornerRadius = 6
        label.center = tipsView.center
        tipsView.center = viewController.view.center
        */
        tipsView.addSubview(tipsViewlabel)


        if caneBeCancle {

            let tipsViewGesture = UITapGestureRecognizer(target: self, action: "tipsViewTapHandle:")
            tipsViewGesture.numberOfTapsRequired = 1
            tipsView.addGestureRecognizer(tipsViewGesture)

        }

        if visualEffect {
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
            visualEffectView.frame = rootView!.bounds
            rootView!.addSubview(visualEffectView)
        }

        rootView!.addSubview(self.tipsView)

        self.tipsView.alpha = 0.01

        UIView.animateWithDuration( 0.8,

            animations: {
                self.tipsView.alpha = 1
            },
            completion: {finished in
                
            }
        )

    }

    public func showTipsInMainThread(Text text:String) {

        if ( NSThread.isMainThread() )
        {

            self.showTips(Text:text)

        } else {

            dispatch_async ( dispatch_get_main_queue(), {

                self.showTips(Text:text)

            })

        }

        if 0 == duration {
            duration = 15
        }
        
        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(duration * NSEC_PER_SEC))

        /*
        这里保持了 FETips 的实例，所以在调用的方法里面生成 FETips 在方法退出的时候不会马上释放FETips实例，
        从而可以使得 UITapGestureRecognizer 事件响应依然有效
        没有下面的dispatch_after，响应一定会崩溃
        */

        dispatch_after(time, dispatch_get_main_queue(), {

            self.disappearTipsInMainThread()

        })
        
    }

    public func tipsViewTapHandle(sender: UITapGestureRecognizer) {
        
        disappearTipsInMainThread()
        
    }
    
    public func disappearTipsInMainThread() {

        let disappear:()->Void = {

            if nil == self.tipsView.superview {
                return
            }
            
            UIView.animateWithDuration( 0.8,
                
                animations: {
                    self.tipsView.alpha = 0.01
                },
                
                completion: {finished in
                    
                    self.tipsView.removeFromSuperview()
                    
                    if self.visualEffect {
                        self.visualEffectView.removeFromSuperview()
                    }
                    
                }
            )
            
        }

        dispatch_async ( dispatch_get_main_queue(), {
            disappear()
        })
        
    }
    
    public func showActivityIndicatorViewInMainThread(text: String!){
        
        let rootView = UIApplication.sharedApplication().keyWindow
        
        let show:()->Void = {
            
            self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.activityIndicatorView.bounds = rootView!.bounds
            self.activityIndicatorView.center = CGPointMake(rootView!.frame.size.width/2 , rootView!.frame.size.height/2)
            
            rootView!.addSubview(self.activityIndicatorView)
            
            self.activityIndicatorView.startAnimating()
            
            if text == nil {
                self.tipsViewlabel.text = "正在发送中..."
            } else {
                self.tipsViewlabel.text = text
            }
            
            self.tipsViewlabel.textColor = UIColor.darkTextColor()
            self.tipsViewlabel.textAlignment = NSTextAlignment.Center
            self.tipsViewlabel.numberOfLines = 0
            self.tipsViewlabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            
            self.tipsViewlabel.center = CGPointMake(SCREEN_WIDTH / 2, self.activityIndicatorView.frame.size.height / 2 + 30)
            self.tipsViewlabel.bounds.size = CGSize(width: SCREEN_WIDTH, height: 30)
            
            self.activityIndicatorView.addSubview(self.tipsViewlabel)
            
            
            
            if self.caneBeCancle {
                
                let activityIndicatorViewGesture = UITapGestureRecognizer(target: self, action: "activityIndicatorViewTapHandle:")
                activityIndicatorViewGesture.numberOfTapsRequired = 1
                self.activityIndicatorView.addGestureRecognizer(activityIndicatorViewGesture)
                
            }
        }
        
        if ( NSThread.isMainThread() ) {
            
            show()
            
        } else {
            
            dispatch_async ( dispatch_get_main_queue(), {
                
                show()
                
            })
            
        }
        
        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(duration * NSEC_PER_SEC))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            self.disappearActivityIndicatorViewInMainThread()
            
        })
        
    }
    
    public func showActivityIndicatorViewInMainThread(viewController: UIViewController!, text: String!){

        if viewController == nil {
            return
        }
        
        let view = viewController.view

        let show:()->Void = {
        
            self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.activityIndicatorView.bounds = view!.bounds
            self.activityIndicatorView.center = CGPointMake(view!.frame.size.width/2 , view!.frame.size.height/2)
            
            view!.addSubview(self.activityIndicatorView)
        
            self.activityIndicatorView.startAnimating()
            
            if text == nil {
                self.tipsViewlabel.text = "正在努力加载..."
            } else {
                self.tipsViewlabel.text = text
            }
            
            self.tipsViewlabel.textColor = UIColor.darkTextColor()
            self.tipsViewlabel.textAlignment = NSTextAlignment.Center
            self.tipsViewlabel.numberOfLines = 0
            self.tipsViewlabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            
            self.tipsViewlabel.center = CGPointMake(SCREEN_WIDTH / 2, self.activityIndicatorView.frame.size.height / 2 + 30)
            self.tipsViewlabel.bounds.size = CGSize(width: SCREEN_WIDTH, height: 30)
            
            self.activityIndicatorView.addSubview(self.tipsViewlabel)
            
            
            
            if self.caneBeCancle {

                let activityIndicatorViewGesture = UITapGestureRecognizer(target: self, action: "activityIndicatorViewTapHandle:")
                activityIndicatorViewGesture.numberOfTapsRequired = 1
                self.activityIndicatorView.addGestureRecognizer(activityIndicatorViewGesture)

            }
        }
        
        if ( NSThread.isMainThread() ) {

            show()

        } else {
        
            dispatch_async ( dispatch_get_main_queue(), {

                show()

            })
            
        }
        
        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(duration * NSEC_PER_SEC))

        dispatch_after(time, dispatch_get_main_queue(), {
            
            self.disappearActivityIndicatorViewInMainThread()
            
        })
   
    }
    
    public func disappearActivityIndicatorViewInMainThread() {
        
        let disappear:()->Void = {
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()

        }

        if ( NSThread.isMainThread() ) {
            disappear()

        } else {

            dispatch_async ( dispatch_get_main_queue(), {
                disappear()
            })
        
        }
        
    }
    
    public func activityIndicatorViewTapHandle(sender: UITapGestureRecognizer) {

//        disappearActivityIndicatorViewInMainThread()

    }

}

