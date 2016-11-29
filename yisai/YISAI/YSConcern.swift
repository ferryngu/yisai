//
//  YSConcern.swift
//  YISAI
//
//  Created by Yufate on 15/7/4.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum ConcernStatus: Int {
    case Add
    case Cancel
}

class YSConcern: NSObject {
   
    /** 关注接口 */
    class func concern(concernStatus: ConcernStatus, fuid: String, respBlock block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var action = ""
        if concernStatus == .Add {
            action = "addUserConcern"
        } else {
            action = "cancelUserConcern"
        }
        let params = ["a", action, "uid", uid, "loginkey", loginkey, "fuid", fuid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/userConcern", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                if resp == nil {
                    block("网络不给力")
                    return
                }
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block("数据错误")
                    return
                }
                
                var errorMsg: String? = nil
                switch code! {
                case 1:
                    break
                case -1, 0:
                    errorMsg = "获取数据失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 3002:
                    errorMsg = "关注信息有误"
                case 2001:
                    errorMsg = "不能关注自己"
                case 3001:
                    errorMsg = (concernStatus == .Add ? "已关注该用户" : "未关注该用户")
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(errorMsg!)
                    return
                }
                
                block(nil)
            })
        }, params: params)
    }
}
