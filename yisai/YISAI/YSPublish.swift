//
//  YSPublish.swift
//  YISAI
//
//  Created by Yufate on 15/6/9.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSPublish: NSObject {
    
    class func getWorkCategory(respBlock block:(([YSWorkCategory]!, String!) -> Void)!) {
        
        var uid = ysApplication.loginUser.uid
        var loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil
        {
            uid = ""
        }
        if loginkey == nil
        {
            loginkey = ""
        }
        let cacheKey = "workCategory" + "list"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/workCategory", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
                    block(nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_lst_work_category = data!["lst_work_category"] as? [AnyObject]
                var lst_work_category = [YSWorkCategory]()
                if resp_lst_work_category != nil {
                    for attributes in resp_lst_work_category! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let workcategory = YSWorkCategory.workCategoryWithAttributes(attributes as! NSDictionary)
                        lst_work_category.append(workcategory)
                    }

                }
                
                block(lst_work_category, nil)
            })
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey])
    }
    
    /** 获取报名ID */
    class func getCridByCpid(cpid: String, respBlock block:((String!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionRegistration", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001, 1002, 1003:
                    errorMsg = "赛事信息错误"
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
                
                let crid = data!["crid"] as? String
                if crid == nil {
                    block(nil, "数据异常")
                    return
                }
                
                block(crid, nil)
            })
            
        }, params: ["a", "getCrid", "uid", uid, "loginkey", loginkey, "cpid", cpid])
    }
   
    /** 发布发现作品 */
    class func publishDiscoveryFindwork(wcid: String, title: String, fileName: String, respBlock block:((String!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/work", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
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
                case 9000, 9001, 3001, 3002:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 2001, 2002:
                    errorMsg = "请选择视频提交"
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
                
                let wid = data!["wid"] as? String
                if wid != nil {
                    block(wid, nil)
                }
            })
            
        }, params: ["a", "add", "uid", uid, "loginkey", loginkey, "wcid", wcid, "title", title, "file_name", fileName, "found_status", "1"])
    }
    
    /** 发布比赛作品 */
    class func publishCompetitonFindwork(title: String, file_name: String, teacher_name: String?, teacher_phone: String?, crid: String, resp block: ((String!, String!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var params = ["a", "addCompetitionWork", "uid", uid, "loginkey", loginkey, "title", title, "file_name", file_name, "crid", crid] as [String]
        
        if teacher_name != nil && teacher_phone != nil {
            params += ["teacher_name", teacher_name!, "teacher_phone", teacher_phone!]
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/work", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
                if resp == nil {
                    block(nil, nil, "网络不给力")
                    return
                }
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block(nil, nil, "数据错误")
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
                case 9002, 9003, 2002, 2003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 3001, 3002:
                    errorMsg = "赛事信息错误"
                case 4001:
                    errorMsg = "请填写作品标题"
                case 5001:
                    errorMsg = "请选择视频提交"
                case 7002:
                    errorMsg = "指导老师手机号有误"
                case 8001, 8002, 8003:
                    errorMsg = "作品信息有误"
                case 10001...10019, 11001...11004:
                    errorMsg = "发送信息到指导老师失败"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, "数据错误")
                    return
                }
                
                let crid = data!["crid"] as? String
                let wid = data!["wid"] as? String
                if crid != nil && wid != nil {
                    block(crid, wid, nil)
                }
            })
        }, params: params)
    }
    
    /** 发布比赛作品 */
    class func resendToDiscovery(wid: String, resp block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "updateFoundStatus", "uid", uid, "loginkey", loginkey, "wid", wid, "found_status", "1"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/work", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
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
                case 9002, 9003, 2002, 2003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "赛事信息错误"
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

class YSWorkCategory: NSObject {
    
    var wcid: String! // 作品分类ID
    var pid: String! // 父分类id，顶级分类父id是0
    var sort_number: NSNumber! // 排序字段
    var category_logo: String! // 分类logo地址
    var level: NSNumber! // 分类级别
    var update_time: NSNumber! // 该行记录插入或更新的时间
    var is_show: NSNumber! // 是否显示，1为显示，0为不显示
    var category_name: String! // 分类名称
    
    class func workCategoryWithAttributes(attributes: NSDictionary) -> YSWorkCategory {
        return YSWorkCategory().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSWorkCategory {
        
        wcid = attributes["wcid"] as? String
        pid = attributes["pid"] as? String
        sort_number = attributes["sort_number"] as? NSNumber
        category_logo = attributes["category_logo"] as? String
        level = attributes["level"] as? NSNumber
        update_time = attributes["update_time"] as? NSNumber
        is_show = attributes["is_show"] as? NSNumber
        category_name = attributes["category_name"] as? String
        
        return self
    }
}
