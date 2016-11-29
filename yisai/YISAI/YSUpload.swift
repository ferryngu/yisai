//
//  YSUpload.swift
//  YISAI
//
//  Created by Yufate on 15/6/11.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSUpload: NSObject {
    
    /** 根据文件名获取上传凭证 */
    // type : 标志文件类型，0位图片，1为音频
    // status : 标志模块，0位作品，1为家庭动态，2为头像，3为其他
    // key : 文件名
    class func getTokenWithKey(type: Int, status: Int, key: String, respBlock block:((String!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/qiNiu", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            if block == nil {
                return
            }
            
            let resp = handler.content_jsonObj
            
            if resp == nil {
                block(nil, "网络不给力")
                return
            }
            
            let code = resp["code"] as? Int
            
            if code == nil {
                block(nil, "数据错误")
                return
            }
            
            var errorMsg: String? = nil
            switch code! {
            case 1:
                break
            case -1:
                errorMsg = "获取数据失败"
            case 9000, 9001, 9002, 9003, 2001:
                errorMsg = "参数错误"
            case 9004:
                reLogin()
                return
            case 1001:
                errorMsg = "上传文件不存在"
            default:
                errorMsg = "默认处理"
                break
            }
            if errorMsg != nil {
                block(nil, errorMsg)
                return
            }
            
            let data = resp["data"] as? NSDictionary
            if data == nil {
                block(nil, "数据错误")
                return
            }
            
            let token = data!["token"] as? String
            
            if token == nil {
                block(nil, "数据错误")
                return
            }
            
            block(token!, nil)
            
        }, params: ["a", "getUpTokenWithKeyAndType", "uid", uid, "loginkey", loginkey, "key", key, "type", "\(type)", "status", "\(status)"])
    }
}

class YSAvatar: NSObject {
    
    /** 增加或更新用户头像 */
    class func updateAvatar(userOrJT: Bool, fileName: String, respBlock block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let path = userOrJT ? "/user/avatar" : "/judgeTeacher/avatar"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                errorMsg = "操作失败"
            case 9000, 9001, 9002, 9003:
                errorMsg = "参数错误"
            case 9004:
                reLogin()
                return
            case 1001:
                errorMsg = "请上传头像"
            case 1002:
                errorMsg = "头像上传失败"
            default:
                break
            }
            if errorMsg != nil {
                block(errorMsg)
                return
            }
            
            let data = resp["data"] as? NSDictionary
            if data == nil {
                block("数据错误")
                return
            }
            
            block(nil)
            
        }, params: ["a", "update", "uid", uid, "loginkey", loginkey, "filename", fileName])
    }
}
