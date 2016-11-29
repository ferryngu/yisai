//
//  YSMessage.swift
//  YISAI
//
//  Created by Yufate on 15/7/10.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMessage: NSObject {
   
    var sender_username: String? // 发送方昵称
    var update_time: String! // 更新时间
    var send_time: String! // 发送时间
    var receive_status: NSNumber! // 接收状态，0为未接收，1为已接受
    var sender_avatar: String? // 发送方头像URL
    var sender_id: String! // 发送方（用户）ID
    var content: String! // 私信内容
    var dm_id: String! // 私信ID
    var send_status: String! // 发送状态，0为未发送，1为已发送，2为发送失败
    var receiver_id: String! // 接收方ID
    var receive_time: NSNumber! // 接收时间
    var role_type: String! // 角色标识，0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
    var level: String! // 级别
    var level_name: String! // 级别名称
    
    class func messageWithAttributes(attributes: NSDictionary) -> YSMessage {
        return YSMessage().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSMessage {
        
        sender_username = attributes["sender_username"] as? String
        update_time = attributes["update_time"] as? String
        send_time = attributes["send_time"] as? String
        receive_status = attributes["receive_status"] as? NSNumber
        sender_avatar = attributes["sender_avatar"] as? String
        sender_id = attributes["sender_id"] as? String
        content = attributes["content"] as? String
        dm_id = attributes["dm_id"] as? String
        send_status = attributes["send_status"] as? String
        receiver_id = attributes["receiver_id"] as? String
        receive_time = attributes["receive_time"] as? NSNumber
        role_type = attributes["role_type"] as? String
        level = attributes["level"] as? String
        level_name = attributes["level_name"] as? String
        
        return self
    }
    
    /** 用户私信列表 */
    class func getMsgList(shouldCache: Bool, start: Int, num: Int, resp block: (([YSMessage]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "listWithUid", "uid", uid, "loginkey", loginkey, "start", "0", "num", "99"] as [String]
        
        let cacheKey = "directMessage" + "listWithUid"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/directMessage", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
                if resp == nil {
                    block(nil, "网络不给力")
                    return
                }
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block(nil, "数据异常")
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
                case 1001, 1002:
                    errorMsg = "好友信息错误"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    return
                }
                
                let resp_lst_direct_message = data!["lst_direct_message"] as? [AnyObject]
                var lst_direct_message = [YSMessage]()
                
                if resp_lst_direct_message != nil {
                    for attribute in resp_lst_direct_message! {
                        if let tAttribute = attribute as? NSDictionary {
                            let message = YSMessage.messageWithAttributes(tAttribute)
                            lst_direct_message.append(message)
                        }
                    }
                    
                }
                
                block(lst_direct_message, nil)
            })
        }, params: params)
    }
    
    /** 用户个人私信 */
    class func getFuidMsg(fuid: String, start: Int, num: Int, resp block: (([YSMessage]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "listWithUidAndFuid", "uid", uid, "loginkey", loginkey, "fuid", fuid, "start", "0", "num", "99"] as [String]
        let cacheKey = uid + "directMessage" + "listWithUidAndFuid" + fuid
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/directMessage", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
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
                case -1, 0:
                    errorMsg = "获取数据失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "好友信息错误"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_lst_direct_message = data!["lst_direct_message"] as? [AnyObject]
                var lst_direct_message = [YSMessage]()
                
                if resp_lst_direct_message != nil {
                    for attribute in resp_lst_direct_message! {
                        if attribute as? NSDictionary == nil {
                            continue
                        }
                        let message = YSMessage.messageWithAttributes(attribute as! NSDictionary)
                        lst_direct_message.append(message)
                    }

                }
                
                block(lst_direct_message, nil)
            })
        }, params: params)
    }
    
    /** 发送私信 */
    class func sendMsg(content: String, fuid: String, respBlock block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "send", "uid", uid, "loginkey", loginkey, "fuid", fuid, "content", content] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/directMessage", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001, 1002:
                    errorMsg = "好友信息错误"
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
    
    /** 信息状态变更为已接受 */
    class func postReceived(content: String, fuid: String, respBlock block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "received", "uid", uid, "loginkey", loginkey, "fuid", fuid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/directMessage", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001, 1002:
                    errorMsg = "好友信息错误"
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
