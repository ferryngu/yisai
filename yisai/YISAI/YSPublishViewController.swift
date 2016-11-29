//
//  YSPublishViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/5.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum PublishType {
    case Discovery
    case Competition
}

class YSPublishViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var leftItem: UIBarButtonItem!
    @IBOutlet weak var txv_title: UITextView!
    @IBOutlet weak var lab_category: UILabel!
    @IBOutlet weak var txf_tchName: UITextField!
    @IBOutlet weak var txf_tchTel: UITextField!
    @IBOutlet weak var btn_record: UIButton!
    @IBOutlet weak var lab_ps: UILabel!
    @IBOutlet weak var categoryCell: UITableViewCell!
    
    var moviePath: String!
    var movieFileName: String!
    var selectWcid: String! // 选中的作品分类ID
    var selectCatName: String! // 选中的作品分类名称
    var tips: FETips = FETips()
    var type: PublishType! // 发布类型
    var crid: String! // 作品ID
    var cid: String! // 孩子ID
    var cpid: String! // 赛事ID
    var localFindwork: YSFindwork! // 本地保存好的作品
    var findworkTutor: YSFindworkTutor! // 作品指导老师
    var isConfirm: Bool = false
    var wid: String!
    var matchName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = FETips()
        tips.duration = 1
        
        if movieFileName != nil {
            btn_record.enabled = false
            configureRecordView()
        }
        
        if type == .Competition {
            
            if categoryCell != nil {
                
                for subview in categoryCell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                categoryCell.contentView.hidden = true
            }
            
            leftItem.image = nil
            leftItem.title = "稍后填写"
            
            localFindwork = YSFindwork.getFindwork(cpid)
            findworkTutor = YSFindworkTutor.getTutor()
            
            configureTeacherView()
            
            if localFindwork != nil && localFindwork.uid == ysApplication.loginUser.uid {
                if localFindwork.crid == "" {
                    fetchCrid()
                }
                configurePublishView()
                return
            }
            
            if crid == nil {
                fetchCrid()
            }
            
            localFindwork = YSFindwork()
            localFindwork.cpid = cpid
            localFindwork.uid = ysApplication.loginUser.uid
            
        } else {
            lab_ps.hidden = true
            leftItem.image = UIImage(named: "cs_fanhui")
            leftItem.title = nil
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self!.localFindwork.crid = resp_crid
        })
    }
    
    func configurePublishView() {
        
        if localFindwork.crid.characters.count > 0 {
            crid = localFindwork.crid
        }
        
        if localFindwork.title.characters.count > 0 {
            txv_title.text = localFindwork.title
        }
        
        if localFindwork.categoryName.characters.count > 0 && localFindwork.categoryId.characters.count > 0 {
            
            selectWcid = localFindwork.categoryId
            selectCatName = localFindwork.categoryName
            lab_category.text = localFindwork.categoryName
        }
        
        if localFindwork.movieName.characters.count > 0 {
            
            moviePath = MovieFilesManager.movieFilePathURL(localFindwork.movieName).relativePath
            movieFileName = localFindwork.movieName
            
            btn_record.enabled = false
            configureRecordView()
        }
    }
    
    func configureTeacherView() {
        
        if findworkTutor != nil {
            
            txf_tchName.text = findworkTutor.teacherName
            txf_tchTel.text = findworkTutor.teacherTel
        }
    }
    
    func configureRecordView() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
            
            print(self!.moviePath, terminator: "")
            let image = MovieFilesManager.getImage(NSURL(fileURLWithPath: self!.moviePath))
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self!.btn_record.setBackgroundImage(image, forState: .Normal)
                self!.btn_record.setImage(nil, forState: .Normal)
            })
        })
    }
    
    func setLocalFindWork() {
        
        if selectCatName != nil && selectWcid != nil {
            localFindwork.categoryId = selectWcid
            localFindwork.categoryName = selectCatName
        }
        
        if txv_title.text != "请输入你的作品名......" && !checkInputEmpty(txv_title.text) {
            localFindwork.title = txv_title.text
        }
        
//        if !checkInputEmpty(txf_tchName.text) {
//            localFindwork.teacherName = txf_tchName.text
//        }
//        
//        if !checkInputEmpty(txf_tchTel.text) {
//            localFindwork.teacherTel = txf_tchTel.text
//        }
        
        if movieFileName != nil {
            localFindwork.movieName = movieFileName
        }
        
        if crid != nil {
            localFindwork.crid = crid
        }
        
        YSFindwork.setFindwork(localFindwork)
        
        if !checkInputEmpty(txf_tchName.text) && !checkInputEmpty(txf_tchTel.text) {
            let tutor = YSFindworkTutor(teacherName: txf_tchName.text, teacherTel: txf_tchTel.text)
            YSFindworkTutor.setTutor(tutor)
        }
    }

    func resignInput() {
        
        txf_tchName.resignFirstResponder()
        txf_tchTel.resignFirstResponder()
        txv_title.resignFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if type == .Discovery {
            return 2
        } else {
            if section == 0 {
                return 4
            } else {
                return 2
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if type == .Discovery {
            if indexPath.section == 0 {
                return indexPath.row == 0 ? SCREEN_WIDTH * 170.0 / 414.0 : 44.0
            } else {
                return indexPath.row == 0 ? 0.0 : 120.0
            }
        } else {
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    return SCREEN_WIDTH * 170.0 / 414.0
                case 2:
                    return 54.0
                case 1:
                    return 0.01
                default:
                    return 44.0
                }
            } else {
                return indexPath.row == 0 ? 52.0 : 120.0
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 && type == .Discovery {
            
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
                        self!.lab_category.text = workcategory.category_name
                    })
                    alertController.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self!.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if txv_title.text == "请输入你的作品名......" {
            txv_title.text = ""
        }
        
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if checkInputEmpty(txv_title.text) {
            txv_title.text = "请输入你的作品名......"
        }
        
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func cancelInput(sender: AnyObject) {
        
        resignInput()
    }
    
    @IBAction func writeLater(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if type == .Discovery {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        setLocalFindWork()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func gotoRecord(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        setLocalFindWork()
        
        let controller = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
        controller.matchName = matchName
        controller.cpid = cpid
        controller.cameraMovieStyle = .Competition
        dismissViewControllerAnimated(true, completion: nil)
        ysApplication.tabbarController.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func commit(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if type == .Discovery && selectWcid == nil  {
            tips.showTipsInMainThread(Text: "请选择分类")
            return
        }
        
        if checkInputEmpty(txv_title.text) || txv_title.text == "请输入你的作品名......" {
            tips.showTipsInMainThread(Text: "请输入你的作品名")
            return
        }
        
        if movieFileName == nil {
            tips.showTipsInMainThread(Text: "请拍摄你的作品")
            return
        }
        
        if type == .Competition {
            if crid == nil{
                tips.showTipsInMainThread(Text: "正在获取比赛信息")
                return
            }
            
            // 提交比赛作品
            if txf_tchName.text == nil && txf_tchTel.text != nil {
                tips.showTipsInMainThread(Text: "请输入指导老师姓名")
                return
            }
            
            if txf_tchName.text != nil && txf_tchTel.text == nil {
                tips.showTipsInMainThread(Text: "请输入指导老师联系电话")
                return
            }
            
            if isConfirm {
                tips.showTipsInMainThread(Text: "正在提交作品资料")
                return
            }
            
            isConfirm = true
            
            YSPublish.publishCompetitonFindwork(txv_title.text, file_name: movieFileName, teacher_name: txf_tchName.text, teacher_phone: txf_tchTel.text, crid: crid, resp: { [weak self] (resp_crid: String!, resp_wid: String!, errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    
                    self!.isConfirm = false
                    
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                if !checkInputEmpty(self!.txf_tchName.text) || !checkInputEmpty(self!.txf_tchTel.text) {
                    
                    // 绑定老师
                    MobClick.event("bind_teacher")
                }
                
                self!.tips.showTipsInMainThread(Text: "提交成功")
                
                let tutor = YSFindworkTutor.getTutor()
                if tutor != nil && tutor!.isChange != nil && tutor!.isChange == 1 {
                    ysApplication.mineViewController.tabBarController!.tabBar.showBadgeOnItemIndex(2)
                }
                
                fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
                
                self!.wid = resp_wid
                
                let uid = ysApplication.loginUser.uid
                
                let movie = YSMovie(uid: uid, name: self!.movieFileName, progress: 0.0, uploadStatus: false, title: self!.txv_title.text)
                YSMovie.addUploadMovie(movie)
                
                addUploadMovie(self!.movieFileName)
                
                delayCall(1.0, block: { () -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
//                        uploadMovies(selectUpMovieName: self!.movieFileName)
//                        self!.dismissViewControllerAnimated(true, completion: nil)
                        self!.handleNetwork()
                    })
                    
                    let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
//                        self!.dismissViewControllerAnimated(true, completion: nil)
                        self!.gotoThanksViewController()
                    })
                    let alertController = UIAlertController(title: "提示", message: "是否立刻上传本作品?", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                })
            })
            
        } else {
            
            if isConfirm {
                tips.showTipsInMainThread(Text: "正在提交作品资料")
                return
            }
            
            isConfirm = true
            
            // 提交发现作品
            YSPublish.publishDiscoveryFindwork(selectWcid, title: txv_title.text, fileName: movieFileName) { [weak self] (resp_wid: String!, errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    
                    self!.isConfirm = false
                    
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                self!.tips.showTipsInMainThread(Text: "提交成功")
                
                self!.wid = resp_wid

                let uid = ysApplication.loginUser.uid
                
                let movie = YSMovie(uid: uid, name: self!.movieFileName, progress: 0.0, uploadStatus: false, title: self!.txv_title.text)
                YSMovie.addUploadMovie(movie)
                
                addUploadMovie(self!.movieFileName)
                
                delayCall(1.0, block: { () -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                        self!.handleNetwork()
                    })
                    
                    let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
//                        self!.dismissViewControllerAnimated(true, completion: nil)
                        self!.gotoThanksViewController()
                    })
                    let alertController = UIAlertController(title: "提示", message: "是否立刻上传本作品?", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    func gotoThanksViewController() {
        
        if wid == nil {
            return
        }
        
        let controller = storyboard?.instantiateViewControllerWithIdentifier("YSThanksViewController") as! YSThanksViewController
        controller.discoveryOrCompetition = (type == PublishType.Discovery) ? false : true
        controller.matchName = matchName
        controller.movieTitle = txv_title.text
        controller.wid = wid
        controller.cpid = cpid
        controller.shareImage = btn_record.backgroundImageForState(.Normal)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleNetwork() {
        
        let networkStatus = ysApplication.networkReachability.networkReachabilityStatus
        
        switch networkStatus {
        case .NotReachable:
            let alertController = UIAlertController(title: nil, message: "网络不给力，请检测网络", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
                self.gotoThanksViewController()
            })
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWWAN:
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续上传?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
                self.gotoThanksViewController()
            })
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction) -> Void in
                uploadMovies(selectUpMovieName: self.movieFileName)
                self.gotoThanksViewController()
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.frame
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWiFi:
            
            uploadMovies(selectUpMovieName: self.movieFileName)
            
            
            gotoThanksViewController()
//            dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
}
