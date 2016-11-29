//
//  YSThanksViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/6.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSThanksViewController: UITableViewController, UMSocialUIDelegate {
    
    @IBOutlet weak var lab_also: UILabel!
    @IBOutlet weak var btn_resend: UIButton!
    
    var discoveryOrCompetition: Bool = false // 默认为发现发布作品
    var tips: FETips = FETips()
    var wid: String!
    var cpid: String!
    var shareImage: UIImage!
    var shareURL: String!
    var movieTitle: String!
    var matchName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        if wid != nil {
            shareURL = "http://www.eysai.com:8014/share/workDetail/workDetail.html?wid=\(wid)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resendToDiscover(sender: AnyObject) {
        
        if wid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: "正在发送中")
        
        YSPublish.resendToDiscovery(wid, resp: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            self!.tips.showTipsInMainThread(Text: "转发成功")
        })
    }
    
    @IBAction func shareToQQ(sender: AnyObject) {
        
        // 没有安装QQ
        if !QQApiInterface.isQQInstalled() {
            let alertView = UIAlertView(title: "温馨提示", message: "您的设备没有安装腾讯QQ", delegate: nil, cancelButtonTitle: "确定")
            UIApplication.sharedApplication().keyWindow?.addSubview(alertView)
            alertView.show()
            return
        }
        
        if shareImage == nil {
            tips.showTipsInMainThread(Text: "请设置分享图片")
        }
        
        var shareText = ""
        if discoveryOrCompetition {
            shareText = "大家好，我是“\(ysApplication.loginUser.nickName)”，我在易赛报名参加了“\(matchName)”，快来围观吧"
        } else {
            shareText = "我是“\(ysApplication.loginUser.nickName)” ，我表演的“\(movieTitle)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
        }

        UMSocialData.defaultData().extConfig.qqData.title = "【易赛】"
        UMSocialData.defaultData().extConfig.qqData.url = shareURL
        
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToQQ)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: shareImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToQQ)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    @IBAction func shareToWechat(sender: AnyObject) {
        
        var shareText = ""
        if discoveryOrCompetition {
            shareText = "大家好，我是“\(ysApplication.loginUser.nickName)”，我在易赛报名参加了“\(matchName)”，快来围观吧"
        } else {
            shareText = "我是“\(ysApplication.loginUser.nickName)” ，我表演的“\(movieTitle)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
        }
        
        UMSocialData.defaultData().extConfig.wechatSessionData.title = "【易赛】"
        UMSocialData.defaultData().extConfig.wechatSessionData.url = shareURL
    
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: shareImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    @IBAction func shareToTimeLine(sender: AnyObject) {
        
        var shareText = ""
        if discoveryOrCompetition {
            shareText = "大家好，我是“\(ysApplication.loginUser.nickName)”，我在易赛报名参加了“\(matchName)”，快来围观吧"
        } else {
            shareText = "我是“\(ysApplication.loginUser.nickName)” ，我表演的“\(movieTitle)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
        }
        
        UMSocialData.defaultData().extConfig.wechatTimelineData.title = "【易赛】"
        UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareURL
        
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatTimeline)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: shareImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatTimeline)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    @IBAction func shareToQZone(sender: AnyObject) {
        
        // 没有安装QQ
        if !QQApiInterface.isQQInstalled() {
            let alertView = UIAlertView(title: "温馨提示", message: "您的设备没有安装腾讯QQ", delegate: nil, cancelButtonTitle: "确定")
            UIApplication.sharedApplication().keyWindow?.addSubview(alertView)
            alertView.show()
            return
        }
        
        var shareText = ""
        if discoveryOrCompetition {
            shareText = "大家好，我是“\(ysApplication.loginUser.nickName)”，我在易赛报名参加了“\(matchName)”，快来围观吧"
        } else {
            shareText = "我是“\(ysApplication.loginUser.nickName)” ，我表演的“\(movieTitle)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
        }
        
        UMSocialData.defaultData().extConfig.qzoneData.title = "【易赛】"
        UMSocialData.defaultData().extConfig.qzoneData.url = shareURL
        
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToQzone)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: shareImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToQzone)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    @IBAction func shareToSina(sender: AnyObject) {
        
        var shareText = ""
        if discoveryOrCompetition {
            shareText = "大家好，我是“\(ysApplication.loginUser.nickName)”，我在易赛报名参加了“\(matchName)”，快来围观吧"
        } else {
            shareText = "我是“\(ysApplication.loginUser.nickName)” ，我表演的“\(movieTitle)”，在易赛上有好多朋友喜欢呢，你也来看看呗"
        }
        
        UMSocialData.defaultData().urlResource.url = shareURL
        
//        let platform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToSina)
        UMSocialControllerService.defaultControllerService().setShareText(shareText, shareImage: shareImage, socialUIDelegate: self)
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToSina)
        snsPlatform.snsClickHandler(self, UMSocialControllerService.defaultControllerService(), true)
    }
    
    @IBAction func tapBackItem(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if discoveryOrCompetition {
                return 100.0
            } else {
                lab_also.hidden = true
                btn_resend.hidden = true
                return 0.01
            }
        } else {
            return 240.0
        }
    }
    
    // MARK: - UMSocial Delegate
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        
//                if (response.responseCode == UMSResponseCode.UMSResponseCodeSuccess) {
//        
//                }
    }
}
