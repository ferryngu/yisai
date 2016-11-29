//
//  YSSettingViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/9.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSSettingViewController: UITableViewController {
    
    var tips: FETips = FETips()
    var commentConf: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        fetchCommentConf()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCommentConf() {
        
        YSConfigure.getWorkJudgeTeacherCommentStatus { [weak self] (resp_comment_conf: Int!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                return
            }
            
            self!.commentConf = resp_comment_conf
            self!.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            if ysApplication.loginUser == nil || ysApplication.loginUser.role_type == nil {
                return 0
            }
            
            return ysApplication.loginUser.role_type == "1" ? 3 : 2
        case 1:
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSSettingCell")

        // Configure the cell...
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                cell!.textLabel?.text = "清空已上传的视频文件(请谨慎操作)"
                cell!.textLabel?.textColor = UIColor.redColor()
            case 1:
                cell!.textLabel?.text = "清空缓存"
            case 2:
                cell!.textLabel?.text = "隐藏参赛评论"
                
                let swc = cell!.contentView.viewWithTag(11) as! UISwitch
                swc.hidden = false
                swc.setOn(commentConf == 0 ? true : false, animated: true)
                
                swc.addTarget(self, action: "changeCptComment:", forControlEvents: UIControlEvents.ValueChanged)
            default:
                break
            }
            
        case 1:
            
            if indexPath.row == 0 {
                cell!.textLabel?.text = "联系我们"
            } else {
                cell!.textLabel?.text = "关于易赛"
            }
        case 2:
            
            cell!.textLabel?.text = "意见反馈"
            
        default:
            
            cell!.textLabel?.text = "注销"
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                // 清理上传队列
                //                ysApplication.uploadQueue.removeAll(keepCapacity: true)
                // 清理数据库
                let movies = YSMovie.getUploadMoviesAboutUID()
                
                let fileManager = NSFileManager.defaultManager()
                let movieStorePath = NSHomeDirectory() + "/Documents/Movie"
                let recordStorePath = NSHomeDirectory() + "/Documents/Recorder"
//                var error: NSError?
                
                if movies != nil {
                    
                    for movie in movies! {
                        
                        if !checkInputEmpty(movie.name) && movie.progress > 0.99 {
                            
                            let moviePath = movieStorePath + movie.name
                            let recordPath = recordStorePath + movie.name
                            
                            if fileManager.fileExistsAtPath(moviePath) {
                                do {
                                    try fileManager.removeItemAtPath(moviePath)
                                }catch let error as NSError {
                                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                                    return
                                }

                            }
                            
                            if fileManager.fileExistsAtPath(recordPath) {
                                do {
                                    try fileManager.removeItemAtPath(recordPath)
                                }catch let error as NSError {
                                    CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                                    return
                                }

                            }
                        }
                    }
                }
                
                YSMovie.cleanAllUploadMoviesAboutUID()
                // 清理文件
                //                let fileManager = NSFileManager.defaultManager()
                //                let movieStorePath = NSHomeDirectory() + "/Documents/Movie"
                //                let recordStorePath = NSHomeDirectory() + "/Documents/Recorder"
                //                var error: NSError?
                tips.showTipsInMainThread(Text: "清理完毕")
            case 1:
                fe_clean_http_cache()
                tips.showTipsInMainThread(Text: "清理完毕")
            case 2:
//                tips.showTipsInMainThread(Text: "隐藏参赛评论")
                break
            default:
                break
            }
            
        case 1:
            
            switch indexPath.row {
            case 0:
                
                let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
                controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/contact/contact.html")
                self.navigationController?.pushViewController(controller, animated: true)
            default:
                
                let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
                controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/about/about.html")
                self.navigationController?.pushViewController(controller, animated: true)
                // http://120.25.237.16:8014/about/privacy_policy.html
            }
            
        case 2:
            
            let controller = UIStoryboard(name: "YSDiscovery", bundle: nil).instantiateViewControllerWithIdentifier("YSWebViewController") as! YSWebViewController
            controller.requestUrl = NSURL(string: "http://www.eysai.com:8014/feedback/feedback.html?uid=\(ysApplication.loginUser.uid)&loginkey=\(ysApplication.loginUser.loginKey)")
            self.navigationController?.pushViewController(controller, animated: true)
            
        default:
            
            tips.showTipsInMainThread(Text: "正在退出...")
            XGPush.unRegisterDevice()
            //            fe_clean_http_cache()
            ysApplication.loginUser.clean()
            YSUserOnline.updateOnlineTime(1)
            delayCall(1.0, block: { () -> Void in
                ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
            })
        }
    }
    
    // MARK: - Actions
    
    func changeCptComment(swc: UISwitch) {
        
        if swc.on {
            
            swc.enabled = false
            
            YSConfigure.setWorkJudgeTeacherCommentStatus(0, resp: { [weak self] (errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                self!.tips.showTipsInMainThread(Text: "已隐藏")
                
                swc.enabled = true
            })
            
        } else {
            
            swc.enabled = false
            
            YSConfigure.setWorkJudgeTeacherCommentStatus(1, resp: { [weak self] (errorMsg: String!) -> Void in
                
                if self == nil {
                    return
                }
                
                if errorMsg != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                    return
                }
                
                self!.tips.showTipsInMainThread(Text: "已关闭")
                
                swc.enabled = true
            })
        }
    }
}