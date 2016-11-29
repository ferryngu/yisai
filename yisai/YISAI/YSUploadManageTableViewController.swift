//
//  YSUploadManageTableViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/31.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSUploadManageTableViewController: UITableViewController {

    private struct AssociatedKeys {
        static var GetStopUploadCell = "GetStopUploadCell"
        static var GetStopUploadMovie = "GetStopUploadMovie"
    }
    
    var arr_movies: [YSMovie]!
    var isDelete: Bool = false
//    let upManager: MovieUploadManager = MovieUploadManager(key: nil, movieOrImage: 1, status: 0)
    let tips: FETips = FETips()
    var timer: NSTimer!
//    var progress: Float! = 0.0
    var networkStatus: AFNetworkReachabilityStatus = .ReachableViaWiFi
    
//    var currentUploadMovie: YSMovie!
//    var uploadMovieName: String! // 从录制页进来，则优先上传录制的视频
//    var isContinueToUpload: Bool = false // 继续上传
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //arr_movies = Array(YSMovie.getUploadMoviesAboutUID()?.reverse())  jason
        YSMovie.cleanAllNotUploadMovies()
        
        arr_movies = YSMovie.getUploadMoviesAboutUID()?.reverse()
        
        networkStatus = ysApplication.networkReachability.networkReachabilityStatus
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "monitorNetworkStatus:", name: kYSNetworkStatus, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateProgress:", name: YSMovieUploadProgressNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadFinish:", name: YSMovieUploadFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadCancel:", name: YSMovieUploadCancelNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMovieUploadProgressNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMovieUploadFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSMovieUploadCancelNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if timer != nil {
            timer.invalidate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return (arr_movies != nil && arr_movies.count > 0) ? arr_movies.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isDelete {
            
            let deleteCell = tableView.dequeueReusableCellWithIdentifier("YSUpManageDeleteCell")
            
            if arr_movies == nil {
                return deleteCell!
            }
            
            let movie = arr_movies[indexPath.row]
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                let image = MovieFilesManager.getImage(MovieFilesManager.movieFilePathURL(movie.name))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let imageView = deleteCell!.contentView.viewWithTag(11) as! UIImageView
                    imageView.image = image
                })
            })
            
            let lab_mName = deleteCell!.contentView.viewWithTag(12) as! UILabel
            lab_mName.text = movie.title
            
            let lab_mProgress = deleteCell!.contentView.viewWithTag(14) as! UILabel
            lab_mProgress.text = "当前进度：" + "\(Int(movie.progress * 100.0))%"
            
            let btn_upload = deleteCell!.contentView.viewWithTag(16) as! UIButton
            
            btn_upload.addTarget(self, action: "deleteMovieFile:", forControlEvents: .TouchUpInside)
            objc_setAssociatedObject(btn_upload, &AssociatedKeys.GetStopUploadMovie, movie, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(btn_upload, &AssociatedKeys.GetStopUploadCell, deleteCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return deleteCell!
            
        } else {
        
            let normalCell = tableView.dequeueReusableCellWithIdentifier("YSUpManageContinousCell")
            
            if arr_movies == nil {
                return normalCell!
            }
            
            let movie = arr_movies[indexPath.row]
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                let image = MovieFilesManager.getImage(MovieFilesManager.movieFilePathURL(movie.name))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let imageView = normalCell!.contentView.viewWithTag(11) as! UIImageView
                    imageView.image = image
                })
            })
            
            let lab_mName = normalCell!.contentView.viewWithTag(12) as! UILabel
            lab_mName.text = movie.title
            
            let mProgressView = normalCell!.contentView.viewWithTag(13) as! UIProgressView
            
            let progress = YSUploadProgress.getProgress(movie.name)
            let progress_float = (((progress == nil) ? "0.0" : progress!) as NSString).floatValue  / 100.0
            mProgressView.progress = progress_float
            
            let lab_mProgress = normalCell!.contentView.viewWithTag(14) as! UILabel
            lab_mProgress.text = "当前进度：" + "\(Int(progress_float * 100.0))%"
        
            let lab_upSpeed = normalCell!.contentView.viewWithTag(15) as! UILabel
            let btn_upload = normalCell!.contentView.viewWithTag(16) as! UIButton
            if Int(movie.progress * 100) == 100 {
                lab_upSpeed.hidden = true
                btn_upload.setTitle("上传完成", forState: .Normal)
                btn_upload.backgroundColor = UIColor(red: 61.0/255.0, green: 206.0/255.0, blue: 156.0/255.0, alpha: 1.0)
                btn_upload.enabled = false
                mProgressView.hidden = true
            } else {
                
                if movie.uploadStatus {
                    
                    btn_upload.backgroundColor = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
                    btn_upload.setTitle("暂停", forState: .Normal)
                    
                    lab_upSpeed.text = "上传速度：0kB/s"
                    
                } else {
                    
                    btn_upload.titleLabel!.text = "续传"
                    btn_upload.backgroundColor = UIColor(red: 69.0/255.0, green: 143.0/255.0, blue: 232.0/255.0, alpha: 1.0)
                    
                    lab_upSpeed.text = ""
                }
                btn_upload.addTarget(self, action: "stopUpload:", forControlEvents: .TouchUpInside)
                objc_setAssociatedObject(btn_upload, &AssociatedKeys.GetStopUploadMovie, movie, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                objc_setAssociatedObject(btn_upload, &AssociatedKeys.GetStopUploadCell, normalCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return normalCell!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85.0
    }
    
    // MARK: - Actions
    
    @IBAction func editing(sender: AnyObject) {
        stopUploadMovie(nil)
        self.isDelete = !self.isDelete
        self.tableView.reloadData()
    }
    // 上传视频/停止上传/续传
    func stopUpload(button: UIButton) {
        
        if networkStatus != AFNetworkReachabilityStatus.ReachableViaWiFi {
            
            switch ysApplication.networkReachability.networkReachabilityStatus {
            case .NotReachable:
                let alertController = UIAlertController(title: nil, message: "无网络连接", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            case .ReachableViaWWAN:
                let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续上传?", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { [weak self] (action: UIAlertAction!) -> Void in
                    if self == nil {
                        return
                    }
                    
                    self!.networkStatus = AFNetworkReachabilityStatus.ReachableViaWiFi
                    self!.stopUpload(button)
                })
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
            default:
                let alertController = UIAlertController(title: nil, message: "网络错误", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
                alertController.addAction(action)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return
        }
        
        let movie = objc_getAssociatedObject(button, &AssociatedKeys.GetStopUploadMovie) as? YSMovie
        let cell = objc_getAssociatedObject(button, &AssociatedKeys.GetStopUploadCell) as? UITableViewCell
        
        if movie == nil || cell == nil {
            return
        }
        
        if movie!.uploadStatus {
            
            movie!.uploadStatus = false
            
//            tips.duration = 30
//            tips.showTipsInMainThread(Text: "正在停止上传")
            tips.showActivityIndicatorViewInMainThread("正在停止上传")
            stopUploadMovie(movie!.name)
        } else {
            
            movie!.uploadStatus = true
            
            let btn_upload = cell!.contentView.viewWithTag(16) as! UIButton
            btn_upload.backgroundColor = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
            btn_upload.setTitle("暂停", forState: .Normal)
            uploadMovies(selectUpMovieName: movie!.name)
        }
    }
    // 删除单个视频文件
    func deleteMovieFile(button: UIButton) {
        
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { [weak self] (action: UIAlertAction!) -> Void in
            
            if self == nil {
                return
            }
            
            let movie = objc_getAssociatedObject(button, &AssociatedKeys.GetStopUploadMovie) as? YSMovie
            let cell = objc_getAssociatedObject(button, &AssociatedKeys.GetStopUploadCell) as? UITableViewCell
            
            if movie == nil || cell == nil {
                return
            }
            
            

            
//            let result = find(self!.arr_movies, movie!)
            let result = self!.arr_movies.indexOf(movie!)
            if result == nil {
                return
            }
            self!.arr_movies.removeAtIndex(result!)
            
            self!.tableView.deleteRowsAtIndexPaths([self!.tableView.indexPathForCell(cell!)!], withRowAnimation: UITableViewRowAnimation.Fade)
            // 删除该文件对应的上传对象
            finishUploadMovie(movie!.name)
            
            YSMovie.cleanOneUploadMovie(movie!.name)
            
//            let fileManager = NSFileManager.defaultManager()
//            let movieStorePath = NSHomeDirectory() + "/Documents/Movie/" + movie!.name
//            let recordStorePath = NSHomeDirectory() + "/Documents/Recorder/" + movie!.name
//            var error: NSError?
//            if fileManager.fileExistsAtPath(movieStorePath) {
//                fileManager.removeItemAtPath(movieStorePath, error: &error)
//            }
//            
//            if fileManager.fileExistsAtPath(movieStorePath) {
//                fileManager.removeItemAtPath(movieStorePath, error: &error)
//            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let alertController = UIAlertController(title: "提示", message: "确定删除该作品?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Notification
    // 更新进度条
    func updateProgress(notification: NSNotification) {
        let userInfo = notification.userInfo as? Dictionary<String, String>
        if userInfo == nil {
            return
        }
        
        let key = userInfo!["key"]!
        let percent = userInfo!["percent"]!
        
        
        for index in 0..<arr_movies.count {
            let movie = arr_movies[index]
            if !isDelete && key == movie.name && movie.uploadStatus {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
                if cell == nil {
                    break
                }
                
               // print("\npercent = \(percent)", terminator: "")
                let progressView = cell!.contentView.viewWithTag(13) as! UIProgressView
                let lab_mProgress = cell!.contentView.viewWithTag(14) as! UILabel
                
                let progress = YSUploadProgress.getProgress(movie.name)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    progressView.progress = (((progress == nil) ? "0.0" : progress!) as NSString).floatValue  / 100.0
                    lab_mProgress.text = "当前进度：" + "\(Int(progressView.progress * 100.0))%"
                })
                break
        }
    }
    }
    // 上传成功
    func uploadFinish(notification: NSNotification) {
        
        let userInfo = notification.userInfo as? Dictionary<String, String>
        if userInfo == nil {
            return
        }
        
        let key = userInfo!["key"]!
        
        for index in 0..<arr_movies.count {
            let movie = arr_movies[index]
            if !isDelete && key == movie.name {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
                if cell == nil {
                    break
                }
                
                movie.uploadStatus = false
                movie.progress = 1.0
                
                let progressView = cell!.contentView.viewWithTag(13) as! UIProgressView
                let lab_mProgress = cell!.contentView.viewWithTag(14) as! UILabel
                let lab_mUploadSpeed = cell!.contentView.viewWithTag(15) as! UILabel
                let btn_upload = cell!.contentView.viewWithTag(16) as! UIButton
                
                progressView.hidden = true
                lab_mProgress.text = "当前进度：100%"
                lab_mUploadSpeed.hidden = true
                btn_upload.setTitle("上传完成", forState: .Normal)
                btn_upload.backgroundColor = UIColor(red: 61.0/255.0, green: 206.0/255.0, blue: 156.0/255.0, alpha: 1.0)
                btn_upload.enabled = false
                
                break
            }
    }
    }
    // 取消上传
    func uploadCancel(notification: NSNotification) {
        
        let userInfo = notification.userInfo as? Dictionary<String, String>
        if userInfo == nil {
            return
        }
        
        let key = userInfo!["key"]!
        
        for index in 0..<arr_movies.count {
            let movie = arr_movies[index]
            if !isDelete && key == movie.name {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
                if cell == nil {
                    break
                }
                
//                let progressView = cell!.contentView.viewWithTag(13) as! UIProgressView
//                let lab_mProgress = cell!.contentView.viewWithTag(14) as! UILabel
//                let lab_mUploadSpeed = cell!.contentView.viewWithTag(15) as! UILabel
                let btn_upload = cell!.contentView.viewWithTag(16) as! UIButton
                
                btn_upload.titleLabel!.text = "续传"
                btn_upload.backgroundColor = UIColor(red: 69.0/255.0, green: 143.0/255.0, blue: 232.0/255.0, alpha: 1.0)
                
                tips.disappearTipsInMainThread()
                
                break
            }
    }
    }
    
    // 检测网络
    func monitorNetworkStatus(notification: NSNotification) {
        let status: AFNetworkReachabilityStatus = AFNetworkReachabilityStatus(rawValue: Int((notification.userInfo!["status"] as! String))!)!
        switch status {
        case .NotReachable:
            self.networkStatus = .NotReachable
            let alertController = UIAlertController(title: nil, message: "网络不给力，请检测网络", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWWAN:
            self.networkStatus = AFNetworkReachabilityStatus.ReachableViaWWAN
            let alertController = UIAlertController(title: nil, message: "当前为非Wi-Fi网络下，将产生流量费用，确定继续上传?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction) -> Void in
                self.networkStatus = AFNetworkReachabilityStatus.ReachableViaWiFi
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        case .ReachableViaWiFi:
            self.networkStatus = AFNetworkReachabilityStatus.ReachableViaWiFi
        default:
            self.networkStatus = AFNetworkReachabilityStatus.Unknown
        }
    }
}
