//
//  YSCompetition.swift
//  YISAI
//
//  Created by Yufate on 15/6/19.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetition: NSObject {
   
    /** 获取比赛列表 */
    class func getMainCompetitionInfo(shouldCache: Bool, wcid: String!, type: Int!, startIndex: Int!, fetchNum: Int!, resp block: (([YSMainCompetitionInfo]!, String!)-> Void)!) {
        
        // 传空参数，则默认取记录开始位置为0，获取行数为20
        var start: Int = 0
        var num: Int = 0
        if startIndex == nil {
            start = 0
        } else {
            start = startIndex
        }
        if fetchNum == nil || fetchNum == 0 {
            num = 20
        } else {
            num = fetchNum
        }
        
        var uid = ysApplication.loginUser.uid
        var loginkey = ysApplication.loginUser.loginKey
        
        var apiAction: String? = nil
        if wcid == nil {
            
            apiAction = "list"
            
        } else {
            
            if type == nil {
                apiAction = "listWithWcid"
            } else {
                apiAction = "listWithWcidAndType"
            }
        }
        
        if uid == nil
        {
            uid = ""
        }
        if loginkey == nil
        {
            loginkey = ""
        }
        
        var params = ["a", apiAction!, "uid", uid, "loginkey", loginkey, "start", "\(start)", "num", "\(num)"] as [String]
        if wcid != nil {
            params += ["wcid", wcid]
        }
        if type != nil {
            params += ["type", "\(type)"]
        }
        
//        let cacheKey = "competitionInfo" + apiAction! + "\(wcid)" + "type" + "\(type)"
        
        // shouldCache ? cacheKey : nil
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case -1, 0:
                    errorMsg = "获取数据失败"
                case 9000, 9001, 1001, 1002, 2001:
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
                
                let lst_competition_info = data!["lst_competition_info"] as? [AnyObject]
                var resp_lst_findwork = [YSMainCompetitionInfo]()
                
                if lst_competition_info != nil {
                    
                    for attributes in lst_competition_info! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let competition_info = YSMainCompetitionInfo.competitionInfoWithAttributes(attributes as! NSDictionary)
                        resp_lst_findwork.append(competition_info)
                    }

                }
           
                block(resp_lst_findwork, nil)
            })
        }, params: params)
    }
    
    /** 获取赛事详情 */
    class func getCompetitionDetail(cpid: String, resp block: ((YSCompetitionDetail!, String!)-> Void)!) {
        
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
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        let params = ["a", "detail", "uid", uid, "loginkey", loginkey, "cpid", cpid,"version",version] as [String]
        
        let cacheKey = "competitionInfo" + "detail" + cpid + uid
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                if resp == nil {
                    block(nil,"网络不给力")
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
                case 9002, 9003, 4001, 4002:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002:
                    errorMsg = "赛事信息错误"
                case 3001, 3002:
                    errorMsg = "主办方信息错误"
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
                
                let obj_competition_info = data!["obj_competition_info"] as? NSDictionary
                if obj_competition_info == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_competition_info = YSCompetitionDetail.competitionInfoWithAttributes(obj_competition_info!)

                
                block(resp_competition_info, nil)

            })
        }, params: params)
    }
    
    /** 获取学生信息 */
    class func getStudentInfo(phone: String, resp block: ((YSStudentInfo!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
 
        
        let params = ["a", "phone", "uid", uid, "loginkey", loginkey, "phone", phone] as [String]
        
       
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
                if resp == nil {
                //    block(nil, nil)
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
                case 9002, 9003, 4001, 4002:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002:
                    errorMsg = "赛事信息错误"
                case 3001, 3002:
                    errorMsg = "主办方信息错误"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                 //   block(nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                
                if data == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let obj_competition_info = data!["childInfo"] as? NSDictionary
                if obj_competition_info == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_competition_info = YSStudentInfo.competitionInfoWithAttributes(obj_competition_info!)
                
                
                block(resp_competition_info, nil)
                
            })
            }, params: params)

        
    }
    /** 获取比赛报名详情 */
    class func getConfirmDetail(cpid: String, resp block: ((YSCompetitionConfirmInfo!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "registrationConfirmationPage", "uid", uid, "loginkey", loginkey, "cpid", cpid] as [String]
        let cacheKey = uid + "competitionInfo" + "registrationConfirmationPage"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9002, 9003, 4001, 4002:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002:
                    errorMsg = "赛事信息错误"
                case 3001, 3002:
                    errorMsg = "主办方信息错误"
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
                
                let obj_competition_info = data!["obj_competition_info"] as? NSDictionary
                if obj_competition_info == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_competition_info = YSCompetitionConfirmInfo.confirmInfoWithAttributes(obj_competition_info!)

                
                block(resp_competition_info, nil)
                
            })
        }, params: params)
    }
    
    /** 报名确认页点击"提交"按钮 */
    class func confirmRegistration(cpid: String, cgid: String?, realname: String, phone: String, birth: String, identity_card: String, region: String, institution: String!, tch_name: String, tch_phone: String,version: String, resp block: ((String!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var condision = "add"
        
        if ysApplication.loginUser.role_type == "1"
        {
            condision = "add"
          
        }
        else
        {
          condision = "addByTeacher"
        }
        
        var params = ["a", condision, "uid", uid, "loginkey", loginkey, "cpid", cpid, "realname", realname, "phone", phone, "birth", birth, "identity_card", identity_card, "region", region,  "version", version] as [String]
        
        if cgid != nil {
            params += ["cgid", cgid!]
        }
        
        if institution != nil {
            params += ["school_institution", institution]
        }
        
        if ysApplication.loginUser.role_type == "1"
        {
            params += ["teacher_name",tch_name, "teacher_phone", tch_phone]
        }
        
        
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
                case 9002, 9003, 2002, 2003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "赛事信息错误"
                case 2004, 2005:
                    errorMsg = "用户信息更新失败"
                case 3001:
                    errorMsg = "你已报名了该赛事"
                case 4001, 4002:
                    errorMsg = "组别信息错误"
                case 5001, 5002:
                    errorMsg = "用户年龄不符合赛事的要求"
                case 6001:
                    errorMsg = "请选择要参加的赛事"
                case 7001:
                    errorMsg = "请填写生日信息"
                case 8001:
                    errorMsg = "手机号错误或没填写"
                case 10001:
                    errorMsg = "身份证号错误或没填写"
                case 10002:
                    errorMsg = "身份证格式错误"
                case 11001:
                    errorMsg = "请填写的联系地址"
                case 11002:
                    errorMsg = "联系地址信息有误"
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
                
                let crid = data!["crid"] as? String
                
                if crid == nil {
                    block(nil, "数据错误")
                    return
                }
                
                block(crid, nil)
                
            })
        }, params: params)
    }
    
    /** 老师报名确认页点击"提交"按钮 */
    class func confirmRegistrationTch(cpid: String, cid: String?, cgid: String?, realname: String, phone: String, birth: String, identity_card: String, region: String, institution: String!, tch_name: String, tch_phone: String,version: String, resp block: ((String!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var params = ["a", "addByTeacher", "uid", uid, "loginkey", loginkey, "cpid", cpid, "realname", realname, "phone", phone, "birth", birth, "identity_card", identity_card, "region", region, "teacher_name", tch_name, "teacher_phone", tch_phone, "version", version] as [String]
        
        if cgid != nil {
            params += ["cgid", cgid!]
        }
        
        if institution != nil {
            params += ["school_institution", institution]
        }
        
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
                case 9002, 9003, 2002, 2003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "赛事信息错误"
                case 2004, 2005:
                    errorMsg = "用户信息更新失败"
                case 3001:
                    errorMsg = "你已报名了该赛事"
                case 4001, 4002:
                    errorMsg = "组别信息错误"
                case 5001, 5002:
                    errorMsg = "用户年龄不符合赛事的要求"
                case 6001:
                    errorMsg = "请选择要参加的赛事"
                case 7001:
                    errorMsg = "请填写生日信息"
                case 7005:
                    errorMsg = "不能帮老师报名"
                case 8001:
                    errorMsg = "手机号错误或没填写"
                case 10001:
                    errorMsg = "身份证号错误或没填写"
                case 10002:
                    errorMsg = "身份证格式错误"
                case 11001:
                    errorMsg = "请填写的联系地址"
                case 11002:
                    errorMsg = "联系地址信息有误"
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
                
                let crid = data!["crid"] as? String
                
                if crid == nil {
                    block(nil, "数据错误")
                    return
                }
                
                block(crid, nil)
                
            })
            }, params: params)
    }
    
    /** 参加过的比赛页接口 */
    class func getParticipatedCompetitionInfo(shouldCache: Bool, startIndex: Int!, fetchNum: Int!, resp block: (([YSCompetitionJoinedInfo]!, String!)-> Void)!) {
        
        // 传空参数，则默认取记录开始位置为0，获取行数为20
        var start: Int = 0
        var num: Int = 0
        if startIndex == nil {
            start = 0
        } else {
            start = startIndex
        }
        if fetchNum == nil || fetchNum == 0 {
            num = 20
        } else {
            num = fetchNum
        }
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "participatedCompetition", "uid", uid, "loginkey", loginkey, "start", "\(start)", "num", "\(num)"] as [String]
        
        let cacheKey = "competitionInfo" + "participatedCompetition"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001, 1001, 1002, 2001:
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
                
                let lst_competition_info = data!["lst_competition_info"] as? [AnyObject]
                var resp_lst_competition = [YSCompetitionJoinedInfo]()
                if lst_competition_info != nil {
                    for attributes in lst_competition_info! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let joinedInfo = YSCompetitionJoinedInfo.joinedInfoWithAttributes(attributes as! NSDictionary)
                        resp_lst_competition.append(joinedInfo)
                    }

                }
                
                block(resp_lst_competition, nil)
            })
        }, params: params)
    }
    
    /** 赛事排名列表 */
    class func getRankInfo(shouldCache: Bool, cpid: String, cgid: String?, startIndex: Int, fetchNum: Int, resp block: (([YSCompetitionRankInfo]!, [YSCompetitionGroupInfo]!, YSCompetitionRankInfo!, Int!, Int!, String!)-> Void)!) {
        
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
        
        
        var params = ["a", "competitionRank", "uid", uid, "loginkey", loginkey, "start", "\(startIndex)", "num", "\(fetchNum)", "cpid", cpid] as [String]
        if cgid != nil {
            params += ["cgid", cgid!]
        }
//        if wcid != nil {
//            params += ["wcid", wcid!]
//        }
        
        let cacheKey = uid + "competitionInfo" + "competitionInfo" + cpid + (cgid == nil ? "" : cgid!)
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
                if resp == nil {
                    block(nil, nil, nil, nil, nil, "网络不给力")
                    return
                }
                
                let code = resp["code"] as? Int
                
                if code == nil {
                    block(nil, nil, nil, nil, nil, "数据错误")
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
                    block(nil, nil, nil, nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, nil, nil, nil, "数据错误")
                    return
                }
                
                let resp_status = data!["status"] as? Int
                let resp_lst_competition_rank = data!["lst_competition_rank"] as? [AnyObject]
                let resp_lst_competition_group = data!["lst_competition_group"] as? [AnyObject]
                let resp_user_comptition_rank = data!["obj_user_comptition_rank"] as? NSDictionary
                let resp_user_comptition_rank_status = data!["user_comptition_rank_status"] as? Int
                
                if resp_status == nil || resp_lst_competition_rank == nil || resp_lst_competition_group == nil || resp_user_comptition_rank == nil || resp_user_comptition_rank_status == nil {
                    block(nil, nil, nil, nil, nil, "数据错误")
                    return
                }
                
                var lst_competition_rank = [YSCompetitionRankInfo]()
                var lst_competition_group = [YSCompetitionGroupInfo]()
                let user_competition_rank = YSCompetitionRankInfo.rankInfoWithAttributes(resp_user_comptition_rank!)
                
                for attributes in resp_lst_competition_rank! {
                    if attributes as? NSDictionary == nil {
                        continue
                    }
                    
                    let rankInfo = YSCompetitionRankInfo.rankInfoWithAttributes(attributes as! NSDictionary)
                    lst_competition_rank.append(rankInfo)
                }
                for attributes in resp_lst_competition_group! {
                    if attributes as? NSDictionary == nil {
                        continue
                    }
                    
                    let groupInfo = YSCompetitionGroupInfo.groupInfoWithAttributes(attributes as! NSDictionary)
                    lst_competition_group.append(groupInfo)
                }
                
                block(lst_competition_rank, lst_competition_group, user_competition_rank, resp_status, resp_user_comptition_rank_status, nil)
            })
        }, params: params)
    }
    
    /** 评分作品列表页 */
    class func getMarkingFindworkInfo(resp block: (([YSMarkingCompetitionInfo]!, String!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "scoreList", "uid", uid, "loginkey", loginkey] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    block(nil, nil, "数据异常")
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
                case 9002, 9003, 1002:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 2001:
                    errorMsg = "暂未加入主办方"
                case 2002:
                    errorMsg = "没有需要评分的赛事"
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
                    block(nil, nil, "数据异常")
                    return
                }
                
                var lst_marking_info = [YSMarkingCompetitionInfo]()
                let resp_lst_marking_info = data!["lst_work"] as? [AnyObject]
                if resp_lst_marking_info != nil {
                    for attributes in resp_lst_marking_info! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let markingInfo = YSMarkingCompetitionInfo.markingInfoWithAttributes(attributes as! NSDictionary)
                        lst_marking_info.append(markingInfo)
                    }
                }
                
                var scoring_criteria = data!["scoring_criteria"] as? String
                
                if scoring_criteria == nil {
                    scoring_criteria = ""
                }
                
                block(lst_marking_info, scoring_criteria, nil)
            })
        }, params: params)
    }
    
    /** 作品评分详情页 */
    class func getMarkingDetailInfo(crid: String, resp block: ((YSMarkingCompetitionInfo!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "competitionScorePage", "uid", uid, "loginkey", loginkey, "crid", crid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
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
                case 1001...1008:
                    errorMsg = "该作品信息有误"
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
                
                let resp_obj_work = data!["obj_work"] as? NSDictionary
                if resp_obj_work == nil {
                    block(nil, "数据异常")
                    return
                }
                
                let obj_work = YSMarkingCompetitionInfo.markingInfoWithAttributes(resp_obj_work!)
                block(obj_work, nil)
            })
        }, params: params)
    }
    
    /** 作品评分详情页，点击"提交"按钮 */
    class func confirmFindworkScore(crid: String, point: String, content: String, resp block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "add", "uid", uid, "loginkey", loginkey, "crid", crid, "point", point, "content", content] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/competitionScore", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
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
                    block("数据异常")
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
                case 1001, 1002, 1004, 1005:
                    errorMsg = "作品信息错误"
                case 1003:
                    errorMsg = "该作品已评分"
                case 2001:
                    errorMsg = "请填写评分内容"
                case 3001:
                    errorMsg = "评分分数为0~100分"
                default:
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
    
    /** 导出（孩子）个人经历页PDF */
    class func fetchExperience(resp block: ((String!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "exportPDF", "uid", uid, "loginkey", loginkey] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childCompetitionInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
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
                    errorMsg = "获奖信息错误"
                case 1003:
                    errorMsg = "该作品已评分"
                default:
                    break
                }
                if errorMsg != nil {
                    block(nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, "数据异常")
                    return
                }
                
                
                
                let pdf_url = data!["pdf_url"] as? String
                if pdf_url == nil {
                    block(nil, "数据异常")
                    return
                }
                
                block(pdf_url!, nil)
                

            })
        }, params: params)
    }
    
    /** 导出孩子列表*/
    class func getstudentlist(cpid: String,resp block: (([YSStudentCompetitionInfo]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "stuList", "uid", uid, "loginkey", loginkey,"cpid", cpid,"num", "200"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/student", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
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
                    errorMsg = "获奖信息错误"
                case 1003:
                    errorMsg = "该作品已评分"
                default:
                    break
                }
                if errorMsg != nil {
                    block(nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, "数据异常")
                    return
                }
                
                let resp_lst_competition_rank = data!["lst_student"] as? [AnyObject]
                var list_student =  [YSStudentCompetitionInfo]()
                
                for attributes in resp_lst_competition_rank! {
                    if attributes as? NSDictionary == nil {
                        continue
                    }
                    let obj_work = YSStudentCompetitionInfo.markingInfoWithAttributes(attributes as! NSDictionary)
                      list_student.append(obj_work)
                }
                
                
                block(list_student, nil)
            })
            }, params: params)
    }

}



/** 比赛首页列表信息 */
class YSStudentInfo: NSObject {
    
    var cid: String! // 赛事ID
    var uid: String! // 赛事名
    var realname: String! // 赛事开始时间
    var birth: String! // 视频URL
    var region: String! // 作品ID
    var school_institution: String! // 注册人数
    var identity_card: String! // 注册人数
    
    class func competitionInfoWithAttributes(attributes: NSDictionary) -> YSStudentInfo {
        return YSStudentInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSStudentInfo {
        
        cid = attributes["cid"] as? String
        uid = attributes["uid"] as? String
        realname = attributes["realname"] as? String
        birth = attributes["birth"] as? String
        region = attributes["region"] as? String
        school_institution = attributes["school_institution"] as? String
        identity_card =  attributes["identity_card"] as? String
        
        return self
    }
}



/** 比赛首页列表信息 */
class YSMainCompetitionInfo: NSObject {
    
    var cpid: String! // 赛事ID
    var match_name: String! // 赛事名
    var start_time: String! // 赛事开始时间
    var last_time: String! // 视频URL
    var cover_plan: String! // 作品ID
    var register_number: NSNumber! // 注册人数
    var registration_time_end: String! // 赛事报名结束时间
    var judge_score_time_begin: String! // 赛事报名结束时间
    var judge_score_time_end: String! // 赛事评分结束时间
    var registration_time_begin: String! // 赛事报名开始时间
    var competition_process: String! // 赛事进行状态，0为赛事尚未开始，1为赛事报名阶段，2为赛事评分阶段，3为赛事结束
    
    class func competitionInfoWithAttributes(attributes: NSDictionary) -> YSMainCompetitionInfo {
        return YSMainCompetitionInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSMainCompetitionInfo {
        
        cpid = attributes["cpid"] as? String
        match_name = attributes["match_name"] as? String
        start_time = attributes["start_time"] as? String
        last_time = attributes["last_time"] as? String
        cover_plan = attributes["cover_plan"] as? String
        register_number = attributes["register_number"] as? NSNumber
        registration_time_end = attributes["registration_time_end"] as? String
        judge_score_time_begin = attributes["judge_score_time_begin"] as? String
        judge_score_time_end = attributes["judge_score_time_end"] as? String
        registration_time_begin = attributes["registration_time_begin"] as? String
        competition_process = attributes["competition_process"] as? String
        
        return self
    }
}

/** 赛事详情 */
class YSCompetitionDetail: NSObject {
    
    var application_fee: String! // 报名费
    var institution_name: String! // 主办方名称
    var register_number: NSNumber! // 报名人数
    var constitution_introduction: String! // 章程介绍
    var match_name: String! // 赛事名称
    var last_time: String! // 赛事结束时间
    var lst_competition_judge: [YSCompetitionJudge]! // 赛事评委列表
    var lst_publicity_pic: [String]! // 宣传图列表（最多6张）
    var biggest_age: String! // 参赛者最大年龄
    var payment_type: String! // 是否需付报名费，0为否，1为是
    var institution_logo: String! // 主办方LOGO URL
    var cpid: String! // 赛事ID
    var start_time: String! // 赛事开始时间
    var smallest_age: String! // 参赛者最小年龄
    var iid: String! // 主办方ID
    var competition_rules: String! // 赛事规则
    var competition_process: NSNumber! // 赛事进行状态，0为赛事尚未开始，1为赛事报名阶段，2为赛事评分阶段，3为赛事结束
    var user_competing_process: NSNumber! // 参赛流程，0为未支付，1为报名成功，2为已提交参赛视频，3为已提交参赛作品资料，其他为未知
    var user_competing_status: NSNumber! // 标识用户是否报名了该赛事，0为否，1为是
    var registration_time_begin: String! // 赛事报名开始时间
    var registration_time_end: String! // 赛事报名结束时间
    var judge_score_time_begin: String! // 赛事评分开始时间
    var judge_score_time_end: String! // 赛事评分结束时间
    var judge_competition_status: NSNumber! // 标识该用户是否为该赛事的评委，0为否，1为是
    var wcid: String! // 赛事分类ID
    var competition_type: String! // 标识赛事类型，0为线上赛事，1为线下赛事
    
    var user_pay_status: NSNumber! //用户支付状态，0为未支付，
    var user_upload_status: NSNumber! // 用户上传状态，0为已提交资料，未提交视频
    var benefit_price: String! // 优惠金额
    var pay_amount: String! // 优惠金额
    
    
    
    class func competitionInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionDetail {
        return YSCompetitionDetail().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionDetail {
        
        application_fee = attributes["application_fee"] as? String
        institution_name = attributes["institution_name"] as? String
        register_number = attributes["register_number"] as? NSNumber
        constitution_introduction = attributes["constitution_introduction"] as? String
        match_name = attributes["match_name"] as? String
        last_time = attributes["last_time"] as? String
        
        lst_competition_judge = [YSCompetitionJudge]()
        if attributes["lst_competition_judge"] as? NSArray != nil {
            for attribute in attributes["lst_competition_judge"] as! NSArray {
                if attribute as? NSDictionary == nil {
                    continue
                }
                let judge = YSCompetitionJudge.competitionJudgeWithAttributes(attribute as! NSDictionary)
                lst_competition_judge.append(judge)
            }
        }
        
        lst_publicity_pic = [String]()
        if attributes["lst_publicity_pic"] as? NSArray != nil {
            for attribute in attributes["lst_publicity_pic"] as! NSArray {
                let publicity_pic = attribute as? String
                if publicity_pic == nil {
                    continue
                }
                lst_publicity_pic.append(publicity_pic!)
            }
        }
        
        biggest_age = attributes["biggest_age"] as? String
        payment_type = attributes["payment_type"] as? String
        institution_logo = attributes["institution_logo"] as? String
        cpid = attributes["cpid"] as? String
        start_time = attributes["start_time"] as? String
        smallest_age = attributes["smallest_age"] as? String
        iid = attributes["iid"] as? String
        competition_rules = attributes["competition_rules"] as? String
        competition_process = attributes["competition_process"] as? NSNumber
        user_competing_process = attributes["user_competing_process"] as? NSNumber
        user_competing_status = attributes["user_competing_status"] as? NSNumber
        registration_time_begin = attributes["registration_time_begin"] as? String
        registration_time_end = attributes["registration_time_end"] as? String
        judge_score_time_begin = attributes["judge_score_time_begin"] as? String
        judge_score_time_end = attributes["judge_score_time_end"] as? String
        judge_competition_status = attributes["judge_competition_status"] as? NSNumber
        wcid = attributes["wcid"] as? String
        competition_type = attributes["competition_type"] as? String
        user_pay_status = attributes["user_pay_status"] as? NSNumber
        user_upload_status = attributes["user_upload_status"] as? NSNumber
        benefit_price = attributes["benefit_price"] as? String
        pay_amount = attributes["pay_amount"] as? String
        
        return self
    }
}

/** 比赛详情评委 */
class YSCompetitionJudge: NSObject {
    
    var avatar: String! // 头像URL
    var uid: String! // 用户ID
    var realname: String! // 用户姓名
    var introduction: String! // 个人简介
    
    class func competitionJudgeWithAttributes(attributes: NSDictionary) -> YSCompetitionJudge {
        return YSCompetitionJudge().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionJudge {
        
        avatar = attributes["avatar"] as? String
        uid = attributes["uid"] as? String
        realname = attributes["realname"] as? String
        introduction = attributes["introduction"] as? String
        
        return self
    }
}

/** 比赛报名页信息 */
class YSCompetitionConfirmInfo: NSObject {
    
    var payment_type: String! // 是否需付报名费，0为否，1为是
    var application_fee: String! // 报名费
    var match_name: String! // 赛事名称
    var last_time: String! // 赛事结束时间
    var institution_name: String! // 主办方名称
    var lst_competition_group: [YSCompetitionGroup]! // 赛事下的组别列表
    var start_time: String! // 赛事开始时间
    var cpid: String! // 赛事ID
    var iid: String! // 主办方ID
    var lst_publicity_pic: [String]! // 宣传图列表（最多6张）
    var registration_time_begin: String! // 赛事报名开始时间
    var registration_time_end: String! // 赛事报名结束时间
    var judge_score_time_begin: String! // 赛事评分开始时间
    var judge_score_time_end: String! // 赛事评分结束时间
    
    var obj_child_info: YSCompetitionChildInfo!
    var benefit_price: String! // 优惠金额
    var pay_amount: String! // 优惠金额
    
    
    class func confirmInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionConfirmInfo {
        return YSCompetitionConfirmInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionConfirmInfo {
        
        application_fee = attributes["application_fee"] as? String
        institution_name = attributes["institution_name"] as? String
        match_name = attributes["match_name"] as? String
        last_time = attributes["last_time"] as? String
        benefit_price = attributes["benefit_price"] as? String
         pay_amount = attributes["pay_amount"] as? String
        
        lst_competition_group = [YSCompetitionGroup]()
        if attributes["lst_competition_group"] as? NSArray != nil {
            for attribute in attributes["lst_competition_group"] as! NSArray {
                if attribute as? NSDictionary == nil {
                    continue
                }
                let group = YSCompetitionGroup.competitionGroupWithAttributes(attribute as! NSDictionary)
                lst_competition_group.append(group)
            }
        }
        
        lst_publicity_pic = [String]()
        if attributes["lst_publicity_pic"] as? NSArray != nil {
            for attribute in attributes["lst_publicity_pic"] as! NSArray {
                let publicity_pic = attribute as? String
                if publicity_pic == nil {
                    continue
                }
                lst_publicity_pic.append(publicity_pic!)
            }
        }
        
        payment_type = attributes["payment_type"] as? String
        cpid = attributes["cpid"] as? String
        start_time = attributes["start_time"] as? String
        iid = attributes["iid"] as? String
        if attributes["obj_child_info"] as? NSDictionary == nil {
            obj_child_info = nil
        } else {
            obj_child_info = YSCompetitionChildInfo.childInfoWithAttributes(attributes["obj_child_info"] as! NSDictionary)
        }
        registration_time_begin = attributes["registration_time_begin"] as? String
        registration_time_end = attributes["registration_time_end"] as? String
        judge_score_time_begin = attributes["judge_score_time_begin"] as? String
        judge_score_time_end = attributes["judge_score_time_end"] as? String
       
        return self
    }
}

/** 比赛组别 */
class YSCompetitionGroup: NSObject {
    
    var smallest_age: String! // 组别参赛者最小年龄
    var pid: String! // 父级组别ID，顶级组别父ID为0
    var cpid: String! // 赛事ID
    var cgid: String! // 赛事下的组别ID
    var biggest_age: String! // 组别参赛者最大年龄
    var title: String! // 组别名称
    var age_status: String! // 标识是否要求参赛者年龄，0为否，1为是
    var level: String! // 组别级别
    
    class func competitionGroupWithAttributes(attributes: NSDictionary) -> YSCompetitionGroup {
        return YSCompetitionGroup().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionGroup {
        
        smallest_age = attributes["smallest_age"] as? String
        pid = attributes["pid"] as? String
        cpid = attributes["cpid"] as? String
        cgid = attributes["cgid"] as? String
        biggest_age = attributes["biggest_age"] as? String
        title = attributes["title"] as? String
        age_status = attributes["age_status"] as? String
        level = attributes["level"] as? String
        
        return self
    }
}

/** 比赛孩子信息 */
class YSCompetitionChildInfo: NSObject {
    
    var cid: String!
    var uid: String!
    var username: String!
    var realname: String!
    var birth: String!
    var identity_card: NSNumber!
    var phone: String!
    var region: String!
    var school_institution: String!
    
    class func childInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionChildInfo {
        return YSCompetitionChildInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionChildInfo {
        
        cid = attributes["cid"] as? String
        uid = attributes["uid"] as? String
        username = attributes["username"] as? String
        realname = attributes["realname"] as? String
        birth = attributes["birth"] as? String
        identity_card = attributes["identity_card"] as? NSNumber
        phone = attributes["phone"] as? String
        region = attributes["region"] as? String
        school_institution = attributes["school_institution"] as? String
        
        return self
    }
}

/** 参加过的比赛信息 */
class YSCompetitionJoinedInfo: NSObject {
    
    var cpid: String! // 赛事ID
    var match_name: String! // 赛事名
    var start_time: String! // 赛事开始时间
    var last_time: String! // 赛事结束时间
    var cover_plan: String! // 封面图
    var competition_process: Int! // 赛事流程标识，0为报名正在进行中，1为评委评分进行中，2为已结束
    var user_competing_status: Int! // 用户参赛流程标识，1为报名成功，2为已提交参赛视频，3为已提交参赛作品资料，其他为未知
    var registration_time_begin: String! // 赛事报名开始时间
    var registration_time_end: String! // 赛事报名结束时间
    var judge_score_time_begin: String! // 赛事评分开始时间
    var judge_score_time_end: String! // 赛事评分结束时间
    var ranking: String! // 名次
    
    class func joinedInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionJoinedInfo {
        return YSCompetitionJoinedInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionJoinedInfo {
        
        cpid = attributes["cpid"] as? String
        match_name = attributes["match_name"] as? String
        start_time = attributes["start_time"] as? String
        last_time = attributes["last_time"] as? String
        cover_plan = attributes["cover_plan"] as? String
        competition_process = attributes["competition_process"] as? Int
        user_competing_status = attributes["user_competing_status"] as? Int
        registration_time_begin = attributes["registration_time_begin"] as? String
        registration_time_end = attributes["registration_time_end"] as? String
        judge_score_time_begin = attributes["judge_score_time_begin"] as? String
        judge_score_time_end = attributes["judge_score_time_end"] as? String
        ranking = attributes["ranking"] as? String
        
        return self
    }
}

/** 比赛排名信息 */
class YSCompetitionRankInfo: NSObject {
    
    var video_url: String! // （作品）视频URL
    var video_img_url: String! // （作品）视频封面图
    var personal_profile: String! // （孩子）个人简介
    var ranking: String! // 名次
    var uid: String! // 用户ID
    var cpid: String! // 赛事ID
    var cgid: String! // 赛事下的组别ID
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var title: String! // 作品名称
    var wid: String! // 作品ID
    var score: String! // 作品分数
    var work_uid_status: String! // 标识作品是否有关联用户，“0”为否，“1”为是
    
    class func rankInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionRankInfo {
        return YSCompetitionRankInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionRankInfo {
        
        video_url = attributes["video_url"] as? String
        video_img_url = attributes["video_img_url"] as? String
        personal_profile = attributes["personal_profile"] as? String
        ranking = attributes["ranking"] as? String
        uid = attributes["uid"] as? String
        cpid = attributes["cpid"] as? String
        cgid = attributes["cgid"] as? String
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        title = attributes["title"] as? String
        wid = attributes["wid"] as? String
        score = attributes["score"] as? String
        work_uid_status = attributes["work_uid_status"] as? String
        
        return self
    }
}

/** 赛事组别信息 */
class YSCompetitionGroupInfo: NSObject {
    
    var smallest_age: String! // 组别参赛者最小年龄
    var pid: String! // 父级组别ID，顶级组别父ID为0
    var cpid: String! // 赛事ID
    var cgid: String! // 赛事下的组别ID
    var biggest_age: String! // 组别参赛者最大年龄
    var title: String! // 组别名称
    var age_status: String! // 标识是否要求参赛者年龄，0为否，1为是
    var level: NSNumber! // 组别级别
    
    class func groupInfoWithAttributes(attributes: NSDictionary) -> YSCompetitionGroupInfo {
        return YSCompetitionGroupInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSCompetitionGroupInfo {
        
        smallest_age = attributes["smallest_age"] as? String
        pid = attributes["pid"] as? String
        cpid = attributes["cpid"] as? String
        cgid = attributes["cgid"] as? String
        biggest_age = attributes["biggest_age"] as? String
        title = attributes["title"] as? String
        age_status = attributes["age_status"] as? String
        level = attributes["level"] as? NSNumber
        
        return self
    }
}

/** 评分作品信息 */
class YSMarkingCompetitionInfo: NSObject {
    
    var username: String! // 用户名
    var avatar: String! // 用户头像
    var uid: String! // 用户ID
    var crid: String! // 报名ID
    var video_url: String! // 视频URL
    var wid: String! // 作品ID
    var video_img_url: String! // 视频缩略图
    var title: String! // 作品标题
    
    class func markingInfoWithAttributes(attributes: NSDictionary) -> YSMarkingCompetitionInfo {
        return YSMarkingCompetitionInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSMarkingCompetitionInfo {
        
        username = attributes["username"] as? String
        avatar = attributes["avatar"] as? String
        uid = attributes["uid"] as? String
        crid = attributes["crid"] as? String
        video_url = attributes["video_url"] as? String
        wid = attributes["wid"] as? String
        video_img_url = attributes["video_img_url"] as? String
        title = attributes["title"] as? String
        
        return self
    }
}


/** 学生列表信息 */
class YSStudentCompetitionInfo: NSObject {
    
    var realname: String! // 用户名
    var avatar: String! // 用户头像
    var uid: String! // 用户ID

    var phone: String! // 作品ID
    var user_competing_process: NSNumber! //
    var user_upload_status: NSNumber! // 作品标题
    
    var videoname: String! // 作品名称
    
    var groupname: String! //组别
    var crid: String! //组别
    
    class func markingInfoWithAttributes(attributes: NSDictionary) -> YSStudentCompetitionInfo {
        return YSStudentCompetitionInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSStudentCompetitionInfo {
        
        realname = attributes["realname"] as? String
        avatar = attributes["avatar"] as? String
        uid = attributes["uid"] as? String
        phone = attributes["phone"] as? String
        user_competing_process = attributes["user_competing_process"] as? NSNumber
        user_upload_status = attributes["user_upload_status"] as? NSNumber
        videoname = attributes["videoname"] as? String
        groupname = attributes["groupname"] as? String
        crid = attributes["crid"] as? String
        
        return self
    }
}
