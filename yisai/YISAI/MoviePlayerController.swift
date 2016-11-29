//
//  MoviePlayerController.swift
//  TestAVPlayer
//
//  Created by Yufate on 15/5/21.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

enum MoviePlayerStyle {
    case None
    case Normal
}

class MoviePlayerController: UIViewController {

    var contentURL: NSURL!
    
    var moviePlayer: MPMoviePlayerController!
    
    private var durationTimer: NSTimer!
    private var defaultFrame: CGRect = CGRectZero
    private var topFrame: CGRect = CGRectZero
    private var bottomFrame: CGRect = CGRectZero
    private var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var topBgView: UIView!
    @IBOutlet weak var bottomBgView: UIView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var sld_duration: UISlider!
    @IBOutlet weak var lab_total: UILabel!
    @IBOutlet weak var lab_elapsed: UILabel!
    @IBOutlet weak var btn_play: UIButton!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_share: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var pgv_cache: UIProgressView!
    
    var style: MoviePlayerStyle = .Normal
    var isFullscreen: Bool = false
    var isPrepare: Bool = false
    var shouldShowBackAndShareBtn: Bool = false
    var canFullscreen: Bool = true
    
    
    var clickBackHandler: dispatch_block_t!
    var clickShareHandler: dispatch_block_t!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.style == .None {
            self.topBgView.hidden = true
            self.bottomBgView.hidden = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if moviePlayer != nil {
//            moviePlayer.scalingMode = MPMovieScalingMode.Fill
//        }
        
        if let t_btn_back = btn_back, let t_btn_share = btn_share {
            
            t_btn_back.hidden = false
            t_btn_share.hidden = false
        }
        
//        if moviePlayer == nil {
//            setupPlayingVideo()
//        }
        
//        moviePlayer.scalingMode = MPMovieScalingMode.AspectFit
        
        if sld_duration != nil && pgv_cache != nil && sld_duration.subviews.count > 1 {
            sld_duration.insertSubview(pgv_cache, atIndex: 1)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func setPlayerStyle(style: MoviePlayerStyle) {
        self.style = style
    }
    
    func setupPlayingVideo() {
        
        if moviePlayer != nil {
            self.stopPlayingVideo()
        }
        
        moviePlayer = MPMoviePlayerController(contentURL: self.contentURL)
        moviePlayer.controlStyle = .None
        
        if moviePlayer != nil {
            addNotification()
            setupDuration()
            moviePlayer.movieSourceType = MPMovieSourceType.File
            moviePlayer.scalingMode = MPMovieScalingMode.Fill
            moviePlayer.view.clipsToBounds = true
            moviePlayer.view.frame = self.view.bounds
            moviePlayer.shouldAutoplay = true
            moviePlayer.setFullscreen(isFullscreen, animated: true)
            
            
            view.insertSubview(moviePlayer.view, aboveSubview: self.preview)
            
            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityView.center = moviePlayer.view.center
            moviePlayer.view.addSubview(activityView)
            activityView.startAnimating()
            
            sld_duration.minimumTrackTintColor = UIColor.redColor()
            sld_duration.setThumbImage(UIImage(named: "xqy_shipingbofangdian"), forState: .Normal)
            sld_duration.maximumTrackTintColor = UIColor.grayColor()
            
//            moviePlayer.prepareToPlay()
            moviePlayer.play()
        }
    }
    
    func stopPlayingVideo() {
        
        if moviePlayer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            stopDurationTimer()
            moviePlayer.stop()
            moviePlayer.view.removeFromSuperview()
        }
    }
    
    private func addNotification() {
        // 做好播放准备后
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaPlaybackIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: self.moviePlayer)
        // 播放状态改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: self.moviePlayer)
        // 网络加载状态改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerLoadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: self.moviePlayer)
        // 播放完成通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
        // 缩略图请求完成之后
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerThumbnailImageRequestDidFinish:", name: MPMoviePlayerThumbnailImageRequestDidFinishNotification, object: self.moviePlayer)
        // 确定了媒体播放时长后
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "movieDurationAvailable:", name: MPMovieDurationAvailableNotification, object: nil)
        // 将要进入全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillEnterFullscreen:", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        // 将要退出全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillExitFullscreen:", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        // 退出全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidExitFullscreen:", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerScalingModeDidChange:", name: MPMoviePlayerScalingModeDidChangeNotification, object: nil)
    }
    
    private func setupDuration() {
        let delayInSeconds: Double = 0.2
        let poptime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(poptime, dispatch_get_main_queue(), { [weak self] () -> Void in
            /* resume values */
            self!.monitorMoviePlayback()
            self!.startDurationTimer()
        })
    }
    
    private func startDurationTimer() {
        durationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "monitorMoviePlayback", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(durationTimer, forMode: NSDefaultRunLoopMode)
    }
    
    func stopDurationTimer() {
        if durationTimer != nil {
            durationTimer.invalidate()
        }
    }
    
    private func setDurationSliderMaxMinValues() {
        let duration = moviePlayer.duration
        sld_duration.minimumValue = 0.0
        sld_duration.maximumValue = Float(duration)
    }
    
    private func setTimeLabelValues(currentTime: Double, totalTime: Double) {
        let minutesElapsed = floor(currentTime / 60.0)
        let secondsElapsed = fmod(currentTime, 60.0)
        lab_elapsed.text = NSString(format: "%.0f:%02.0f", minutesElapsed, secondsElapsed) as String
    }
    
    func monitorMoviePlayback() {
        var currentTime = ceil(moviePlayer.currentPlaybackTime)
        let totalTime = ceil(moviePlayer.duration)
        if currentTime.isNaN {
            currentTime = 0
        }
        setTimeLabelValues(currentTime, totalTime: totalTime)
        sld_duration.value = Float(ceil(currentTime))
        if pgv_cache != nil {
            let progress = Float(self.moviePlayer.playableDuration / self.moviePlayer.duration)
            pgv_cache.progress = progress > 0 ? progress : 0.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func tapCoverView(sender: AnyObject) {
        
        self.topBgView.userInteractionEnabled = false
        self.bottomBgView.userInteractionEnabled = false
        
        if !self.topBgView.hidden && !self.bottomBgView.hidden {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.topBgView.alpha = 0
                self.bottomBgView.alpha = 0
                
            }, completion: { finished in
                
                self.topBgView.hidden = true
                self.bottomBgView.hidden = true
                
                self.topBgView.userInteractionEnabled = true
                self.bottomBgView.userInteractionEnabled = true
            })
            
        } else {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                self.topBgView.alpha = 1
                self.bottomBgView.alpha = 1
                
            }, completion: { finished in
                
                self.topBgView.hidden = false
                self.bottomBgView.hidden = false
                
                self.topBgView.userInteractionEnabled = true
                self.bottomBgView.userInteractionEnabled = true
            })
        }
    }
    
    @IBAction func clickBack(sender: AnyObject) {
        
        if let block = self.clickBackHandler {
            block()
        }
    }
    
    @IBAction func clickShare(sender: AnyObject) {
        
        if let block = self.clickShareHandler {
            block()
        }
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        stopPlayingVideo()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func play(sender: AnyObject) {
        
        if moviePlayer == nil {
            return
        }
        
        if self.moviePlayer.playbackState == .Playing {
            self.moviePlayer.pause()
        } else if self.moviePlayer.playbackState == .Paused {
            self.moviePlayer.play()
        }
    }
    
    @IBAction func fullScreen(sender: AnyObject) {

        if moviePlayer == nil {
            return
        }
        if canFullscreen == false
        {
            return
        }
        isFullscreen = !isFullscreen
        
        self.moviePlayer.setFullscreen(isFullscreen, animated: true)
        self.moviePlayer.fullscreen = isFullscreen
    }
    
    @IBAction func durationSliderValueChanged(sender: AnyObject) {
        
        if moviePlayer == nil {
            return
        }
        
        let slider = sender as! UISlider
        let currentTime = ceil(slider.value)
        let totalTime = ceil(moviePlayer.duration)
        setTimeLabelValues(Double(currentTime), totalTime: totalTime)
    }
    
    @IBAction func durationSliderTouchBegan(sender: AnyObject) {
        
        if moviePlayer == nil {
            return
        }
        
        moviePlayer.pause()
    }
    
    @IBAction func durationSliderTouchEnded(sender: AnyObject) {
        
        if moviePlayer == nil {
            return
        }
        
        let slider = sender as! UISlider
        moviePlayer.currentPlaybackTime = Double(ceil(slider.value))
        moviePlayer.play()
    }
    
    // MARK: - Notification
    
    /** 做好播放准备后 */
    func mediaPlaybackIsPreparedToPlayDidChange(notification: NSNotification) {
        print("mediaPlaybackIsPreparedToPlayDidChange", terminator: "")
        
        isPrepare = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(YSMoviePlaybackSuccess, object: nil)
        
        activityView.stopAnimating()
    }
    
    /** 播放状态改变 */
    func moviePlayerPlaybackStateDidChange(notification: NSNotification) {

        switch moviePlayer.playbackState {
        case .Playing:
            print("moviePlayerPlaybackStateDidChange to Playing", terminator: "")
            self.btn_play.setImage(UIImage(named: "suspended_detail"), forState: .Normal)
            startDurationTimer()
        case .SeekingBackward:
            break
        case .SeekingForward:
//            state = .Ready
            break
        case .Interrupted:
            print("moviePlayerPlaybackStateDidChange to Interrupted", terminator: "")
//            state = .Loading
            break
        case .Paused:
            print("moviePlayerPlaybackStateDidChange to Paused", terminator: "")
            self.btn_play.setImage(UIImage(named: "play_detail"), forState: .Normal)
        case .Stopped:
            self.activityView.stopAnimating()
            print("moviePlayerPlaybackStateDidChange to Stopped", terminator: "")
            self.btn_play.setImage(UIImage(named: "play_detail"), forState: .Normal)
//            state = .Idle
            stopDurationTimer()
        }
    }
    
    /** 网络加载状态改变 */
    func moviePlayerLoadStateDidChange(notification: NSNotification) {
        
        switch moviePlayer.loadState {
        case MPMovieLoadState.Stalled, MPMovieLoadState.Unknown:
            print("moviePlayerLoadStateDidChange to Stalled", terminator: "")
            self.activityView.startAnimating()
        case MPMovieLoadState.PlaythroughOK:
            fallthrough
        case MPMovieLoadState.Playable:
            self.moviePlayer.play()
            print("moviePlayerLoadStateDidChange to Playable", terminator: "")
            self.activityView.stopAnimating()
        default:
//            self.activityView.startAnimating()
            break
        }
    }
    
    /** 播放完成通知 */
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        print("moviePlayerPlaybackDidFinish", terminator: "")
        
        // TODO: - 播放下一个视频
//        self.moviePlayer.contentURL = NSURL(string: "http://7xog4v.media1.z0.glb.clouddn.com/89hwjRk8kFtAfw6MJYBJ8YJD-gk=/lttAuTXz21qUtW-a4A8rdCmP4G7Q")
//        self.moviePlayer.play()
        // --------
        
        if !isPrepare {
            
            NSNotificationCenter.defaultCenter().postNotificationName(YSMoviePlaybackFailed, object: nil)
        }
//        let duration = moviePlayer.duration
//        sld_duration.value = Float(duration)
    }
    
    /** 缩略图请求完成之后 */
    func moviePlayerThumbnailImageRequestDidFinish(notification: NSNotification) {
        print("moviePlayerThumbnailImageRequestDidFinish", terminator: "")
    }
    
    /** 确定了媒体播放时长后 */
    func movieDurationAvailable(notification: NSNotification) {
        print("movieDurationAvailable", terminator: "")
        let mp = notification.object as! MPMoviePlayerController
        let duration = mp.duration
        let minutesTotal = floor(duration / 60.0)
        let secondsTotal = ceil(fmod(duration, 60.0))
        lab_total.text = NSString(format: "%.0f:%02.0f", minutesTotal, secondsTotal) as String
        setDurationSliderMaxMinValues()
    }
    
    /** 将要进入全屏 */
    var parentView: UIView?
    var tView: UIView?
    func moviePlayerWillEnterFullscreen(notification: NSNotification) {
        print("moviePlayerWillEnterFullscreen", terminator: "")
        
        if let t_btn_back = btn_back, let t_btn_share = btn_share {
            
            t_btn_back.hidden = true
            t_btn_share.hidden = true
        }

        defaultFrame = self.view.frame
        
        parentView = self.view.superview
        tView = self.view
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).isFullScreen = true
        let number:NSNumber = NSNumber(integer: UIInterfaceOrientation.LandscapeRight.rawValue)
        UIDevice.currentDevice().setValue(number, forKey: "orientation")
        
        var keyWindow = UIApplication.sharedApplication().keyWindow
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().windows[0] as UIWindow
        }
        tView!.frame = keyWindow!.bounds
        self.preview.hidden = true
        self.moviePlayer.view.hidden = true
        self.view.backgroundColor = UIColor.clearColor()
        keyWindow?.addSubview(tView!)
    }
    
    func moviePlayerDidExitFullscreen(notification: NSNotification) {
        
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
    }
    
    /** 将要退出全屏 */
    func moviePlayerWillExitFullscreen(notification: NSNotification) {
        
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        print("moviePlayerWillExitFullscreen", terminator: "")
        
        if let t_btn_back = btn_back, let t_btn_share = btn_share {
            
            t_btn_back.hidden = false
            t_btn_share.hidden = false
        }
        
        let number:NSNumber = NSNumber(integer: UIInterfaceOrientation.Portrait.rawValue)
        UIDevice.currentDevice().setValue(number, forKey: "orientation")
        (UIApplication.sharedApplication().delegate as! AppDelegate).isFullScreen = false
        
        self.preview.hidden = false
        self.moviePlayer.view.hidden = false
        self.view.frame = CGRect(x: 0, y: 20, width: defaultFrame.size.width, height: defaultFrame.size.height)
    }
    
    func moviePlayerScalingModeDidChange(notification: NSNotification) {
        print("moviePlayerScalingModeDidChange", terminator: "")
//        moviePlayer.scalingMode = MPMovieScalingMode.Fill
    }
}
