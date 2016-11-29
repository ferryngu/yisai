//
//  YSPulishInformationViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/8/15.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

enum PPulishInformationType {
    case Discovery
    case Competition
}


class YSPulishInformationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    

    var movieController: MoviePlayerController!
    var containerView: UIView!
    var movieName: String!
    var contentURLStr: String!
    var type: PPulishInformationType!
    var cpid: String!
    var crid: String!
    var recordTouchStatus: Bool = false
    var commitTouchStatus: Bool = false
    var matchName: String!

    var txf_Name: UITextField!
    var txf_BounDate: UILabel!
    
    var confirmInfo: YSCompetitionConfirmInfo!
    var bgView:UIView!
    var bgView_black:UIView!
    var contentView:UIView!
    
    var selectWcid: String! // 选中的作品分类ID
    var selectCatName: String! // 选中的作品分类名称
    var tips: FETips = FETips()
    
    var isConfirm:Bool!
    var popView: PSPopView!
    var progressView:UIProgressView!
    var Bottomview:UIView!
    var progress: ZFProgressView!
    var competition_type: String!
    
    
    var txt_type: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
       // self.navigationController?.navigationBarHidden = true
        // self.navigationController?.navigationBar.backIndicatorImage =
        
        let backItem:UIBarButtonItem = UIBarButtonItem(image:UIImage(named: "cs_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTouched))
        backItem.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = backItem
        
        self.title = "提交视频"
        
        tips.duration = 1
        
         fetchConfirmInfo()
        
        
        let org_x:CGFloat = 0
        let org_y:CGFloat = SCREEN_WIDTH * 480.0 / 864.0 + 10
        let org_h:CGFloat = 50*3+10
        
        containerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, org_y))
        self.view.addSubview(containerView)
        
        
        
        
        let dataTable = UITableView(frame: CGRectMake(org_x, org_y, SCREEN_WIDTH, org_h),style:UITableViewStyle.Grouped)
        dataTable.dataSource = self
        dataTable.delegate  = self
        dataTable.scrollEnabled = false
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        self.view.addSubview(dataTable);

        self.configurePlayer()
        
        let height = ( SCREEN_HEIGHT - (SCREEN_WIDTH * 480.0 / 864.0))/2
        
        let button =  UIButton(type:.Custom)
        button.frame = CGRectMake(15, SCREEN_HEIGHT-height, SCREEN_WIDTH-30, 43)
        button.setTitle("确认提交", forState:UIControlState.Normal) //普通状态下的文字
        button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        button.setTitleColor(UIColor.grayColor(),forState: .Highlighted) //普通状态下文字的颜色
        button.backgroundColor = UIColor.init(red: 239/255, green: 97/255, blue: 80/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self,action:#selector(tapped),forControlEvents:.TouchUpInside)
        
        
        //  button.buttonType = UIButtonType.RoundedRect
        self.view.addSubview(button)
        

        
        
        initshare()
        
        
        if crid == nil {
            fetchCrid()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateProgress:", name: YSMovieUploadProgressNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadFinish:", name: YSMovieUploadFinishNotification, object: nil)

        // 将要进入全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillEnterFullscreen:", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        // 将要退出全屏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillExitFullscreen:", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMovieUploadProgressNotification, object: nil)
        
         NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMovieUploadFinishNotification, object: nil)
        
        // 将要进入全屏
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        // 将要退出全屏
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchConfirmInfo() {
        
        if cpid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getConfirmDetail(cpid, resp: { [weak self] (resp_confirmInfo: YSCompetitionConfirmInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.confirmInfo = resp_confirmInfo
           // self!.configureData()
            // self!.tableView.reloadData()
            })
    }
    
    func configurePlayer() {
        
        movieController = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("MoviePlayerController") as! MoviePlayerController
        
        //movieController.style = .Normal
        movieController.contentURL = NSURL(fileURLWithPath: contentURLStr)
        self.addChildViewController(movieController)
        movieController.view.frame = self.containerView.bounds
        movieController.canFullscreen = false
        self.containerView.addSubview(movieController.view)
        movieController.setupPlayingVideo()
        //movieController.stopPlayingVideo()
        movieController.topBgView.hidden  = true

        
 
 
        //self.addChildViewController(movieController)
       // movieController.view.frame = self.containerView.bounds
    
        //            movieController.setupPlayingVideo()

        
        
    }
    
    //1.1默认返回一组
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    // 1.2 返回行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(type == .Discovery)
        {
            return 2;
        }
        else
        {
            return 1;
        }
        
    }
    
    //1.3 返回行高
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 50;
        
    }
    
    //1.4每组的头部高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1;
    }
    
    //1.5每组的底部高度
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    //1.6 返回数据源
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier="identtifier";
        
        var cell=tableView.dequeueReusableCellWithIdentifier(identifier);
        if(cell == nil){
            cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
        }
        
        switch indexPath.row {
        case 0:
            
             let  title_str = UILabel(frame: CGRectMake(15,10,185,30))

             title_str.textColor = UIColor.blackColor()
             title_str.textAlignment = NSTextAlignment.Left
             title_str.text = "作品名称";
             
             cell?.contentView.addSubview(title_str)
             
             
            txf_Name = UITextField(frame: CGRectMake(100,10,200,30))
            //设置边框样式为圆角矩形
            txf_Name.borderStyle = UITextBorderStyle.None
            txf_Name.placeholder="请填写作品名称"
            cell?.contentView.addSubview(txf_Name)
             
             let toolBar = UIToolbar()
             toolBar.barStyle = UIBarStyle.Default
             toolBar.frame = CGRectMake(0,0,SCREEN_WIDTH,40)
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
             
             let button =  UIButton(type:.Custom)
             button.frame=CGRectMake(2, 2, 50, 30)
             button.setTitle("完成", forState:UIControlState.Normal) //普通状态下的文字
             button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
             button.backgroundColor = UIColor.redColor()
             button.layer.cornerRadius = 5
             button.addTarget(self,action:#selector(resignInput),forControlEvents:.TouchUpInside)
             
             
             //继续创建按钮
            // let doneButton = UIBarButtonItem(title: "完成", style:UIBarButtonItemStyle.Plain, target:self, action:#selector(resignInput))
             
             let doneButton  = UIBarButtonItem(customView: button)
             
             
             
             toolBar.setItems([spaceButton, doneButton], animated: false)
             
             
             txf_Name.inputAccessoryView =  toolBar
             
             
             

            
             
             
             
            break;
        default:
            // cell?.textLabel?.text = "作品类型";
             
             let  title_str = UILabel(frame: CGRectMake(15,10,185,30))
             
             title_str.textColor = UIColor.blackColor()
             title_str.textAlignment = NSTextAlignment.Left
             title_str.text =  "作品类型";
             
             cell?.contentView.addSubview(title_str)
             
             
             
            txf_BounDate = UILabel(frame: CGRectMake(100,10,200,30))
            //设置边框样式为圆角矩形
            //  txf_BounDate.borderStyle = UITextBorderStyle.None
            // txf_BounDate.placeholder="请输入出生日期(必填)"
            txf_BounDate.textColor = UIColor.grayColor()
            txf_BounDate.textAlignment = NSTextAlignment.Left
            txf_BounDate.text = "请选择作品类型"
            
            cell?.contentView.addSubview(txf_BounDate)
             
            cell?.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
             
            break;
        
            
        }
        
        cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle =  UITableViewCellSelectionStyle.None
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //print(indexPath.section)
        // print(indexPath.row)
        if indexPath.row == 1 {
            // 选择组别
            resignInput()
            
            YSPublish.getWorkCategory(respBlock: { [weak self] (lst_workcategory: [YSWorkCategory]!, errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                for workcategory in lst_workcategory {
                    let action = UIAlertAction(title: workcategory.category_name, style: .Default, handler: { (action: UIAlertAction) -> Void in
                        self!.selectWcid = workcategory.wcid
                        self!.selectCatName = workcategory.category_name
                        self!.txf_BounDate.text = workcategory.category_name
                        self!.txf_BounDate.textColor = UIColor.blackColor()
                    })
                    alertController.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self!.view
                  //  alertController.popoverPresentationController?.sourceRect = self!.view.frame
                }
                
                
                self!.presentViewController(alertController, animated: true, completion: nil)
                
                
                })
            
        }
    }
    
    
    func tapped(){
        
        
      
        
        if checkInputEmpty(txf_Name.text) {
            tips.showTipsInMainThread(Text: "请填写作品名称")
            return
        }
         if type == .Discovery {
          
            if checkInputEmpty(txf_BounDate.text) {
                tips.showTipsInMainThread(Text: "请填写作品名称")
                return
            }
            
            if txf_BounDate.text == "请选择作品类型" {
                tips.showTipsInMainThread(Text: "请选择作品类型")
                return
            }
        }
        
        self.movieController.stopPlayingVideo()
        
        GetFileSize(contentURLStr)
        
        
        share()
        
        txt_type.text = "视频准备上传"
        
        yasuoMovie(resp: {() -> Void in
            
            self.txt_type.text = "视频正在上传"
            
             self.progress.setProgress(0.0, animated: false)
            delayCall(1.0, block: { () -> Void in
               self.updateload()
            })

            
            })
        
      //  delayCall(2.0, block: { () -> Void in
           
            
           
            
        
        }
    
    func  updateload()
    {
        if type == .Competition {
            // 提交比赛资料
            if (isConfirm != nil) {
                tips.showTipsInMainThread(Text: "正在提交作品资料")
                return
            }
            
            isConfirm = true
            
            
            YSPublish.publishCompetitonFindwork(txf_Name.text!, file_name: movieName, teacher_name: nil, teacher_phone: nil, crid: crid, resp: { [weak self] (resp_crid: String!, resp_wid: String!, errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    
                    self!.isConfirm = false
                    
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                let uid = ysApplication.loginUser.uid
                
                let movie = YSMovie(uid: uid, name: self!.movieName, progress: 0.0, uploadStatus: false, title: self!.txf_Name.text)
                YSMovie.addUploadMovie(movie)
                
                addUploadMovie(self!.movieName)
                
                
                self!.handleNetwork()
                
                
                
                
                })
        }
        else
        {
            if (isConfirm != nil) {
                tips.showTipsInMainThread(Text: "正在提交作品资料")
                return
            }
            
            isConfirm = true
            
            // 提交发现作品
            YSPublish.publishDiscoveryFindwork(selectWcid, title: txf_Name.text!, fileName: movieName) { [weak self] (resp_wid: String!, errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    
                    self!.isConfirm = false
                    
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                //    self!.tips.showTipsInMainThread(Text: "提交成功")
                
                //self!.wid = resp_wid
                
                // let uid = ysApplication.loginUser.uid
                
                //let movie = YSMovie(uid: uid, name: self!.movieFileName, progress: 0.0, uploadStatus: false, title: self!.txv_title.text)
                // YSMovie.addUploadMovie(movie)
                
                /// addUploadMovie(self!.movieFileName)
                
               // let uid = ysApplication.loginUser.uid
                
                //let movie = YSMovie(uid: uid, name: self!.movieName, progress: 0.0, uploadStatus: false, title: self!.txf_Name.text)
               // YSMovie.addUploadMovie(movie)
                
                addUploadMovie(self!.movieName)
                
                
                self!.handleNetwork()
            }
            
        }

    }
    
    
    
    func backButtonTouched()
    {
      //  self.dismissViewControllerAnimated(false, completion: { [weak self] () -> Void in
           // self!.movieController.stopPlayingVideo()
          //  })
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.popViewControllerAnimated(true)
       //  self.movieController.stopPlayingVideo()
    }
    
    
    func resignInput() {
        
        txf_Name.resignFirstResponder()
       
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        txf_Name.resignFirstResponder()
    }
    
    func handleNetwork() {
        
        let networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
        switch networkStatus {
        case .NotReachable:
            let alertController = UIAlertController(title: nil, message: "网络不给力，请检测网络", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
               // self.gotoThanksViewController()
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWWAN:
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续上传?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
               // self.gotoThanksViewController()
            })
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction) -> Void in
                uploadMovies(selectUpMovieName: self.movieName)
               // self.gotoThanksViewController()
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWiFi:
            
           
           
            uploadMovies(selectUpMovieName: self.movieName)
            
            
         //   gotoThanksViewController()
        //            dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
        func updateProgress(notification: NSNotification) {
            let userInfo = notification.userInfo as? Dictionary<String, String>
            if userInfo == nil {
                return
            }
            
            let key = userInfo!["key"]!
            let percent = userInfo!["percent"]!
            
            print(percent, terminator: "")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               
              //  cirect.process =  (percent as  NSString).floatValue
              //  self.progress.angle = Int((percent as  NSString).floatValue * 360.0)
                //lab_mProgress.text = "当前进度：" + "\(Int(progressView.progress * 100.0))%"
               // progress setProgress:(percent as  NSString).floatValue Animated:YES];
                let value1:CGFloat = CGFloat((percent as  NSString).floatValue)
                self.progress.setProgress(value1, animated: false)
            })

          //  progressView.progress =
            //progressView.setProgress((percent as NSString).floatValue,animated:true)
           /* for index in 0..<arr_movies.count {
                let movie = arr_movies[index]
                if !isDelete && key == movie.name && movie.uploadStatus {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
                    if cell == nil {
                        break
                    }
                    
                    print("\npercent = \(percent)", terminator: "")
                    let progressView = cell!.contentView.viewWithTag(13) as! UIProgressView
                    let lab_mProgress = cell!.contentView.viewWithTag(14) as! UILabel
                    
                    let progress = YSUploadProgress.getProgress(movie.name)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        progressView.progress = (((progress == nil) ? "0.0" : progress!) as NSString).floatValue  / 100.0
                        lab_mProgress.text = "当前进度：" + "\(Int(progressView.progress * 100.0))%"
                    })
                    break
                }
            }*/
            
        }
    
    //获取报名ID
    func fetchCrid() {
        
        if cpid == nil {
            return
        }
        
        YSPublish.getCridByCpid(cpid, respBlock: { [weak self] (resp_crid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.crid = resp_crid
           // self!.localFindwork.crid = resp_crid
            })
    }
    
    func uploadFinish(notification: NSNotification)
    {
        //提交完成
        if(type == .Discovery)
        {
            self.txt_type.text = "视频上传成功"
            progress.setProgress(1.0, animated: false)
            
            self.tips.showTipsInMainThread(Text: "上传成功，请刷新页面查看")
            
            delayCall(3, block: { () -> Void in
                
                self.bgView.hidden = true
                

                //发现频道
                //self.backButtonTouched()
                 self.navigationController?.navigationBarHidden = false
                 self.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
        else
        {

            
        self.txt_type.text = "视频上传成功"
        progress.setProgress(1.0, animated: false)
            
            if self.confirmInfo.application_fee != nil && (self.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
                // 赛事报名收费点击
                MobClick.event("join_competition", attributes: ["fee_type": "charge"])
                
            } else {
                
                // 赛事报名免费点击
                MobClick.event("join_competition", attributes: ["fee_type": "free"])
            }
            
            
            
            if self.confirmInfo.application_fee != nil && (self.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
                delayCall(3, block: { () -> Void in
                    
                    self.bgView.hidden = true
                    
                    let controller = YSPulishPayViewController()
                    controller.crid = self.crid
                    controller.match_name = self.confirmInfo.match_name
                    controller.application_fee = self.confirmInfo.application_fee
                    controller.benefit_price = self.confirmInfo.benefit_price
                    controller.competition_type = self.competition_type
                    controller.real_price = self.confirmInfo.application_fee
                    
                    
                    controller.isRoot  = false
                    if  ysApplication.loginUser.role_type != "1"
                    {
                        controller.application_fee = self.confirmInfo.pay_amount
                    }
                    
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("UpdateStudentList", object: nil, userInfo: nil)
                    
                })
                
            } else {
                
                //免费赛事

                
                let settoDic: Dictionary<String, String>? = [ "DateTime": "1"]
                
                fe_std_data_set_json("YSUploadState", key: ysApplication.loginUser.uid +  confirmInfo.cpid, jsonValue: settoDic, expire_sec: 10 * 60)
                
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateStudentList", object: nil, userInfo: nil)
                
                
                delayCall(3, block: { () -> Void in
                    self.bgView.hidden = true
                     self.navigationController?.popToRootViewControllerAnimated(true)
                })
                
                
            }
        }
        
    }
    
    
    // MARK: - Notification
    
    func moviePlayerWillEnterFullscreen(notification: NSNotification) {
        
       // fullscreen = true
    }
    
    func moviePlayerWillExitFullscreen(notification: NSNotification) {
        
        //fullscreen = false
    }

    func initshare()
    {
        bgView = UIView(frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+65))
        bgView.hidden = true
        bgView_black = UIView(frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+65))
        bgView_black.backgroundColor = UIColor.blackColor()
        bgView_black.alpha = 0
        bgView.addSubview(bgView_black)
        
        self.navigationController?.view.addSubview(bgView)
        
        
        contentView = UIView(frame: CGRect(x: SCREEN_WIDTH/2-100, y: SCREEN_HEIGHT, width: 200, height: 100))
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.cornerRadius = 10
        bgView.addSubview(contentView)
        

       progress = ZFProgressView(frame: CGRect(x: 20, y: 20, width: 60, height: 60))
       progress.innerBackgroundColor = UIColor.whiteColor();
        progress.progressStrokeColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 1);
       progress.backgroundStrokeColor = UIColor.whiteColor();
      //  progress.setDigitTintColor(UIColor.redColor())
        progress.setProgress(0.0, animated: false)
        contentView.addSubview(progress)
        
        txt_type = UILabel(frame: CGRectMake(100,30,200,40))
        //设置边框样式为圆角矩形
        //  txf_BounDate.borderStyle = UITextBorderStyle.None
        // txf_BounDate.placeholder="请输入出生日期(必填)"
        txt_type.textColor = UIColor.blackColor()
        txt_type.textAlignment = NSTextAlignment.Left
        
        txt_type.font = UIFont.systemFontOfSize(20.0)
        contentView.addSubview(txt_type)
        
        

    }
    func share() {
        
        /* umsocial */
      //  if popView == nil {
           // popView = PSPopView()
       // }
       // popView.initView(self.view.bounds)
       // self.navigationController?.view.addSubview(popView)
       // popView.show()
        self.progress.setProgress(0.95, animated: true)
        
        
        bgView.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {[weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.bgView_black.alpha = 0.4
            self!.contentView.frame = CGRect(x: SCREEN_WIDTH/2-125, y: SCREEN_HEIGHT/2-50, width:250, height: 100)
            })

    }

    
    func yasuoMovie(resp block: (()-> Void))
    {
        
        let movDir = NSHomeDirectory() + "/Documents/Movie"
        let betaCompressionDirectory = movDir + "/" + movieName
        //            var error: NSError?
        let videoPath = NSURL(fileURLWithPath: betaCompressionDirectory)
        
        print(videoPath)
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
        
        let exportPath = movDir + "/m_" + movieName
        
        movieName = "m_" + movieName
        
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
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                //if block == nil {
                //  return
                // }
                block()
                
            })
            
            
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
