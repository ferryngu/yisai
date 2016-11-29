//
//  YSRegister.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSRegister: NSObject {
    
    /** 获取验证码 */
    class func getVerifyNum(phoneNum pNum: String, role_type: String, finish_block block: ((String!, String!) -> Void)!) {
        
       // let path = "/user/register"
         let path = role_type == "1" ? "/user/register" : "/judgeTeacher/register"
        
        let params = ["a", "vcode", "phone", pNum, "role_type", role_type] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                if resp == nil {
                    block(nil, "数据异常")
                    return
                }
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block(nil, "数据异常")
                    return
                }
                
                if code == 1003 || code == 1004 {
                    block(nil, "手机号已使用")
                    return
                }
                if code == 5002 {
                    block(nil, "一个小时只能发三次")
                    return
                }
                if code == 5003 {
                    block(nil, "一分钟只能发一次")
                    return
                }
                if code == 5004 {
                    block(nil, "二十四个小时只能发十次")
                    return
                }
                if code != 1 {
                    let msg = resp["msg"] as? String
                    if msg == nil {
                        block(nil, "")
                        return
                    }
                    block(nil, msg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, "数据异常")
                    return
                }
                let vcode = data!["vcode"] as? String
                if vcode == nil {
                    block(nil, "数据异常")
                    return
                }
                block(vcode, nil)
            })
                
        }, params: params)
    }
    
    class func register(phoneNum pNum: String, password pwd: String, vcode: String, filename: String!, username: String, role_type: String, openID: String!, finish_block block: ((String!, String!, String!, String!) -> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
        let path = role_type == "1" ? "/user/register" : "/judgeTeacher/register"
        var params = ["a", "phone", "phone", pNum, "passwd", pwd, "vcode", vcode, "username", username] as [String]
        if filename != nil {
            params += ["filename", filename]
        }
        
        if openID != nil {
            params += ["openid", openID]
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
//                println(resp)
                
                if resp == nil {
                    return
                }
                
                let code = resp["code"] as? Int
                if code == nil {
                    return
                }
                
                var errorMsg: String? = nil
                switch code! {
                case 1:
                    break
                case -1:
                    errorMsg = "获取数据失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 1001:
                    errorMsg = "请填写手机号"
                case 1002:
                    errorMsg = "请填写正确的手机号"
                case 1003:
                    errorMsg = "手机号已存在"
                case 1004:
                    errorMsg = "手机号已存在"
                case 2001:
                    errorMsg = "请填写密码"
                case 2002:
                    errorMsg = "注册成功,登陆失败"
                case 2003:
                    errorMsg = "请设置密码为8到16位"
                case 3001:
                    errorMsg = "请填写验证码"
                case 3002:
                    errorMsg = "验证码不正确"
                case 4001:
                    errorMsg = "请设置头像"
                case 5001:
                    errorMsg = "请填写用户名"
                default:
                    break
                }
                if errorMsg != nil {
                    block(nil, nil, nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, nil, "数据异常")
                    return
                }
                
                let uid = data!["uid"] as? String
                let loginKey = data!["loginkey"] as? String
                let respRole_type = data!["role_type"] as? String
                
                if checkInputEmpty(uid) || checkInputEmpty(loginKey) || respRole_type == nil || checkInputEmpty(respRole_type) {
                    block(nil, nil, nil, "数据异常")
                    return
                }
                
                block(uid!, loginKey!, respRole_type!, nil)
            })
            
        }, params: params)
    }
}
