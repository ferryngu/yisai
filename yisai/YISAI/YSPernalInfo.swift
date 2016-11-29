//
//  YSPernalInfo.swift
//  YISAI
//
//  Created by Yufate on 15/6/10.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSUserHomePage: NSObject {
    
    /** 我（用户）个人主页数据 */
    class func getMyHomePageInfo(role_type: String, resp block: ((YSUserInfo!, String!)-> Void)!) {
        
        // 用户接用户接口，评委老师接评委老师接口
        let path = role_type == "1" ? "/user" : "/judgeTeacher"
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "myHomePage", "uid", uid, "loginkey", loginkey] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9002, 9003, 1001, 1002, 1003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
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
                    block(nil, "数据异常")
                    return
                }
                let obj_user = data![(role_type == "1" ? "obj_user" : "obj_judge_teacher")] as? NSDictionary
                if obj_user == nil {
                    block(nil, "数据异常")
                    return
                }
                
                let userInfo = YSUserInfo.userInfoWithAttributes(obj_user!)
                block(userInfo, nil)
            })
            
        }, params: params)
    }
    
    /** 用户的个人主页数据 */
    class func getUserHomePageInfo(fuid: String, resp block: ((YSUserInfo!, [YSDiscoveryMainFindWork]!, NSNumber!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "homePage", "uid", uid, "loginkey", loginkey, "fuid", fuid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/user", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                if resp == nil {
                    block(nil, nil, nil, "网络不给力")
                    return
                }
                
                let code = resp["code"] as? Int
                if code == nil {
                    block(nil, nil, nil, "数据错误")
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
                case 9002, 9003, 1001, 1002, 1003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(nil, nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, nil, "数据错误")
                    return
                }
                
                let obj_user = data!["obj_user"] as? NSDictionary
                if obj_user == nil {
                    block(nil, nil, nil, "数据错误")
                    return
                }
                
                let userInfo = YSUserInfo.userInfoWithAttributes(obj_user!)
                
                let resp_lst_work = data!["lst_work"] as? NSArray
                var lst_work = [YSDiscoveryMainFindWork]()
                for attribute in resp_lst_work! {
                    if attribute as? NSDictionary == nil {
                        return
                    }
                    let work = YSDiscoveryMainFindWork.findworkWithAttributes(attribute as! NSDictionary)
                    lst_work.append(work)
                }
                
                let work_count = ((data!["work_count"] as? NSNumber == nil) ? 0 : data!["work_count"] as! NSNumber)
                
                block(userInfo, lst_work, work_count, nil)
            })
            
        }, params: params)
    }
}

class YSPernalInfo: NSObject {
    
    var phone: String! // 手机号
    var avatar: String! // 头像地址
    var sex: String! // 性别
    var realname: String! // 真实姓名
    var birth: String! // 出生日期
    var username: String! // 昵称
    var identity_card: String! // 身份证号码
    var region: String! // 身份证所属地区
    
    class func pernalInfoWithAttributes(attributes: NSDictionary) -> YSPernalInfo {
        return YSPernalInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSPernalInfo {
        
        phone = attributes["phone"] as? String
        avatar = attributes["avatar"] as? String
        sex = attributes["sex"] as? String
        realname = attributes["realname"] as? String
        birth = attributes["birth"] as? String
        username = attributes["username"] as? String
        identity_card = attributes["identity_card"] as? String
        region = attributes["region"] as? String
        
        return self
    }
    
    /** 获取用户信息 */
    // 用户: true, 评委/老师: false
    class func getUserInfo(userOrJT: Bool, resp block: ((YSPernalInfo!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let path = userOrJT ? "/user/info" : "/judgeTeacher/info"
        let dic = ["action" : "getAll", "uid" : uid, "loginkey" : loginkey]
        
//        let jsonData = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var jsonData = NSData()
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
        }catch let error as NSError {
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            return
        }

        
        
        
        var jsonString: String? = nil
        if jsonData.length > 0 {
            jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case -1:
                    errorMsg = "获取数据失败"
                case 9000, 9001, 9002:
                    errorMsg = "参数错误"
                case 9003, 9004, 9005:
                    errorMsg = "用户信息错误"
                case 9006, 9007:
                    reLogin()
                    return
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
                
                let personlInfo = YSPernalInfo.pernalInfoWithAttributes(data!)
                
                block(personlInfo, nil)
            })
            
        }, params: ["data", jsonString!])
    }
    
    /** 更新用户信息 */
    // 用户: true, 评委/老师: false
    class func updatePersonalInfo(userOrJT: Bool, personalInfo: YSPernalInfo, resp block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let path = userOrJT ? "/user/info" : "/judgeTeacher/info"
        
        var dic: Dictionary<String, String!>? = nil
        
        if userOrJT {
            
            dic = ["action" : "updateAll", "uid" : uid, "loginkey" : loginkey, "username" : personalInfo.username, "realname" : personalInfo.realname, "sex" : personalInfo.sex, "birth" : personalInfo.birth, "identity_card": personalInfo.identity_card, "region": personalInfo.region]
        } else {
            
            dic = ["action" : "updateAll", "uid" : uid, "loginkey" : loginkey, "username" : personalInfo.username, "realname" : personalInfo.realname, "sex" : personalInfo.sex, "birth" : personalInfo.birth]
        }
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dic!, options: NSJSONWritingOptions.PrettyPrinted)
        var jsonString: String? = nil
        if jsonData.length > 0 {
            jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
        }
        
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
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block("数据错误")
                    return
                }
                
                var errorMsg: String? = nil
                switch code! {
                case 1:
                    break
                case -1:
                    errorMsg = "获取数据失败"
                case 9000, 9001, 9002:
                    errorMsg = "参数错误"
                case 9003, 9004, 9005:
                    errorMsg = "用户信息错误"
                case 9006, 9007:
                    reLogin()
                    return
                case 9004:
                    reLogin()
                    return
                case 1001:
                    errorMsg = "请输入用户名"
                case 1002:
                    errorMsg = "用户名必须是中文、数字或字母"
                case 2001:
                    errorMsg = "请输入姓名"
                case 2002:
                    errorMsg = "姓名必须是中文、数字或字母"
                case 3001:
                    errorMsg = "请输入性别"
                case 3002:
                    errorMsg = "性别信息有误，请重新填写"
                case 4001:
                    errorMsg = "请输入生日信息"
                case 4002:
                    errorMsg = "生日信息有误，请重新填写"
                case 5001:
                    errorMsg = "请填写身份证号"
                case 5002:
                    errorMsg = "身份证号格式有误"
                case 6001:
                    errorMsg = "请填写联系地址"
                case 6002:
                    errorMsg = "联系地址填写格式不正确"
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
            
        }, params: ["data", jsonString!])
    }
}

/** 用户个人主页数据 */
class YSUserInfo: NSObject {
    
    var integral_quantity: NSNumber? // 积分值
    var level_name: String! // 等级称号
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var uid: String! // 用户ID
    var fuid: String! // 用户ID
    var level: NSNumber! // 级别
    var username: String! // 用户名
    var user_concern_status: NSNumber! // 标识是否关注，0为否，1为是
    var role_type: NSNumber! // 角色类型，0为评委，1为老师，2为评委/老师
    var region: String! // 城市
    var count_user_fan: String! // 粉丝数
    var count_user_concern: String! // 关注数
    
    class func userInfoWithAttributes(attributes: NSDictionary) -> YSUserInfo {
        return YSUserInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSUserInfo {
        
        integral_quantity = attributes["integral_quantity"] as? NSNumber
        level_name = attributes["level_name"] as? String
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        uid = attributes["uid"] as? String
        fuid = attributes["fuid"] as? String
        level = attributes["level"] as? NSNumber
        username = attributes["username"] as? String
        user_concern_status = attributes["user_concern_status"] as? NSNumber
        role_type = attributes["role_type"] as? NSNumber
        region = attributes["region"] as? String
        count_user_fan = attributes["count_user_fan"] as? String
        count_user_concern = attributes["count_user_concern"] as? String
        
        return self
    }
}
