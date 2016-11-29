//
//  YSCameraViewController.swift
//  YISAI
//
//  Created by jason on 16/10/17.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CoreMotion

enum CameraContainerType {
    case Discovery
    case Competition
}


class YSCameraViewController: UIViewController,ALiVideoRecordDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
    var cameraToggleButton: UIButton!
    var cameraView:UIView!
    var recorder:ALiVideoRecorder!
    var time_label:UILabel!
    var motionManager:CMMotionManager!
    var orientationLast:UIInterfaceOrientation!
    var lock_view:UIView!
    
    var moviePath: String!
    var movieFileName: String!
    var selectWcid: String! // 选中的作品分类ID
    var selectCatName: String! // 选中的作品分类名称
    var tips: FETips = FETips()
    var type: CameraContainerType! // 发布类型
    var crid: String! // 作品ID
    
    var cpid: String! // 赛事ID
    var localFindwork: YSFindwork! // 本地保存好的作品
    var findworkTutor: YSFindworkTutor! // 作品指导老师
    var isConfirm: Bool = false
    var local_view: UIView!
    var competition_type: String!
    
    var wid: String!
    var matchName: String!
    
    var back_btn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        cameraView = UIView()
        cameraView.frame = CGRectMake(0, 0, SCREEN_HEIGHT - 100,SCREEN_WIDTH )
        
        self.view.addSubview(cameraView)
        
        recorder = ALiVideoRecorder()
        
        recorder.maxVideoDuration = 1800;
        recorder.delegate = self;
        recorder.previewLayer().connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        recorder.previewLayer().frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 100)
        self.view.layer.insertSublayer(recorder.previewLayer(), atIndex:0);
        
        
        let bottm_view = UIView(frame:CGRectMake(0, 0, SCREEN_WIDTH, 100))
        bottm_view.backgroundColor = UIColor.grayColor()
         self.view.addSubview(bottm_view)
        
        bottm_view.top = SCREEN_HEIGHT - 100
        
        
        cameraToggleButton = UIButton(frame: CGRectMake(0, 0, 80, 80))
        cameraToggleButton.left = (SCREEN_WIDTH-80)/2
        cameraToggleButton.top = 10
        configureCameraToggleButtonState(false)
        cameraToggleButton.addTarget(self,action:#selector(SelectButton),forControlEvents:.TouchUpInside)
        bottm_view.addSubview(cameraToggleButton)
        
       cameraToggleButton.selected  = false

        local_view  = UIView(frame: CGRectMake(0, 0, 80, 50))
        local_view.left = 10
        local_view.top = 25
        
        
         bottm_view.addSubview(local_view)
        
        
        let loal = UIButton(frame: CGRectMake(19, 0, 38, 30))
        loal.setBackgroundImage(UIImage(named: "local_load"), forState: .Normal)
        loal.addTarget(self,action:#selector(Local),forControlEvents:.TouchUpInside)
    
        local_view.addSubview(loal)
        
        let local_title = UILabel(frame: CGRectMake(0, 35, 80, 20))
        local_title.textAlignment = .Center
        local_title.textColor = UIColor.init(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
        local_title.font = UIFont.systemFontOfSize(15)
        local_title.text  = "本地导入"
        local_view.addSubview(local_title)
        
        local_view.hidden = true
        
        
        back_btn = UIButton(frame: CGRectMake(SCREEN_WIDTH-45, 25, 30, 30))
        back_btn .setBackgroundImage(UIImage(named: "cs_fanhui"), forState: .Normal)
         back_btn.addTarget(self,action:#selector(Back),forControlEvents:.TouchUpInside)
        back_btn.tintColor = UIColor.whiteColor()
        self.view.addSubview(back_btn)
       // back_btn.hidden = true
        
         time_label = UILabel(frame: CGRectMake(SCREEN_WIDTH-75, (SCREEN_HEIGHT-100)/2, 100, 30))
        time_label.textAlignment = .Center
        time_label.textColor = UIColor.whiteColor()
        time_label.text  = "00:30"
        self.view.addSubview(time_label)
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.back_btn.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
            self.time_label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
            self.local_view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
            // self.previewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 1.5)
            
            
        })
        
        
        self.Add_lockView()
        
       // self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        

        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.recorder.openPreview()
        self.screenOrientedObserve()
        
   
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        if(self.recorder != nil)
        {
            self.recorder.closePreview()
        }
        if(self.motionManager != nil)
        {
            self.motionManager.stopAccelerometerUpdates()
            self.motionManager = nil
        }
        if(lock_view != nil)
        {
            lock_view.removeFromSuperview()
            lock_view = nil
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

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
        
       // print(filePath)
        
        
        
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
    func recordProgress(progress:CGFloat)
    {
       // self.recordCount -= 0.5
        let t_float:Float = Float(progress)
         let b_float:Float = Float(recorder.maxVideoDuration)
        let time = recorder.maxVideoDuration - Int(ceil(t_float * b_float))
        
        let min = time / 60
        let minText = "\(min)"
        let sec: Int = time % 60
        var secText: String = "\(sec)"
        if sec < 10 {
            secText = "0\(sec)"
        }
        time_label.text = minText + ":" + secText
        
    }
    
    func SelectButton(sender: UIButton) {
        
        
     
        cameraToggleButton.selected = !cameraToggleButton.selected
        
        configureStartRecordingSound( cameraToggleButton.selected)
        configureCameraToggleButtonState(cameraToggleButton.selected)
        
        
        if(cameraToggleButton.selected)
        {
            if (self.recorder.isCapturing) {
                self.recorder.resumeRecording()
            }else {
                self.recorder.startRecording()
                
                
            }

        }
        else
        {
           /* self.recorder.stopRecordingCompletion:( (UIImage *movieImage) -> in  {
             
                
                NSLog(@"%@",self.recorder.videoPath);
                CGFloat duration = [self.recorder getVideoLength:[NSURL URLWithString:self.recorder.videoPath]];
                CGFloat videoSize = [self.recorder getFileSize:self.recorder.videoPath];
                NSLog(@"%f-----%f",duration,videoSize);
            }*/
            
           // recorder.stopRecordingCompletion(:{(movieImage:) -> Void in
            
            //})
            
                
              //  })
            
            
            recorder.stopRecordingCompletion({ (movieImage:UIImage!) in
                
                print(self.recorder.videoPath)
                
                 print(self.recorder.filename)
                
                
                 let publishViewController =  YSPulishInformationViewController()
                
                if self.type == .Discovery {
                    publishViewController.type = .Discovery
                } else {
                    publishViewController.cpid = self.cpid
                    publishViewController.type = .Competition
                    publishViewController.crid = self.crid
                    if self.matchName != nil {
                        publishViewController.matchName = self.matchName
                    }
                }
                
                publishViewController.contentURLStr = self.recorder.videoPath
                publishViewController.movieName = self.recorder.filename
                
                self.navigationController?.navigationBarHidden = false
                self.navigationController?.pushViewController(publishViewController, animated: true)
                
                
             })
        }
        
    }

    func rotateView() {
        
        //        let orientation = UIApplication.sharedApplication().statusBarOrientation
        //        let frame = UIScreen.mainScreen().applicationFrame
        //        let center = CGPointMake(frame.origin.x + ceil(frame.size.width/2), frame.origin.y + ceil(frame.size.height/2))
        
        //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
           // self.previewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 1.5)
        })
    }

    
    func Back()
    {
      

        self.navigationController?.navigationBarHidden = false
        
        let childViewControllers = navigationController!.childViewControllers
        
        
        for viewController in childViewControllers {
            
            if viewController is YSCompetitionDetailViewController {
                
                
                self.navigationController?.popToViewController(viewController, animated: true)
                
                return
            }
            
            
        }
        
  
        self.navigationController?.popViewControllerAnimated(true)

    }

    func Add_lockView()
    {
        lock_view = UIView(frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        lock_view.backgroundColor = UIColor.blackColor()
        lock_view.alpha = 0.7
        self.view.addSubview(lock_view)
        
        let imageView = UIImageView(frame:CGRectMake(0, 0, 180, 180))
        imageView.image = UIImage(named: "record_rotation")
        imageView.center = lock_view.center
        lock_view.addSubview(imageView)
        
        let title_str = UILabel(frame: CGRectMake(0, imageView.top, SCREEN_WIDTH, 30))
        title_str.textAlignment = .Center
        title_str.textColor = UIColor.whiteColor()
        title_str.text  = "亲,把相机横过来拍摄哦!"
        lock_view.addSubview(title_str)
        
        title_str.bottom = imageView.top - 10
        
        let view1  = UIView(frame: CGRectMake(0, 0, 80, 50))
        view1.left = 15
        view1.top = lock_view.bottom - 75
        
        
        lock_view.addSubview(view1)
        
        
        let loal = UIButton(frame: CGRectMake(19, 0, 38, 30))
        loal.setBackgroundImage(UIImage(named: "local_load"), forState: .Normal)
        loal.addTarget(self,action:#selector(Local),forControlEvents:.TouchUpInside)
        
        view1.addSubview(loal)
        
        let local_title = UILabel(frame: CGRectMake(0, 35, 80, 20))
        local_title.textAlignment = .Center
        local_title.textColor = UIColor.whiteColor()
        local_title.font = UIFont.systemFontOfSize(15)
        local_title.text  = "本地导入"
        view1.addSubview(local_title)
        
       // let back = UIButton(frame: CGRectMake(15, 25, 30, 30))
       // back .setBackgroundImage(UIImage(named: "cs_fanhui"), forState: .Normal)
       // back.addTarget(self,action:#selector(Back),forControlEvents:.TouchUpInside)
       // back.tintColor = UIColor.whiteColor()
       // lock_view.addSubview(back)
       
        
    }
    func Remove_lockView()
    {
        if(lock_view != nil)
        {
        lock_view.removeFromSuperview()
        lock_view = nil
        }
    }
    
    func screenOrientedObserve()
    {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval =  1.0/15.0
        
        if(motionManager.accelerometerAvailable)
        {
            let queue = NSOperationQueue.currentQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue!, withHandler:
                { (accelerometerData : CMAccelerometerData?, error: NSError?) -> Void in
                    
                    //
                    
                    let acceleration = accelerometerData!.acceleration;
                    let orientationNew:UIInterfaceOrientation;
                    if (acceleration.x >= 0.75) {
                        orientationNew = UIInterfaceOrientation.LandscapeLeft;
                    }
                    else if (acceleration.x <= -0.75) {
                        orientationNew = UIInterfaceOrientation.LandscapeRight;
                    }
                    else if (acceleration.y <= -0.75) {
                        orientationNew = UIInterfaceOrientation.Portrait;
                    }
                    else if (acceleration.y >= 0.75) {
                        orientationNew = UIInterfaceOrientation.PortraitUpsideDown;
                    }
                    else {
                        // Consider same as last time
                        return;
                    }
  
                    if (orientationNew == self.orientationLast)
                    {
                        return;
                    }
                    
                    self.orientationLast = orientationNew;
                    
                    if(orientationNew != UIInterfaceOrientation.LandscapeRight)
                    {
                        print("不是横屏")
                        
                        if(self.lock_view == nil)
                        {
                            self.Add_lockView()
                            
                            self.local_view.hidden = true
                           //  self.back_btn.hidden  = true
                        }
                    }
                    else
                    {
                        self.Remove_lockView()
                        self.local_view.hidden = false
                       //  self.back_btn.hidden  = false
                    }
                    
            })
        }
    }
    
    func Local()
    {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //设置是否允许编辑
            picker.allowsEditing = false
            picker.mediaTypes =  [kUTTypeMovie as String]
            // picker.videoQuality  = UIImagePickerControllerQualityType.TypeLow
            
            //弹出控制器，显示界面
            self.presentViewController(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误", terminator: "")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //查看info对象
        
        //获取选择的原图
        // let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //imageView.image = image
        //图片控制器退出
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
        
        if let type1:AnyObject = mediaType {
            if type1 is String {
                let stringType = type1 as! String
                if stringType == kUTTypeMovie as String {
                    
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    
                    print(urlOfVideo)
                    
                    
                    //let urlString = "text.mp4"
                    //let output = NSURL(string: urlString)
                    
                    let dateString = "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
                    
                    let movDir = NSHomeDirectory() + "/Documents/Movie"
                    
                    let fileManager = NSFileManager.defaultManager()
                    
                    if !fileManager.fileExistsAtPath(movDir) {
                        try! fileManager.createDirectoryAtPath(movDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    
                    let movName = dateString + ".mp4"
                    
                    let betaCompressionDirectory = movDir + "/" + movName
                    
                    let outputURL = NSURL(fileURLWithPath: betaCompressionDirectory)
                    
                    self.convertVideoQuailtyWithInputURL(urlOfVideo!, outputUrl: outputURL, completeHandler:{ (handler:AVAssetExportSession) in
                        
                        
                        
                        let publishViewController =  YSPulishInformationViewController()
                        
                        if self.type == .Discovery {
                            publishViewController.type = .Discovery
                        } else {
                            publishViewController.cpid = self.cpid
                            publishViewController.type = .Competition
                            publishViewController.crid = self.crid
                            publishViewController.competition_type = self.competition_type
                            if self.matchName != nil {
                                publishViewController.matchName = self.matchName
                            }
                        }
    
                        
                        publishViewController.contentURLStr = betaCompressionDirectory
                        publishViewController.movieName = movName
                        
                        self.navigationController?.navigationBarHidden = false
                        self.navigationController?.pushViewController(publishViewController, animated: true)
                        
                        
                        
                    })
                    
                    
                    
                    
                    // }
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: {
                () -> Void in
                
               // self.Back()
            })
        }
    }
    
    
    // 仅仅转换格式
    func convertVideoQuailtyWithInputURL(inputUrl:NSURL,outputUrl:NSURL,completeHandler:(handler:AVAssetExportSession)->Void)->Void{
        
        let avAsset = AVURLAsset.init(URL: inputUrl, options: nil)
        
        let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)  //输出质量)
        
        exportSession?.outputFileType = AVFileTypeMPEG4  //类型
        exportSession?.outputURL = outputUrl
        exportSession?.shouldOptimizeForNetworkUse = true
        
        exportSession?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            switch exportSession!.status {
                
            case AVAssetExportSessionStatus.Cancelled:
                print("AVAssetExportSessionStatusCancelled", terminator: "")
                
            case AVAssetExportSessionStatus.Unknown:
                print("AVAssetExportSessionStatusUnknown", terminator: "")
                
            case AVAssetExportSessionStatus.Waiting:
                print("AVAssetExportSessionStatus.Waiting", terminator: "")
                
            case AVAssetExportSessionStatus.Exporting:
                
                print("AVAssetExportSessionStatus.Exporting", terminator: "")
                
            case AVAssetExportSessionStatus.Completed:  //转码完成后在这里操作后续
                print("AVAssetExportSessionStatusCompleted", terminator: "")
                
                //  print("=====\(self.getVideoLength(outputUrl))")
                // print("=====\(self.getFileSize(outputUrl.path!))")
                
                completeHandler(handler: exportSession!)
                
            default:
                break
                
            }
        })
        
    }
}
