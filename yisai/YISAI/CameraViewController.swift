//
//  CameraViewController.swift
//  Crummy
//
//  Created by dasmer on 8/9/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

/** Focus on view hiding time delay */
let focusViewHideDelay = 0.5

enum SnapCameraTapStatus {
    case Default // Default Status
    case Selected // Selected Status
}

enum YSCameraMovieStyle {
    case Dynamic
    case Discovery
    case Competition
}

//func HideCoverViewDelay(target: CameraViewController) {
//    let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(focusViewHideDelay * Double(NSEC_PER_SEC)))
//    dispatch_after(popTime, dispatch_get_main_queue(), { [weak target] () -> Void in
//        UIView.animateWithDuration(1.0, animations: { () -> Void in
//            target!.coverView.alpha = 0.0
//        })
//    })
//}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, UIPopoverControllerDelegate {
    
    private enum CamSetupResult: NSInteger {
        case Success
        case CameraNotAuthorized
        case SessionConfigurationFailed
    }
    
    private enum CamStyle: NSInteger {
        case Default
        case Piano
    }
    
    /* Session management. */
    var captureSession: AVCaptureSession//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
    var videoDeviceInput: AVCaptureDeviceInput?//AVCaptureDeviceInput对象是输入流
    var audioDeviceInput: AVCaptureDeviceInput?
//    var imageOutput: AVCaptureStillImageOutput
    var movieOutput: AVCaptureVideoDataOutput
//    var movieOutput: AVCaptureMovieFileOutput
    
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var adaptor: AVAssetWriterInputPixelBufferAdaptor!
    var audioWriterInput: AVAssetWriterInput!
    var audioOutput: AVCaptureAudioDataOutput!
    
    /* 录制有关参数 */
    /** 拍摄按钮状态 */
    var snapCameraTapStatus: SnapCameraTapStatus
    /** 录制计时器 */
    var recordTimer: NSTimer!
    /** 录制时间 */
    var recordCount: Double
    /** 禁止屏幕旋转 */
    var lockInterfaceRotation: Bool
    /** 后台标识 */
    var backgroundRecordingID: UIBackgroundTaskIdentifier
    /** 状态栏隐藏状态 */
    var statusBarHidden: Bool
    /** 焦距缩放大小 */
    var frameScale: CGFloat
    /** 录制状态 */
    var isRecording: Bool
    private var setupResult: CamSetupResult = .Success
    private var camStyle: CamStyle = .Default
    
    /* For use in the storyboards. */
    /** 闪光灯 */
//    @IBOutlet weak var btn_flash: UIButton!
    /** 录制时间 */
    @IBOutlet weak var lab_recordTime: UILabel!
    /** 切换前置或后置摄像头 */
    @IBOutlet weak var btn_changeCamera: UIButton!
    /** 辅助格设置 */
//    @IBOutlet weak var btn_assistView: UIButton!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var cameraToggleButton: UIButton!
    @IBOutlet weak var cateLabsView: UIView!
    @IBOutlet weak var img_guideView: UIImageView!
    @IBOutlet weak var btn_defaultStyle: UIButton!
    @IBOutlet weak var btn_pianoStyle: UIButton!
    @IBOutlet weak var img_piano: UIImageView!
    
    var queue: dispatch_queue_t!
    
//    private var coverView: UIView!
    var tips: FETips! = FETips()
    var movName: String!
    var cameraMovieStyle: YSCameraMovieStyle
    /** 赛事ID */
    var cpid: String!
    var crid: String!
    var matchName: String!
    var currentCate: Int = 0
    let lst_cateLabs = ["默认", "唱歌", "小提琴", "钢琴", "舞蹈"]
    /** Max Record Time */
    private var MAX_RECORD_TIME = 60 * 30
    
    required init(coder aDecoder: NSCoder) {
        self.captureSession = AVCaptureSession()
        recordCount = Double(MAX_RECORD_TIME)
        snapCameraTapStatus = .Default
        lockInterfaceRotation = false
        backgroundRecordingID = UIBackgroundTaskInvalid
        cameraMovieStyle = .Discovery
        statusBarHidden = true
        frameScale = 1.0
        isRecording = false
        
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        if (videoCaptureDevice != nil) {
            do {
                self.videoDeviceInput = try AVCaptureDeviceInput.init(device: videoCaptureDevice)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                videoDeviceInput = nil
            }
        }
        
        if (audioCaptureDevice != nil) {
            do {
                self.audioDeviceInput = try AVCaptureDeviceInput.init(device: audioCaptureDevice)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                audioDeviceInput = nil
            }
        }
        
        audioOutput = AVCaptureAudioDataOutput()
        movieOutput = AVCaptureVideoDataOutput()
        super.init(coder: aDecoder)!
        
        self.hidesBottomBarWhenPushed = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.configureCateViewLbls()
        
        // 应用授权
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            break
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                
                if !granted {
                    self.setupResult = CamSetupResult.CameraNotAuthorized
                }
            })
        default:
            setupResult = CamSetupResult.CameraNotAuthorized
        }
        
        if setupResult != .Success {
            return
        }
        // =================
        
        self.configureCaptureSession()
        self.configurePreviewView()
        self.configureVideoAudioWriter()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: YSApplicationDidEnterBackground, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: YSApplicationDidBecomeActiveNotification, object: nil)
        
        rotateView()
        
        self.captureSession.commitConfiguration()
        
        
       // self.navigationController?.toolbarHidden = true;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if cameraMovieStyle == .Dynamic {
            MAX_RECORD_TIME = 7
        }
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput!.device)
        /* start session from device input to preview output */
        self.captureSession.startRunning()
      
        self.configureCameraToggleButtonState(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* default focus point is previewView center */
//        self.focousCursorWithPoint(previewView.center)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        if isRecording {
            finishRecording()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput!.device)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        
        if isRecording {
            self.finishRecording()
        }
        self.configureCameraToggleButtonState(false)
        record()
        closeView()
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
    
    }
    
    // MARK: - Interface Orientation
    
    func rotateView() {
        
//        let orientation = UIApplication.sharedApplication().statusBarOrientation
//        let frame = UIScreen.mainScreen().applicationFrame
//        let center = CGPointMake(frame.origin.x + ceil(frame.size.width/2), frame.origin.y + ceil(frame.size.height/2))
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
            self.previewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 1.5)
        })
    }
    
//    override func shouldAutorotate() -> Bool {
        /* Disable autorotation of the interface when recording is in progress. */
//        return false
//        return !self.lockInterfaceRotation
//    }
    
//    override func supportedInterfaceOrientations() -> Int {
//        return interfaceOrientationMask
//    }

//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = AVCaptureVideoOrientation(rawValue: toInterfaceOrientation.rawValue)!
//    }
    
    // MARK: - Configure session, focus view, preview, toggle button state
    /*
    func configureCateViewLbls() {
        
        let btnWidth = 46
        let btnHeight = 16
        let originX = Int(SCREEN_HEIGHT / 2) - btnWidth / 2
        let originY = 0
        
        for (index, cateLab) in enumerate(lst_cateLabs) {
            
            let label = UILabel(frame: CGRect(x: originX + btnWidth * index, y: originY, width: btnWidth, height: btnHeight))
            label.text = cateLab
            label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(15)
            label.tag = 21 + index
            
            cateLabsView!.addSubview(label)
        }
    }
*/
    
    func configureVideoAudioWriter() {
        
        let size = CGSize(width: 1280, height: 720)
        // 创建文件
//        var date: NSDate = NSDate()
//        var formatter: NSDateFormatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
//        var dateString = formatter.stringFromDate(date)
        let dateString = "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
        
        let movDir = NSHomeDirectory() + "/Documents/Movie"
        
        if cameraMovieStyle == .Dynamic {
            movName = ysApplication.loginUser.uid + dateString + ".mp4"
        } else {
            movName = dateString + ".mp4"
        }
        let betaCompressionDirectory = movDir + "/" + movName
//        var error: NSError?
        let outputURL = NSURL(fileURLWithPath: betaCompressionDirectory)
        print("outputURL" + "\(outputURL)")
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(movDir) {
            try! fileManager.createDirectoryAtPath(movDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        if (fileManager.fileExistsAtPath(betaCompressionDirectory)) {
            try! fileManager.removeItemAtPath(betaCompressionDirectory)
        }
        
        /* initialize compression engine */
//        self.videoWriter = AVAssetWriter(URL: NSURL(fileURLWithPath: betaCompressionDirectory), fileType: AVFileTypeMPEG4, error: &error)
        do {
            self.videoWriter = try AVAssetWriter(URL: NSURL(fileURLWithPath: betaCompressionDirectory), fileType: AVFileTypeMPEG4)
        }catch let error as NSError {
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            abort()
        }

        
        assert(videoWriter != nil, "video writer is nil")//断言
//        if error != nil {
//            print(error?.localizedDescription)
//        }
        
        let videoCompressionProps = [ AVVideoAverageBitRateKey : (1024.0 * 1600.0) ]
        let videoSettings: [String : AnyObject] = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : size.width,
            AVVideoHeightKey : size.height,
            AVVideoCompressionPropertiesKey : videoCompressionProps ]
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        assert(videoWriterInput != nil, "video writer input initialize failed")
        
        videoWriterInput.expectsMediaDataInRealTime = true
        let sourcePixelBufferAttributesDictionary: [String : AnyObject] = [ kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_32ARGB) ]
        adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        assert(videoWriter.canAddInput(videoWriterInput), "video writer can't add video writer input")
        
        // add the audio input
        var acl: AudioChannelLayout? = nil
        bzero(&acl, sizeofValue(acl))
        acl?.mChannelLayoutTag = kAudioChannelLayoutTag_Mono
        let audioOutputSettings : [String : AnyObject] = [
            AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVEncoderBitRateKey : 128000,
            AVSampleRateKey : 44100.0,
            AVNumberOfChannelsKey : 1,
            AVChannelLayoutKey : NSData(bytes: &acl, length: sizeofValue(acl))
        ]
        audioWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        audioWriterInput.expectsMediaDataInRealTime = true
        
        if videoWriter.canAddInput(audioWriterInput) {
            videoWriter.addInput(audioWriterInput)
        }
        
        if videoWriter.canAddInput(videoWriterInput) {
            videoWriter.addInput(videoWriterInput)
        }
    }

    func configureCaptureSession() {
        
        if (captureSession.canAddInput(videoDeviceInput)) {
            captureSession.addInput(videoDeviceInput)
        }
        
        if (captureSession.canAddOutput(movieOutput)) {
            captureSession.addOutput(movieOutput)
            queue = dispatch_queue_create("movieoutputqueue", nil)
            movieOutput.alwaysDiscardsLateVideoFrames = true
            movieOutput.setSampleBufferDelegate(self, queue: queue)
//            movieOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32ARGB ]
//            let connection = movieOutput.connectionWithMediaType(AVMediaTypeVideo)
//            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Cinematic
        }
        if (captureSession.canAddOutput(audioOutput)) {
            captureSession.addOutput(audioOutput)
            audioOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        }
//        if (captureSession.canAddOutput(imageOutput)) {
//            captureSession.addOutput(imageOutput)
//        }
        /* achieve high quality video and audio output. default is high resolution */
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        /* 
        /* optional: set the designed resolution */
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        */
    }
    
//    func configureFocusView() {
//        coverView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        coverView.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4).CGColor
//        self.previewView.addSubview(coverView)
//    }
    
    func configurePreviewView() {
        
        self.lab_recordTime.text = "\(MAX_RECORD_TIME / 60):00"
        
        //self.previewView.session = self.captureSession
        //self.previewView.clipsToBounds = true
       // (self.previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
       // self.previewView.frame = CGRectMake(0, 0, 600, 600)
      //  self.view.layer.addSublayer(self.previewView)
       // self.previewView.backgroundColor = UIColor.blackColor()
        self.previewView.commonInit(self.captureSession)
       // self.previewView.frame = CGRectMake(0, 0, 600, 600)
        previewView.backgroundColor = UIColor.blackColor()
        
        
       // self.view.addSubview(previewView)
    }
    
    func configureCameraToggleButtonState(recording:Bool) {
        if (recording) {
            self.cameraToggleButton.setBackgroundImage(UIImage(named: "record_selected"), forState: .Normal)
        }
        else {
            self.cameraToggleButton.setBackgroundImage(UIImage(named: "record_normal"), forState: .Normal)
        }
    }
    
    var soundID: SystemSoundID = 0
      var audioPlayer = AVAudioPlayer()
    
    func configureStartRecordingSound(beginOrEnd: Bool) {
        
        var filePath: NSURL?
        if beginOrEnd {
            filePath = NSURL.fileURLWithPath("/System/Library/Audio/UISounds/begin_record.caf")
        } else {
            filePath = NSURL.fileURLWithPath("/System/Library/Audio/UISounds/end_record.caf")
        }
        
        if filePath == nil {
            return
        }
        
        print(filePath)
        
       
        
        AudioServicesCreateSystemSoundID(filePath! as CFURLRef, &soundID)
        
        print(soundID)
        
        AudioServicesPlaySystemSound(soundID)
        
        
      
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: filePath!)
        } catch {
            print("No sound found by URL:\(filePath)")
        }
        audioPlayer.play()
        
        
        
        
    }
    
    // MARK: - UI Button Actions
    
    @IBAction func changeCamStyle(sender: UIButton) {
        
        if sender.tag == 21 {
            if camStyle == .Default {
                return
            } else {
                img_piano.hidden = true
                camStyle = .Default
                btn_defaultStyle.setBackgroundImage(UIImage(named: "ts_hong"), forState: .Normal)
                btn_pianoStyle.setBackgroundImage(UIImage(named: "ts_hui"), forState: .Normal)
            }
        } else {
            if camStyle == .Piano {
                return
            } else {
                img_piano.hidden = false
                camStyle = .Piano
                btn_defaultStyle.setBackgroundImage(UIImage(named: "ts_hui"), forState: .Normal)
                btn_pianoStyle.setBackgroundImage(UIImage(named: "ts_hong"), forState: .Normal)
            }
        }
    }
    
    @IBAction func tapGuideView(sender: UITapGestureRecognizer) {
        
        img_guideView.hidden = true
    }
    
    @IBAction func camViewSwipeRight(sender: AnyObject) {
        /*
        if isRecording || currentCate == 0 {
            return
        }
        
        currentCate--
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            for index in 21...(21 + self.lst_cateLabs.count) {
                
                let label = self.cateLabsView.viewWithTag(index)
                
                if label == nil {
                    continue
                }
                
                label!.frame.origin = CGPoint(x: label!.frame.origin.x + 46, y: label!.frame.origin.y)
            }
        })
*/
    }
    
    @IBAction func camViewSwipeLeft(sender: AnyObject) {
        /*
        if isRecording || currentCate == lst_cateLabs.count - 1 {
            return
        }
        
        currentCate++
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            for index in 21...(21 + self.lst_cateLabs.count) {
                
                let label = self.cateLabsView.viewWithTag(index)
                
                if label == nil {
                    continue
                }
                
                label!.frame.origin = CGPoint(x: label!.frame.origin.x - 46, y: label!.frame.origin.y)
            }
        })
*/
    }
    
    @IBAction func closeView(sender: AnyObject) {
        
        closeView()
    }
    
    /* 开启曝光灯 */
    @IBAction func openTorch(sender: AnyObject) {
        let device = self.videoDeviceInput?.device
        if device != nil {
            CameraViewController.setTorchMode(device!.torchMode == .Off ? .On : .Off, forDevice: device!)
//            btn_flash.setTitle(device!.torchMode == .Off ? "关闭曝光灯" : "打开曝光灯", forState: .Normal)
        }
    }
    
    /* 切换摄像头 */
    @IBAction func changeCamera(sender: AnyObject) {
        self.cameraToggleButton.userInteractionEnabled = false
//        self.btn_assistView.enabled = false
        self.btn_changeCamera.enabled = false
//        self.btn_flash.enabled = false
        
        let device = self.videoDeviceInput?.device
        var preferredPosition = AVCaptureDevicePosition.Unspecified
        let currentPositionPosition = device!.position
        var btn_changeCameraTitle: String = self.btn_changeCamera.titleLabel!.text!
        
        switch currentPositionPosition {
        case .Unspecified:
            btn_changeCameraTitle = "切换前置摄像头"
//            btn_flash.hidden = false
            preferredPosition = .Back
        case .Back:
            btn_changeCameraTitle = "切换后置摄像头"
//            btn_flash.hidden = true
            preferredPosition = .Front
        case .Front:
//            btn_flash.hidden = false
            btn_changeCameraTitle = "切换前置摄像头"
            preferredPosition = .Back
        }
        
        let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)!
        let videoDeviceInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        
        captureSession.beginConfiguration()
        captureSession.removeInput(self.videoDeviceInput)
        if captureSession.canAddInput(videoDeviceInput) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: device)
            CameraViewController.setFlashMode(AVCaptureFlashMode.Auto, forDevice: videoDevice)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)
            captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        } else {
            captureSession.addInput(self.videoDeviceInput)
        }
        btn_changeCamera.setTitle(btn_changeCameraTitle, forState: .Normal)
        
        captureSession.commitConfiguration()
        
        self.cameraToggleButton.userInteractionEnabled = true
//        self.btn_assistView.enabled = true
        self.btn_changeCamera.enabled = true
//        self.btn_flash.enabled = true
    }

    /** 拍视频 */
    @IBAction func userDidTapCameraToggle(sender: AnyObject) {
        
        !isRecording ? configureStartRecordingSound(true) : configureStartRecordingSound(false)
        
        delayCall(0.3) { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            if (self!.captureSession.canAddInput(self!.audioDeviceInput)) {
                
                !self!.isRecording ? self!.captureSession.addInput(self!.audioDeviceInput) : self!.captureSession.removeInput(self!.audioDeviceInput)
            }
            
            self!.record()
        }
    }
    
    /** 对焦 */
    @IBAction func focusAndExposeTap(sender: AnyObject) {
        let tapGesture = sender as! UITapGestureRecognizer
        if (self.captureSession.running) {
            
            let tapPoint = tapGesture.locationInView(tapGesture.view)
            self.focousCursorWithPoint(tapPoint)
            
            let focusPoint = CGPointMake(tapPoint.x/CGRectGetWidth(self.previewView.frame), tapPoint.y/CGRectGetHeight(self.previewView.frame))
            self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposeWithMode: AVCaptureExposureMode.AutoExpose, atDevicePoint: focusPoint, monitorSubjectAreaChange: true)
        }
    }
    
    /* 调整焦距 */
    @IBAction func pinchScale(sender: AnyObject) {
        
        let recognizer = sender as! UIPinchGestureRecognizer
        if self.frameScale * recognizer.scale < 1.0 {
            return
        }
        
        let device = self.videoDeviceInput!.device
        if recognizer.scale > device.activeFormat.videoMaxZoomFactor {
            return
        }
        
        self.frameScale = self.frameScale * recognizer.scale
        do {
            //没有返回值了这个方法
            try device.lockForConfiguration()
        }catch let error as NSError {
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            return
        }
        recognizer.scale = 1
    }
    
    
    // MARK: - Configure Camera Methods
    
    /** 设置焦点 */
    private func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposeMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        
        let device = videoDeviceInput?.device
//        var error: NSError?
        do {
            //没有返回值了这个方法
            try device!.lockForConfiguration()
            if device!.focusPointOfInterestSupported && device!.isFocusModeSupported(focusMode) {
                device!.focusMode = focusMode
                device!.focusPointOfInterest = point
            }
            if device!.exposurePointOfInterestSupported && device!.isExposureModeSupported(exposeMode) {
                device!.exposureMode = exposeMode
                device!.exposurePointOfInterest = point
            }
            device!.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device!.unlockForConfiguration()
        }catch let error as NSError{
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            return
        }
    }
    
    /** 设置电筒 */
    class func setTorchMode(torchMode: AVCaptureTorchMode, forDevice device: AVCaptureDevice) {
        if device.hasTorch && device.isTorchModeSupported(torchMode) {
            do {
                //没有返回值了这个方法
                try device.lockForConfiguration()
                device.torchMode = torchMode
                device.unlockForConfiguration()
            }catch let error as NSError{
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }
        }
    }
    
    /** 设置闪光灯 */
    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            do {
                //没有返回值了这个方法
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
            }catch let error as NSError{
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return
            }
        }
    }
    
    /** 取摄像头 */
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first as! AVCaptureDevice
        
        for device in devices {
            if (device as! AVCaptureDevice).position == position {
                captureDevice = device as! AVCaptureDevice
                break
            }
        }
        
        return captureDevice
    }
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focusWithMode(AVCaptureFocusMode.ContinuousAutoFocus, exposeWithMode: AVCaptureExposureMode.ContinuousAutoExposure, atDevicePoint:devicePoint, monitorSubjectAreaChange: false)
    }
    
    func focousCursorWithPoint(point: CGPoint) {
//        self.coverView.center = point
//        self.coverView.transform = CGAffineTransformMakeScale(1.5, 1.5)
//        self.coverView.alpha = 1.0
//        UIView.animateWithDuration(1.0, animations: { [weak self] () -> Void in
//            self!.coverView.transform = CGAffineTransformIdentity
//            }) { [weak self] (finished: Bool) -> Void in
//            self!.coverView.alpha = 0
//        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        if !CMSampleBufferDataIsReady(sampleBuffer) {
            return
        }
        
        if !isRecording {
            return
        }
        
        if captureOutput == movieOutput {
            let lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            
            if videoWriter.status != AVAssetWriterStatus.Writing {
                videoWriter.startWriting()
                videoWriter.startSessionAtSourceTime(lastSampleTime)
            }
        
            if videoWriter.status.rawValue > AVAssetWriterStatus.Writing.rawValue {
                print("Warning: writer status is \(videoWriter.status)")
                if videoWriter.status == AVAssetWriterStatus.Failed {
                    print("Error: \(videoWriter.error)")
                    
                    //视频生成失败，未知错误
                    tips.duration = 1
                    tips.showTipsInMainThread(Text: "未知错误，视频生成失败")
                    
                    delayCall(1.0, block: { () -> Void in
                        self.closeView()
                    })
                }
                return
            }
            
            if videoWriterInput.readyForMoreMediaData {
                if !videoWriterInput.appendSampleBuffer(sampleBuffer) {
                    print("Unable to write to video input.")
                } else {
//                    println("Already write video")
                }
            }
        } else if captureOutput == audioOutput {
            
            if videoWriter.status != AVAssetWriterStatus.Writing {
                return
            }
//            if videoWriter.status.rawValue > AVAssetWriterStatus.Writing.rawValue {
//                println("Warning: writer status is \(videoWriter.status)")
//                if videoWriter.status == AVAssetWriterStatus.Failed {
//                    println("Error: \(videoWriter.error)")
//                }
//                return
//            }
            
            if audioWriterInput.readyForMoreMediaData {
                if !audioWriterInput.appendSampleBuffer(sampleBuffer) {
                    print("Unable to write to audio input")
                } else {
//                    println("already write audio")
                }
            }
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
//    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
//        recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "calculateRecordTime:", userInfo: nil, repeats: true)
//        self.configureCameraToggleButtonState(true)
//    }
//    
//    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
//        println("save movie")
//        // reset record time label, stop the record timer
//        self.recordCount = 0.0
//        self.lab_recordTime.text = "0:00"
//        recordTimer.invalidate()
//        // set record button default status
//        self.configureCameraToggleButtonState(false)
//        
//        lockInterfaceRotation = false
//
//        var backgroundID = backgroundRecordingID
//        self.backgroundRecordingID = UIBackgroundTaskInvalid
//        var videoPath: String! = nil
//        
//        // 保存视频
//        MovieAchieveManager.videoCompressQualityWithInputUrl(outputFileURL, backgroundID: backgroundID) { [weak self] (session: AVAssetExportSession, outputPath: String!, backgroundID: UIBackgroundTaskIdentifier, finished: Bool) -> Void in
//            
//            videoPath = outputPath
//            
//            if finished {
//                
//                if self!.tips != nil {
//                    self!.tips.tipsViewlabel.text = "压缩完成"
//                    self!.tips.disappearTipsInMainThread()
//                }
//                
//                if backgroundID != UIBackgroundTaskInvalid {
//                    UIApplication.sharedApplication().endBackgroundTask(backgroundID)
//                }
//                
//                if videoPath != nil {
//                    var localMovies = NSUserDefaults.standardUserDefaults().objectForKey("localMovies") as? [Array<String>]
//                    if localMovies == nil {
//                        // 1、文件名；2、进度
//                        localMovies = [Array<String>]()
//                        NSUserDefaults.standardUserDefaults().setObject(localMovies, forKey: "localMovies")
//                    }
//                    
//                    localMovies!.append([videoPath, "0"])
//                    NSUserDefaults.standardUserDefaults().setObject(localMovies, forKey: "localMovies")
//                }
//                
//                if self == nil {
//                    return
//                }
//                
//                self!.dismissViewControllerAnimated(true, completion: nil)
//            }
//        }
//        
//        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//            [weak self] (action: UIAlertAction!) -> Void in
//            
//            self!.tips = FETips()
//            self!.tips.showTipsInMainThread(self!, Text: "正在压缩视频，请稍后...")
//            self!.tips.duration = 300
//            
//            if self!.captureSession.running {
//                self!.captureSession.stopRunning()
//            }
//            
//            self?.cameraToggleButton.userInteractionEnabled = false
//        }
//        let alertController: UIAlertController = UIAlertController(title: "提示", message: "上传视频", preferredStyle: .Alert)
//        alertController.addAction(action)
//        self.presentViewController(alertController, animated: true, completion: nil)
//        
//        
//        // 保存到系统相册
//        /*
//        let library = ALAssetsLibrary()
//        if (library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL)) {
//            library.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: { (assetURL: NSURL!, error: NSError!) -> Void in
//                if error != nil {
//                    println(error)
//                }
//                
//                NSFileManager.defaultManager().removeItemAtURL(assetURL, error: nil)
//                
//                if backgroundID != UIBackgroundTaskInvalid {
//                    UIApplication.sharedApplication().endBackgroundTask(backgroundID)
//                }
//            })
//        }
//        */
//    }
    
    // MARK: - UIAlert Controller Delegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.tips = FETips()
        self.tips.showTipsInMainThread(Text: "正在压缩视频，请稍后...")
        self.tips.duration = 300
        
        if self.captureSession.running {
            self.captureSession.stopRunning()
        }
        
        self.cameraToggleButton.userInteractionEnabled = false
    }
    
    // MARK: -  Other Logical Func
    
    func calculateRecordTime(sender: AnyObject) {
        
        self.recordCount -= 0.5
        let time = Int(ceil(self.recordCount))
        let min = time / 60
        let minText = "\(min)"
        let sec: Int = time % 60
        var secText: String = "\(sec)"
        if sec < 10 {
            secText = "0\(sec)"
        }
        self.lab_recordTime.text = minText + ":" + secText
        
        /* reach max record time */
        if time <= 0 {
            self.userDidTapCameraToggle(self.cameraToggleButton)
        }
    }
    
    func deleteMovFile() {
        
    }
    
    private func saveToPhotos(urlString: String) {
        
        // 保存到系统相册
        let library = ALAssetsLibrary()
        let outputFileURL = NSURL(string: urlString)
        
        if (library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL)) {
            library.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: { [weak self] (assetURL, error) in
                
                if error != nil {
                    
                    self!.tips.duration = 1
                    self!.tips.showTipsInMainThread(Text: "视频保存失败")
                    return
                }
            })
        }
    }
    
    func record() {
        
        if (isRecording) {
            
            finishRecording()
            
//            configureStartRecordingSound(false)
            
            let movDir = NSHomeDirectory() + "/Documents/Movie"
            let betaCompressionDirectory = movDir + "/" + movName
            
           // let m_betaCompressionDirectory = movDir + "/m_" + movName
            
            
            saveToPhotos(betaCompressionDirectory)
            
            
            GetFileSize(betaCompressionDirectory)
            
           // self.yasuoMovie()
            
            if cameraMovieStyle == .Dynamic {
                
                objc_setAssociatedObject(ysApplication.tabbarController, &AssociatedPostFamilyDynamic.GetVideoName, movName, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
               /// self.dismissViewControllerAnimated(false, completion: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            } else {
                
                let controller = UIStoryboard(name: "YSPlayer", bundle: nil).instantiateInitialViewController() as! MoviePlayerContainerViewController
                if cameraMovieStyle == .Discovery {
                    controller.type = .Discovery
                } else {
                    controller.cpid = cpid
                     controller.crid = crid
                    controller.type = .Competition
                    controller.matchName = matchName
                }
                controller.movieName =  movName
                controller.contentURLStr = betaCompressionDirectory
                
                
                
              //  controller.movieName =  "1470896566362.mp4"
               // controller.contentURLStr = movDir + "/" + "1470896566362.mp4"
                
                
               // self.dismissViewControllerAnimated(false, completion: nil)
                
               // ysApplication.tabbarController.presentViewController(controller, animated: true, completion: nil)
                
                let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
                
                nav.popToRootViewControllerAnimated(true)
                
                delayCall(0.5, block: { () -> Void in
                    
                    // ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
                    // self.navigationController?.popViewControllerAnimated(true)
                    
                  //  let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
                    
                    controller.hidesBottomBarWhenPushed = true
                    nav.navigationBarHidden = true
                    nav.pushViewController(controller, animated: false)
                    
                    
                })
                
            }
            //            let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            //                [weak self] (action: UIAlertAction!) -> Void in
            //
            //                if self!.captureSession.running {
            //                    self!.captureSession.stopRunning()
            //                }
            //                self?.cameraToggleButton.userInteractionEnabled = false
            //                YSMovie.setMovie(self!.movName, progress: 0.0, uploadStatus: 0)
            //                self!.dismissViewControllerAnimated(true, completion: nil)
            //            }
            //            let alertController: UIAlertController = UIAlertController(title: "提示", message: "上传视频", preferredStyle: .Alert)
            //            alertController.addAction(action)
            //            self.presentViewController(alertController, animated: true, completion: nil)
            
            //            movieOutput.stopRecording()
        } else {
        
            // Update the orientation on the movie file output video connection before starting recording.

            movieOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = AVCaptureVideoOrientation(rawValue: 3)!
            isRecording = !isRecording
            configureCameraToggleButtonState(isRecording)
            recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "calculateRecordTime:", userInfo: nil, repeats: true)
            lockInterfaceRotation = true
            /* 后台录制视频 */
            if UIDevice.currentDevice().multitaskingSupported {
                backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ })
            }
        }
    }
    
    func finishRecording() {
        
        let backgroundID = backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskInvalid
        
        if backgroundID != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(backgroundID)
        }
        
        isRecording = false
        
        if audioWriterInput.readyForMoreMediaData {
            audioWriterInput.markAsFinished()
        }
        
        if videoWriterInput.readyForMoreMediaData {
            videoWriterInput.markAsFinished()
            videoWriter.finishWritingWithCompletionHandler( { () -> Void in
                self.videoWriter = nil
            } )
        }
        print(videoWriter.status.rawValue)
        
        self.recordCount = Double(MAX_RECORD_TIME)
        self.lab_recordTime.text = "\(Int(MAX_RECORD_TIME/60)):00"
        recordTimer.invalidate()
        // set record button default status
        self.configureCameraToggleButtonState(false)
        
        lockInterfaceRotation = false
        
        if self.captureSession.running {
            self.captureSession.stopRunning()
        }
    }
    
    func closeView() {
        
        if !isRecording {
            // 取消录制，删除文件
            let movDir = NSHomeDirectory() + "/Documents/Movie"
            let betaCompressionDirectory = movDir + "/" + movName
//            var error: NSError?
            let outputURL = NSURL(fileURLWithPath: betaCompressionDirectory)
            print("deleteURL" + "\(outputURL)")
            let fileManager = NSFileManager.defaultManager()
            if (fileManager.fileExistsAtPath(betaCompressionDirectory)) {
                try! fileManager.removeItemAtPath(betaCompressionDirectory)
            }
        } else {
            // 正在录制，保存文件
            finishRecording()
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func yasuoMovie()
    {
        
        let movDir = NSHomeDirectory() + "/Documents/Movie"
        let betaCompressionDirectory = movDir + "/" + movName
        //            var error: NSError?
        let videoPath = NSURL(fileURLWithPath: betaCompressionDirectory)
        
        
       // let stringVideoPath = videoPath.path
        
        //add watermark starting here
        
        let videoAsset = AVURLAsset(URL: videoPath)
        let mixComposition = AVMutableComposition()
        
        let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: clipVideoTrack, atTime: kCMTimeZero)
        } catch {
            print("error")
        }
        
        compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform
        
        let audioTrack = mixComposition.addMutableTrackWithMediaType(
            AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try audioTrack.insertTimeRange(
                CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0] ,
                atTime: kCMTimeZero)
        } catch _ {
        }

        
        let videoSize = clipVideoTrack.naturalSize
        
        print(videoSize)
        
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        
        
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        parentLayer.addSublayer(videoLayer)
        //parentLayer.addSublayer(aLayer)
        
        //create composition and add instructions to insert the layer
        
        let videoComp = AVMutableVideoComposition()
        videoComp.renderSize = CGSize(width: videoSize.width, height: videoSize.height)
        videoComp.frameDuration = CMTimeMake(1, 30)
        videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
        //instructions
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
        let videoTrack = mixComposition.tracksWithMediaType(AVMediaTypeVideo)[0]
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        layerInstruction.setTransform(compositionVideoTrack.preferredTransform, atTime: kCMTimeZero)
        
        
        mainInstruction.layerInstructions = [layerInstruction]
        videoComp.instructions = [mainInstruction]
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        assetExport?.videoComposition = videoComp
        
        let exportPath = movDir + "/m_" + movName
        
        
        let exportURL = NSURL(fileURLWithPath: exportPath)
        
        if NSFileManager.defaultManager().fileExistsAtPath(exportPath) {
            do { try NSFileManager.defaultManager().removeItemAtPath(exportPath)} catch{}
        }
        
        assetExport?.outputFileType = AVFileTypeMPEG4
        assetExport?.outputURL = exportURL
        assetExport?.shouldOptimizeForNetworkUse = true
        assetExport?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            print("done")
            self.GetFileSize(exportPath)
            UISaveVideoAtPathToSavedPhotosAlbum(exportURL.path!, self, nil, nil)
        })
    }
    
    func GetFileSize(fileString: String)
    {
        let manager = NSFileManager.defaultManager()
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(fileString)) {
            let attributes = try? manager.attributesOfItemAtPath(fileString) //结果为AnyObject类型
             print("attributes: \(attributes!)")
        }
       
    }
}
