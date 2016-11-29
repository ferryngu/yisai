//
//  YSTutor.swift
//  YISAI
//
//  Created by Yufate on 15/6/30.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

/** 我的老师 */
class YSTutor: NSObject {
   
    /** 获取我的老师页数据 */
    class func fetchChildTutor(shouldCache: Bool, startIndex: Int, num: Int, block: ((YSChildTutor!, [YSChildTutor]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "childAdvisor" + "list"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childAdvisor", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
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
                case -1:
                    errorMsg = "获取数据失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002:
                    errorMsg = "用户信息有误"
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
                
                let resp_obj_child_advisor = data!["obj_child_advisor"] as? NSDictionary
                if resp_obj_child_advisor == nil {
                    block(nil, nil, "数据错误")
                    return
                }
                
                let resp_current_advisor = YSChildTutor.childTutorWithAttributes(resp_obj_child_advisor!)
                
                let resp_lst_child_advisor = resp_obj_child_advisor!["lst_child_advisor"] as? NSArray
                var lst_history_advisors = [YSChildTutor]()
                
                if resp_lst_child_advisor != nil {
                    for child_advisor in resp_lst_child_advisor! {
                        if child_advisor as? NSDictionary == nil {
                            continue
                        }
                        let advisor = YSChildTutor.childTutorWithAttributes(child_advisor as! NSDictionary)
                        lst_history_advisors.append(advisor)
                    }
                }
                
                block(resp_current_advisor, lst_history_advisors, nil)
            })
            
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey, "start", "\(startIndex)", "num", "\(num)"])
    }
    
    /** 评委/指导老师个人主页数据 */
    class func fetchJudgeTeacherInfo(fuid: String, startIndex: Int, num: Int, block: ((YSTutor_Judge!, [YSTutorStudent]!, YSStudentPrizeCount!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = fuid + "judgeTeacher" + "homePage"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
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
                    block(nil, nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, nil, "数据错误")
                    return
                }
                
                if data!["obj_judge_teacher"] as? NSDictionary == nil || data!["obj_student_comp_winning_statistics"] as? NSDictionary == nil {
                    block(nil, nil, nil, "数据错误")
                    return
                }
                
                let resp_obj_judge_teacher = YSTutor_Judge.tutor_judgeWithAttributes(data!["obj_judge_teacher"] as! NSDictionary)
                let resp_prize_count = YSStudentPrizeCount.prizeCountWithAttributes(data!["obj_student_comp_winning_statistics"] as! NSDictionary)
                
                let resp_lst_student = data!["lst_student"] as? NSArray
                var lst_student = [YSTutorStudent]()
                if resp_lst_student != nil {
                    for attribute in resp_lst_student! {
                        if attribute as? NSDictionary == nil {
                            continue
                        }
                        let student = YSTutorStudent.studentWithAttributes(attribute as! NSDictionary)
                        lst_student.append(student)
                    }
                }
                
                block(resp_obj_judge_teacher, lst_student, resp_prize_count, nil)
            })
            
        }, params: ["a", "homePage", "uid", uid, "loginkey", loginkey, "fuid", fuid, "start", "\(startIndex)", "num", "\(num)"])
    }
    
    /** 获取我的学生页数据 */
    class func fetchMyStudents(startIndex: Int, num: Int, block: (([YSTutorStudent]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "student" + "list"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/student", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                let resp_lst_student = data!["lst_student"] as? [AnyObject]
                var lst_student = [YSTutorStudent]()
                if resp_lst_student != nil {
                    for student in resp_lst_student! {
                        if student as? NSDictionary == nil {
                            continue
                        }
                        let aStudent = YSTutorStudent.studentWithAttributes(student as! NSDictionary)
                        lst_student.append(aStudent)
                    }
                    
                }
                
                block(lst_student, nil)
            })
            
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey, "start", "\(startIndex)", "num", "\(num)"])
    }
    
    /** 获取评委加入的主办方列表 */
    class func fetchOrganizationJoined(block: (([YSOrganization]!, [YSOrganization]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "judgeTeacher" + "listWithJudge"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    block(nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, "数据异常")
                    return
                }
                let resp_list_to_join_institution = data!["list_to_join_institution"] as? [AnyObject]
                let resp_lst_withdrawal_institution = data!["lst_withdrawal_institution"] as? [AnyObject]
                var lst_to_join_institution = [YSOrganization]()
                var lst_withdrawal_institution = [YSOrganization]()
                
                if resp_list_to_join_institution != nil && resp_lst_withdrawal_institution != nil {
                    
                    for institution in resp_list_to_join_institution! {
                        if institution as? NSDictionary == nil {
                            continue
                        }
                        let aInstitution = YSOrganization.organizationWithAttributes(institution as! NSDictionary)
                        lst_to_join_institution.append(aInstitution)
                    }
                    
                    for institution in resp_lst_withdrawal_institution! {
                        if institution as? NSDictionary == nil {
                            continue
                        }
                        let aInstitution = YSOrganization.organizationWithAttributes(institution as! NSDictionary)
                        lst_withdrawal_institution.append(aInstitution)
                    }

                }
                
                block(lst_to_join_institution, lst_withdrawal_institution, nil)
            })
            
        }, params: ["a", "listWithJudge", "uid", uid, "loginkey", loginkey, "start", "\(0)", "num", "\(99)"])
    }
    
    /** 获取评委的主办方邀请列表 */
    class func fetchOrganizationInvited(block: (([YSOrganization]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "listWithInstitutionInvitation", "uid", uid, "loginkey", loginkey, "start", "\(0)", "num", "\(99)"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                
                let resp_list_institution_invitation = data!["list_institution_invitation"] as? [AnyObject]
                var list_institution_invitation = [YSOrganization]()
                if resp_list_institution_invitation != nil {
                    
                    for invitation in resp_list_institution_invitation! {
                        if invitation as? NSDictionary == nil {
                            continue
                        }
                        let aInvitation = YSOrganization.organizationWithAttributes(invitation as! NSDictionary)
                        list_institution_invitation.append(aInvitation)
                    }
                }
                
                block(list_institution_invitation, nil)
            })
            
        }, params: params)
    }
    
    /** 评委_接受/拒绝邀请 */
    // status: 1为接受，2为拒绝
    class func invitationWithStatus(status: Int, iid: String, cpid: String, block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "isInvitedWithJudge", "uid", uid, "loginkey", loginkey, "iid", iid, "cpid", cpid, "status", "\(status)"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001, 3001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 1003:
                    errorMsg = "主办方信息错误"
                case 2001, 2002:
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
    
    /** 评委_退出主办方 */
    class func exitOrganization(iid: String, block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "withdrawalInstitution", "uid", uid, "loginkey", loginkey, "iid", iid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001, 1002:
                    errorMsg = "主办方信息错误"
                case 2002, 2003, 3002:
                    errorMsg = "评委信息有误"
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
    
    /** 获取评委资历数据 */
    class func fetchJudgeQualification(fuid:String, block: ((YSJudgeQualification!, String!)-> Void)!) {
        
        var uid = ysApplication.loginUser.uid
        var loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil{
            uid = ""
        }
        
        if loginkey == nil
        {
            loginkey = ""
        }
        
        
        let params = ["a", "judgeQualification", "uid", uid, "loginkey", loginkey, "fuid", fuid, "start", "\(0)", "num", "\(99)"] as [String]
        
        let cacheKey = fuid + "judgeTeacher" + "judgeQualification"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/judgeTeacher", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    errorMsg = "评委信息有误"
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
                
                let resp_obj_judge = data!["obj_judge"] as? NSDictionary
                if resp_obj_judge == nil {
                    block(nil, "数据异常")
                    return
                }
                
                let obj_judge = YSJudgeQualification.qualificationWithAttributes(resp_obj_judge!)
                

                
                block(obj_judge, nil)
            })
            
        }, params: params)
    }
    
    /** 学生奖项 */
    class func fetchStudentPrize(aid: String, block: (([YSStudentPrize]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "listWithAid", "uid", uid, "loginkey", loginkey, "aid", aid, "start", "\(0)", "num", "\(99)"] as [String]
        
        let cacheKey = aid + "childCompetitionInfo" + "listWithAid"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/childCompetitionInfo", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    block(nil, "数据异常")
                    return
                }
                
                let resp_lst_child_competition_info = data!["lst_child_competition_info"] as? [AnyObject]
                var lst_child_competition_info = [YSStudentPrize]()
                if resp_lst_child_competition_info != nil {
                    for prize in resp_lst_child_competition_info! {
                        if prize as? NSDictionary == nil {
                            continue
                        }
                        let aPrize = YSStudentPrize.prizeWithAttributes(prize as! NSDictionary)
                        lst_child_competition_info.append(aPrize)
                    }
                    

                }
                
                block(lst_child_competition_info, nil)
            })
            
            }, params: params)
    }
}

/** 我的老师页数据 */
class YSChildTutor: NSObject {
    
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var aid: String! // 指导老师ID
    var username: String! // 用户名
    var update_time: String! // 指导时间
    
    class func childTutorWithAttributes(attributes: NSDictionary) -> YSChildTutor {
        return YSChildTutor().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSChildTutor {
        
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        aid = attributes["aid"] as? String
        username = attributes["username"] as? String
        update_time = attributes["update_time"] as? String
        
        return self
    }
}

/** 老师资料页 */
class YSTutor_Judge: NSObject {
    
    var role_type: NSNumber! // 角色类型，0为评委，1为老师，2为评委/老师
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var fuid: String! // （点击查看的）用户ID
    var username: String! // 用户名
    var user_concern_status: NSNumber! // 标识是否关注，0为否，1为是
    
    class func tutor_judgeWithAttributes(attributes: NSDictionary) -> YSTutor_Judge {
        return YSTutor_Judge().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSTutor_Judge {
        
        role_type = attributes["role_type"] as? NSNumber
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        fuid = attributes["fuid"] as? String
        username = attributes["username"] as? String
        user_concern_status = attributes["user_concern_status"] as? NSNumber
        
        return self
    }
}

/** 老师资料页，学生列表 */
class YSTutorStudent: NSObject {
    
    var avatar: String! // 头像URL
    var realname: String! // 真实姓名
    var uid: String! // 用户（学生）ID
    var username: String! // 用户名
    
    class func studentWithAttributes(attributes: NSDictionary) -> YSTutorStudent {
        return YSTutorStudent().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSTutorStudent {
        
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        uid = attributes["uid"] as? String
        username = attributes["username"] as? String
        
        return self
    }
}

/** 主办方资料 */
class YSOrganization: NSObject {
    
    var institution_name: String! // 主办方名称
    var update_time: String! // 更新时间，格式yyyy-MM-dd，例如：2015-05-26
    var institution_logo: String! // 主办方LOGO
    var iid: String! // 主办方ID
    var introduction: String! // 主办方介绍
    var content: String! // 邀请信息
    var cpid: String! // 赛事ID
    var phone: String! // 手机号
    
    class func organizationWithAttributes(attributes: NSDictionary) -> YSOrganization {
        return YSOrganization().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSOrganization {
        
        institution_name = attributes["institution_name"] as? String
        update_time = attributes["update_time"] as? String
        institution_logo = attributes["institution_logo"] as? String
        iid = attributes["iid"] as? String
        introduction = attributes["introduction"] as? String
        content = attributes["content"] as? String
        cpid = attributes["cpid"] as? String
        phone = attributes["phone"] as? String
        
        return self
    }
}

/** 评委赛事资历 */
class YSJudgeMatchQualification: NSObject {
    
    var match_name: String! // 赛事名称
    var update_time: String! // （被查看的）指导老师（加入主办方）作为赛事评委的时间
    
    class func qualificationWithAttributes(attributes: NSDictionary) -> YSJudgeMatchQualification {
        return YSJudgeMatchQualification().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSJudgeMatchQualification {
        
        match_name = attributes["match_name"] as? String
        update_time = attributes["update_time"] as? String
        
        return self
    }
}

/** 评委资历 */
class YSJudgeQualification: NSObject {
    
    var lst_qualification: [YSJudgeMatchQualification]! // 资历列表
    var avatar: String! // 头像URL
    var lst_picture: [String]! // 宣传照片列表
    var realname: String! // 真实姓名
    var fuid: String! // （被查看的）评委ID
    var video_url: String! // 宣传视频URL
    var introduction: String! // 个人简介
    var username: String! // 昵称
    var video_img_url: String! // 视频截图
    
    class func qualificationWithAttributes(attributes: NSDictionary) -> YSJudgeQualification {
        return YSJudgeQualification().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSJudgeQualification {
        
        lst_qualification = [YSJudgeMatchQualification]()
        let resp_lst_qualification = attributes["lst_qualification"] as? [AnyObject]
        if resp_lst_qualification != nil {
            for matchQualification in resp_lst_qualification! {
                if matchQualification as? NSDictionary == nil {
                    continue
                }
                let aMatchQualification = YSJudgeMatchQualification.qualificationWithAttributes(matchQualification as! NSDictionary)
                lst_qualification.append(aMatchQualification)
            }
        }
        
        avatar = attributes["avatar"] as? String
        
        lst_picture = [String]()
        let resp_lst_picture = attributes["lst_picture"] as? [AnyObject]
        if resp_lst_picture != nil {
            for picture in resp_lst_picture! {
                if picture as? String == nil {
                    continue
                }
                let aPicture = picture as! String
                lst_picture.append(aPicture)
            }
        }
        
        realname = attributes["realname"] as? String
        fuid = attributes["fuid"] as? String
        video_url = attributes["video_url"] as? String
        introduction = attributes["introduction"] as? String
        username = attributes["username"] as? String
        video_img_url = attributes["video_img_url"] as? String
        
        return self
    }
}

/** 学生奖项 */
class YSStudentPrize: NSObject {
    
    var crid: String! // 赛事报名ID
    var update_time: String! // 更新时间
    var ranking: NSNumber! // 名次，默认为0未获得名次
    var work_title: String! // 赛事标题
    var username: String! // 用户（学生）昵称
    var uid: String! // 用户（学生）ID
    var cid: String! // 用户（学生）的孩子ID
    var cpid: String! // 赛事ID
    var cgid: String! // 赛事下的组别ID
    var avatar: String! // 用户（学生）头像URL
    var realname: String! // 用户（学生）真实姓名
    var competition_name: String! // 赛事名称
    
    class func prizeWithAttributes(attributes: NSDictionary) -> YSStudentPrize {
        return YSStudentPrize().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSStudentPrize {
        
        crid = attributes["crid"] as? String
        update_time = attributes["update_time"] as? String
        ranking = attributes["ranking"] as? NSNumber
        work_title = attributes["work_title"] as? String
        username = attributes["username"] as? String
        uid = attributes["uid"] as? String
        cid = attributes["cid"] as? String
        cpid = attributes["cpid"] as? String
        cgid = attributes["cgid"] as? String
        avatar = attributes["avatar"] as? String
        realname = attributes["realname"] as? String
        competition_name = attributes["competition_name"] as? String
        
        return self
    }
}

/** 学生赛事奖项统计 */
class YSStudentPrizeCount: NSObject {
    
    var champion_count: String! // 冠军总数
    var runner_up_count: String! // 亚军总数
    var bronze_count: String! // 季军总数
    var rear_guard_count: String! // 殿军总数
    
    class func prizeCountWithAttributes(attributes: NSDictionary) -> YSStudentPrizeCount {
        return YSStudentPrizeCount().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSStudentPrizeCount {
        
        champion_count = attributes["champion_count"] as? String
        runner_up_count = attributes["runner_up_count"] as? String
        bronze_count = attributes["bronze_count"] as? String
        rear_guard_count = attributes["rear_guard_count"] as? String
        
        return self
    }
}
