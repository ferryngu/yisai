//
//  YSChildExperience.swift
//  YISAI
//
//  Created by Yufate on 15/6/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

/** 孩子个人经历 */
class YSChildExperience: NSObject {
   
    /** 获取孩子经历 */
    class func fetchChildExperience(shouldCache: Bool, startIndex: Int, num:Int, block: ((YSChildPersonalExperience!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "childCompetitionInfo" + "list"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childCompetitionInfo", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001, 1002, 2001:
                    errorMsg = "父母信息有误"
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
                
                let resp_obj_child_personal_experience = data!["obj_child_personal_experience"] as? NSDictionary
                if resp_obj_child_personal_experience == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let obj_child_personal_experience = YSChildPersonalExperience.personalExperienceWithAttributes(resp_obj_child_personal_experience!)
    
                
                block(obj_child_personal_experience, nil)
            })
            
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey, "start", "\(startIndex)", "num", "\(num)"])
    }
    
    /** 更新孩子个人简介 */
    class func confirmChildExperience(personal_profile: String, resp block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "add", "uid", uid, "loginkey", loginkey, "personal_profile", personal_profile] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childCompetitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
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
                case 1001, 1002, 2001:
                    errorMsg = "信息有误"
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
    
    /** 获取用户经历 */
    class func fetchUserExperience(fuid: String, startIndex: Int, num:Int, block: (([YSChildCompetitionInfo]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "listWithFuid", "uid", uid, "loginkey", loginkey, "fuid", fuid, "start", "\(startIndex)", "num", "\(num)"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childCompetitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003, 1001, 1002:
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
                    block(nil, "数据错误")
                    return
                }
                
                let resp_lst_child_competition_info = data!["lst_child_competition_info"] as? NSArray
                var lst_child_competition_info = [YSChildCompetitionInfo]()
                
                if resp_lst_child_competition_info != nil {
                    for attribute in resp_lst_child_competition_info! {
                        if attribute as? NSDictionary == nil {
                            continue
                        }
                        let competitionInfo = YSChildCompetitionInfo.competitionInfoWithAttributes(attribute as! NSDictionary)
                        lst_child_competition_info.append(competitionInfo)
                    }
                }
                
                block(lst_child_competition_info, nil)
            })
            
        }, params: params)
    }
}
/** （孩子）个人经历页数据 */
class YSChildPersonalExperience: NSObject {
    
    var personal_profile: String! // 个人简介
    var lst_child_competition_info: [YSChildCompetitionInfo]! // 个人经历列表
    var avatar: String! // 头像
    var realname: String! // 真实姓名
    var username: String! // 昵称
    var cid: String! // 孩子ID
    
    class func personalExperienceWithAttributes(attributes: NSDictionary) -> YSChildPersonalExperience {
        return YSChildPersonalExperience().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSChildPersonalExperience {
        
        personal_profile = attributes["personal_profile"] as? String
        
        lst_child_competition_info = [YSChildCompetitionInfo]()
        if attributes["lst_child_competition_info"] as? NSArray != nil {
            for attribute in attributes["lst_child_competition_info"] as! NSArray {
                if attribute as? NSDictionary == nil {
                    continue
                }
                let child_competition_info = YSChildCompetitionInfo.competitionInfoWithAttributes(attribute as! NSDictionary)
                lst_child_competition_info.append(child_competition_info)
            }
        }
        
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        username = attributes["username"] as? String
        cid = attributes["cid"] as? String
        
        return self
    }
}
/** 个人经历信息 */
class YSChildCompetitionInfo: NSObject {
    
    var update_time: String! // 更新时间
    var crid: String! // 赛事报名ID
    var work_title: String! // 赛事标题
    var ranking: NSNumber! // 名次，默认为0未获得名次
    var competition_name: String! // 赛事名称
    var rank_status: NSNumber! // 获奖状态
    var cid: String! // 孩子ID
    
    class func competitionInfoWithAttributes(attributes: NSDictionary) -> YSChildCompetitionInfo {
        return YSChildCompetitionInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSChildCompetitionInfo {
        
        update_time = attributes["update_time"] as? String
        crid = attributes["crid"] as? String
        work_title = attributes["work_title"] as? String
        ranking = attributes["ranking"] as? NSNumber
        competition_name = attributes["competition_name"] as? String
        cid = attributes["cid"] as? String
        rank_status = attributes["rank_status"] as? NSNumber
        
        return self
    }
}
