//
//  YSMyFriend.swift
//  YISAI
//
//  Created by Yufate on 15/7/16.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyFriend: NSObject {
    
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var uid: String! // 用户ID
    var username: String! // 用户名
    var type: NSNumber! // 标识是否互相关注，0为否，1为是
    var role_type: Int! // 用户标识
    
    class func friendWithAttributes(attributes: NSDictionary) -> YSMyFriend {
        return YSMyFriend().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSMyFriend {
        
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        uid = attributes["uid"] as? String
        username = attributes["username"] as? String
        type = attributes["type"] as? NSNumber
        role_type = attributes["role_type"] as? Int
        
        return self
    }
   
    /** 获取用户关注或粉丝列表 */
    // fanType : 0 为粉丝列表，1为关注/互相关注列表
    class func fetchMyFindwork(fanType: Int, shouldCache: Bool, fuid: String, startIndex: Int, fetchNum: Int, resp block: (([YSMyFriend]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let action = fanType == 0 ? "userConcernList" : "userFanAndUserEachOtherConcernList"
        
        let cacheKey = uid + (fanType == 0 ? "userConcernList" : "userFanAndUserEachOtherConcernList") + "\(fanType)"
        
        let params = ["a", action, "uid", uid, "loginkey", loginkey, "fuid", fuid, "start", "\(startIndex)", "num", "\(fetchNum)"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/userConcern", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                
                let lstName = fanType == 0 ? "lst_user_concern" : "lst_user_fan_and_each_other_concern"
                
                let resp_lst_friend = data![lstName] as? [AnyObject]
                var lst_friend = [YSMyFriend]()
                
                if resp_lst_friend != nil {
                    for attributes in resp_lst_friend! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let friend = YSMyFriend.friendWithAttributes(attributes as! NSDictionary)
                        lst_friend.append(friend)
                    }
                }
                
                block(lst_friend, nil)
            })
        }, params: params)
    }
}
