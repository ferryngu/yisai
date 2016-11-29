//
//  YSLogin.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSLogin: NSObject {

    class func loginWithPhone(role_type: String, phoneNum pNum: String, password passwd: String, finish_block block: ((String!, String!, String!, String!) -> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
       // let path = role_type == "1" ? "/user/login" : "/judgeTeacher/login"
        let path =  "/user/login"
        let params = ["a", "withPhone", "phone", pNum, "passwd", passwd, "role_type", role_type]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
               
                if resp == nil {
                    block(nil, nil, nil, "网络不给力")
                    return
                }
                 print(resp)
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
                    errorMsg = "手机号不存在"
                case 2001:
                    errorMsg = "请填写密码"
                case 2002:
                    errorMsg = "密码错误"
                default:
                    errorMsg = "默认处理"
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
                // role_type: 角色标识，0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
                let role_type = data!["role_type"] as? String
                
                if checkInputEmpty(uid) || checkInputEmpty(loginKey) || role_type == nil || checkInputEmpty(role_type) {
                    block(nil, nil, nil, "数据异常")
                    return
                }
                
                block(uid!, loginKey!, role_type!, nil)
            })
            
        }, params: params)
    }
    
    class func loginByWechat(role_type: String, openid: String, finish_block block: ((String!, String!, String!, String!) -> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
        let path = role_type == "1" ? "/user/login" : "/judgeTeacher/login"
        let params = ["a", "dologinWithWX", "openid", openid]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
              
                if resp == nil {
                    block(nil, nil, nil, "网络不给力")
                    return
                }
                  print(resp)
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
                case 1002:
                    errorMsg = "1002"
                case 1001, 1003, 1004:
                    errorMsg = "用户微信信息错误"
                default:
                    errorMsg = "默认处理"
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
                // role_type: 角色标识，0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
                let role_type = data!["role_type"] as? String
                
                if checkInputEmpty(uid) || checkInputEmpty(loginKey) || role_type == nil || checkInputEmpty(role_type) {
                    block(nil, nil, nil, "数据异常")
                    return
                }
                
                block(uid!, loginKey!, role_type!, nil)
            })
            
        }, params: params)
    }
    
    /** （普通用户）短信发送验证码及验证码入库/（评委/老师）短信发送验证码及验证码入库 */
    class func doVcode(phoneNum pNum: String, finish_block block: ((String!) -> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
      //  let path = role_type == "1" ? "/user/findPasswd" : "/judgeTeacher/findPasswd"
        
        let path = "/user/findPasswd"
        
        let params = ["a", "doVcodeNoRole", "phone", pNum]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                
                if resp == nil {
                    block("网络不给力")
                    return
                }
                print(resp)
                let code = resp["code"] as? Int
                if code == nil {
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
                case 1001:
                    errorMsg = "请填写手机号"
                case 1002:
                    errorMsg = "请填写正确的手机号"
                case 1003:
                    errorMsg = "手机号不存在"
                case 2001, 2002, 2003:
                    errorMsg = "验证码信息有误"
                case 2004:
                    errorMsg = "验证码发送失败"
                case 3001:
                    errorMsg = "验证码已发送"
                case 5002:
                    errorMsg =  "一个小时只能发三次"
                    
                    
                case 5003:
                    errorMsg =  "一分钟只能发一次"
                    
                    
                case 5004:
                    errorMsg =  "二十四个小时只能发十次"
                    
                    
                case 111000...111099, 111200...111224, 112300...112321, 160001...160010, 160011...160022, 112600...112727:
                    errorMsg = "验证码发送失败"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(errorMsg)
                    return
                }
                
                block(nil)
            })
            
        }, params: params)
    }
    
    /**（普通用户）设置新密码/（评委/老师）设置新密码 */
    class func resetPasswd(role_type: String, phoneNum pNum: String, password passwd: String, vCode vcode: String, finish_block block: ((String!) -> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
       // let path = role_type == "1" ? "/user/findPasswd" : "/judgeTeacher/findPasswd"
        let path = "/user/findPasswd"
        
        let params = ["a", "setPasswdNoRole", "phone", pNum, "vcode", vcode, "new_passwd", passwd]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                
                if resp == nil {
                    block("网络不给力")
                    return
                }
                print(resp)
                let code = resp["code"] as? Int
                if code == nil {
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
                case 1001:
                    errorMsg = "请填写手机号"
                case 1002:
                    errorMsg = "验证码不存在"
                case 1005:
                    errorMsg = "手机号码不存在"
                case 2001:
                    errorMsg = "请填写验证码"
                case 2002:
                    errorMsg = "验证码错误"
                case 2003:
                    errorMsg = "验证码已失效"
                case 2004:
                    errorMsg = "密码长度不在范围内"
                case 3001:
                    errorMsg = "请输入密码"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(errorMsg)
                    return
                }
                
                block(nil)
            })
            
        }, params: params)
    }
}

class YSUserOnline: NSObject {
    
    /** 更新（普通）用户在线时间接口 */
    // type = 标识字段，1为退出应用时，其他为未知
    class func updateOnlineTime(type: Int?) {
        
        if ysApplication.loginUser == nil {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/user/online"
        var params = ["a", "addUserOnlineTime", "uid", uid, "loginkey", loginkey] as [String]
        
        if type != nil && type == 1 {
            params += ["type", "\(type!)"]
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let resp = handler.content_jsonObj
                
                
                if resp == nil {
                    return
                }
                print(resp)
                let code = resp["code"] as? Int
                if code == nil {
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
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    return
                }
            })
            
        }, params: params)
    }
}
