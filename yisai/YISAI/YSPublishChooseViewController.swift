//
//  YSPublishChooseViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/8/9.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

enum ChooseContainerType {
    case Discovery
    case Competition
}


class YSPublishChooseViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    var moviePath: String!
    var movieFileName: String!
    var selectWcid: String! // 选中的作品分类ID
    var selectCatName: String! // 选中的作品分类名称
    var tips: FETips = FETips()
    var type: ChooseContainerType! // 发布类型
    var crid: String! // 作品ID

    var cpid: String! // 赛事ID
    var localFindwork: YSFindwork! // 本地保存好的作品
    var findworkTutor: YSFindworkTutor! // 作品指导老师
    var isConfirm: Bool = false
    

    
    var wid: String!
    var matchName: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBarHidden = true
        
        self.view.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        //let top:CGFloat =  0;
        tips.duration = 1
        
       // let lab_title = UILabel(frame: CGRectMake(0,SCREEN_HEIGHT-300,SCREEN_WIDTH,30))

        //lab_title.textColor = UIColor.grayColor()
       // lab_title.textAlignment = NSTextAlignment.Center
       // lab_title.text = "请选择视频上传方式"
       // lab_title.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
       // self.view?.addSubview(lab_title)
        
        let btn_width:CGFloat = SCREEN_WIDTH/4
       
        
        
        let imageView = UIView(frame: CGRectMake(0,SCREEN_HEIGHT-230,SCREEN_WIDTH,btn_width+50))
        imageView.backgroundColor =  UIColor.clearColor()
         self.view?.addSubview(imageView)
        
        
        let btn_Current:UIButton = UIButton(frame: CGRectMake(SCREEN_WIDTH/2-btn_width-25,0,btn_width,btn_width))
        btn_Current.backgroundColor = UIColor.clearColor()
        btn_Current.addTarget(self,action:#selector(Current),forControlEvents:.TouchUpInside)
      //  btn_Current.currentBackgroundImage = UIImage(named: "pulish_current")
        //btn_Current.setImage(UIImage(named: "pulish_current"), forState: UIControlState.Normal)
        btn_Current.setBackgroundImage(UIImage(named: "pulish_current"), forState: UIControlState.Normal)
        
        imageView.addSubview(btn_Current)

        
        let lab_Current = UILabel(frame: CGRectMake(SCREEN_WIDTH/2-btn_width-25,btn_width+12,btn_width,30))
        
        //lab_title.textColor = UIColor.grayColor()
        lab_Current.textAlignment = NSTextAlignment.Center
        lab_Current.text = "现场拍摄"
        imageView.addSubview(lab_Current)

        
        
        
        let btn_local:UIButton = UIButton(frame: CGRectMake(SCREEN_WIDTH/2+25,0,btn_width,btn_width))
        btn_local.backgroundColor = UIColor.clearColor()
        btn_local.addTarget(self,action:#selector(Local),forControlEvents:.TouchUpInside)
        btn_local.setBackgroundImage(UIImage(named: "pulish_local"), forState: UIControlState.Normal)
        imageView.addSubview(btn_local)
        
       
        
      //  btn_local.frame.origin.y = lab_title.frame.origin.x+lab_title.frame.size.height+50
        
        let lab_local = UILabel(frame: CGRectMake(SCREEN_WIDTH/2+25,btn_width+12,btn_width,30))
        
        //lab_title.textColor = UIColor.grayColor()
        lab_local.textAlignment = NSTextAlignment.Center
        lab_local.text = "本地上传"

        imageView.addSubview(lab_local)

        
        
        let button1:UIButton = UIButton(frame: CGRectMake(0,SCREEN_HEIGHT-50,SCREEN_WIDTH,50))
        button1.backgroundColor = UIColor.whiteColor()
        button1.addTarget(self,action:#selector(Quit),forControlEvents:.TouchUpInside)
        self.view?.addSubview(button1)
        
        let igv_canel:UIImageView = UIImageView(frame: CGRectMake(0,10,30,30))
        igv_canel.image = UIImage(named: "pulish_canel")
   
        igv_canel.center = CGPoint(x: self.view.bounds.width / 2,y: 25)
        button1.addSubview(igv_canel)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func Quit() {
        
        //self.navigationController?.popViewControllerAnimated(true)
       // self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func Current()
    {
        let controller = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
        
        
        controller.matchName = matchName
        controller.cpid = cpid
        controller.crid = crid
        if self.type == .Discovery
        {
            controller.cameraMovieStyle = .Discovery
        }
        else
        {
            controller.cameraMovieStyle = .Competition
        }
        
      //  dismissViewControllerAnimated(true, completion: nil)
        
       // ysApplication.tabbarController.presentViewController(controller, animated: true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
        
        delayCall(0.5, block: { () -> Void in
            
            // ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
            // self.navigationController?.popViewControllerAnimated(true)
            
            let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromTop;
            nav.view.layer.addAnimation(transition, forKey: nil)
            
           // controller.navigationBar.hidden = true
            controller.hidesBottomBarWhenPushed = true
            nav.navigationBarHidden = true;
            nav.pushViewController(controller, animated: false)
            
            
        })
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
                            if self.matchName != nil {
                                publishViewController.matchName = self.matchName
                            }
                        }
                        
                        print("container movieName: \(movName) \n moviePath = \(betaCompressionDirectory)", terminator: "")
                        
                     //   let navController = UINavigationController(rootViewController: publishViewController)
                        
                      //  publishViewController.moviePath = betaCompressionDirectory
                       // publishViewController.movieFileName = movName
                        
                         publishViewController.contentURLStr = betaCompressionDirectory
                         publishViewController.movieName = movName
                        
                      //  self.navigationController?.popViewControllerAnimated(true)
                        
                       let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
                        
                        nav.popToRootViewControllerAnimated(true)
                        
                        delayCall(0.5, block: { () -> Void in
                            
                           // ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
                           // self.navigationController?.popViewControllerAnimated(true)
                            
                         //   let nav =   ysApplication.tabbarController.selectedViewController! as! UINavigationController
                            
                            publishViewController.hidesBottomBarWhenPushed = true
                            
                            nav.pushViewController(publishViewController, animated: false)


                        })
                        
                      //  self.navigationController?.pushViewController(publishViewController, animated: true)
                        
                     })
                    
                    
                    
                    
                    // }
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: {
                () -> Void in
                
                self.Quit()
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
