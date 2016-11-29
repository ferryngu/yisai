//
//  MoviePlayer.swift
//  TestAVPlayer
//
//  Created by Yufate on 15/5/20.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

let fullscreenAnimationDuration: NSTimeInterval = 3.0

@objc protocol MoviePlayerDelegate: NSObjectProtocol {
    func moviePlayerWillMoveFromWindow()
    
    optional func movieTimeOut()
}

class MoviePlayer: MPMoviePlayerController {
    
    private var movieBackgroundView: UIView!
    private var movieFullScreen: Bool
    var delegate: MoviePlayerDelegate!
    
    init() {
        movieFullScreen = false
        movieBackgroundView = UIView()
        movieBackgroundView.alpha = 0.0
        movieBackgroundView.backgroundColor = UIColor.blackColor()
        
        super.init(contentURL: nil)
        
        controlStyle = .None
        view.backgroundColor = UIColor.blackColor()
    }
    
    deinit {
        delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func isFullScreen() -> Bool {
        return movieFullScreen
    }
    
    override func setFullscreen(fullscreen: Bool, animated: Bool) {
        
        movieFullScreen = fullscreen
        if fullscreen {
            NSNotificationCenter.defaultCenter().postNotificationName(MPMoviePlayerWillEnterFullscreenNotification, object: nil)
            var keyWindow = UIApplication.sharedApplication().keyWindow
            if keyWindow == nil {
                keyWindow = UIApplication.sharedApplication().windows[0] 
            }
            
            if CGRectEqualToRect(self.movieBackgroundView.frame, CGRectZero) {
                movieBackgroundView.frame = keyWindow!.bounds
            }
            keyWindow?.addSubview(movieBackgroundView)
            
            UIView.animateWithDuration(animated ? fullscreenAnimationDuration : 0.0, animations: { [weak self] () -> Void in
                
                self!.movieBackgroundView.alpha = 1.0
            }, completion: { [weak self] (completed: Bool) -> Void in
                
                self!.view.alpha = 0.0
                self!.movieBackgroundView.addSubview(self!.view)
                
            })
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(MPMoviePlayerWillExitFullscreenNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
            UIView.animateWithDuration(animated ? fullscreenAnimationDuration : 0.0, animations: { [weak self] () -> Void in
                self!.view.alpha = 0.0
            }, completion: { [weak self] (completed: Bool) -> Void in
                if self!.delegate.respondsToSelector("moviePlayerWillMoveFromWindow") {
                    self!.delegate.moviePlayerWillMoveFromWindow()
                }
                self!.view.alpha = 1.0
                UIView.animateWithDuration(animated ? fullscreenAnimationDuration : 0.0, animations: { [weak self] () -> Void in
                    self!.movieBackgroundView.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    self!.movieBackgroundView.removeFromSuperview()
                    NSNotificationCenter.defaultCenter().postNotificationName(MPMoviePlayerDidExitFullscreenNotification, object: nil)
                })
            })
        }
    }
}
