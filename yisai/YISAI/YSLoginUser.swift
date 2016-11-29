

//
//  YSLoginUser.swift
//  YISAI
//
//  Created by Yufate on 15/5/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

enum UserRoleType: String {
    case User = "1"
    case Judge = "2"
    case Teacher = "3"
    case TeacherAndJudge = "4"
}

class YSLoginUser: NSObject {
   
    var loginKey: String!
    var uid: String!
    var role_type: String! // 1为普通用户，2为评委/老师
    
    var nickName: String!
    var realName: String!
    var birth: String!
    var sex: String!
    var idCard: String!
    var region: String!
    var tel: String!
    var institution: String!
    var conf: NSDictionary!
    
    override convenience init() {
        self.init(uid: nil, loginKey: nil, role_type: nil)
    }
    
    init(uid newUid: String!, loginKey newLoginKey: String!, role_type newType: String!) {
        uid = newUid
        loginKey = newLoginKey
        role_type = newType
    }
    
    /** 记录用户登录状态 */
    func setUser(user: YSLoginUser) {
        
        feSetAttrib("YISAI", key: "currentUser", value: user.uid)
        feSetAttrib("YISAI", key: "loginKey", value: user.loginKey)
        feSetAttrib("YISAI", key: "role_type", value: user.role_type)
        
        loginKey = user.loginKey
        uid = user.uid
        role_type = user.role_type
    }
    
    func setUserTel(newTel: String) {
        
        feSetAttrib("YISAI", key: "tel", value: newTel)
        tel = newTel
    }
    
    func setUserInstitution(newInstitution: String) {
        
        feSetAttrib("YISAI", key: "institution", value: newInstitution)
        institution = newInstitution
    }
    
    func setUserNickName(newNickName: String) {
        
        feSetAttrib("YISAI", key: "nickname", value: newNickName)
        nickName = newNickName
    }
    
    func setUserRealName(newRealName: String) {
        
        feSetAttrib("YISAI", key: "realname", value: newRealName)
        realName = newRealName
    }
    
    func setUserBirth(newBirth: String) {
        
        feSetAttrib("YISAI", key: "birth", value: newBirth)
        birth = newBirth
    }
    
    func setUserSex(newSex: String) {
        
        feSetAttrib("YISAI", key: "sex", value: newSex)
        
        sex = newSex
    }
    
    func setUserIDCard(newCard: String) {
        
        feSetAttrib("YISAI", key: "idcard", value: newCard)
        idCard = newCard
    }
    
    func setUserRegion(newRegion: String) {
        
        feSetAttrib("YISAI", key: "region", value: newRegion)
        region = newRegion
    }
    
    func setUserConf(newConf: NSDictionary) {
        
        fe_std_data_set_json("YISAI", key: "conf", jsonValue: newConf, expire_sec: DEFAULT_EXPIRE_SEC)
        conf = newConf
    }
    
    func getUser() -> Bool {
        
         uid = feGetAttrib("YISAI", key: "currentUser")
        loginKey = feGetAttrib("YISAI", key: "loginKey")
        role_type = feGetAttrib("YISAI", key: "role_type")
 
 
        
        //uid = "u_G0IfTe3"
       // loginKey = "K0IfTe3"
        //role_type = "1"
 
        
        nickName = feGetAttrib("YISAI", key: "nickname")
        realName = feGetAttrib("YISAI", key: "realname")
        birth = feGetAttrib("YISAI", key: "birth")
        sex = feGetAttrib("YISAI", key: "sex")
        idCard = feGetAttrib("YISAI", key: "idcard")
        region = feGetAttrib("YISAI", key: "region")
        tel = feGetAttrib("YISAI", key: "tel")
        institution = feGetAttrib("YISAI", key: "institution")
        conf = fe_std_data_get_json("YISAI", key: "conf")
        
        if uid == nil || loginKey == nil || role_type == nil {
            // 没有登录状态
            return false
        } else {
            return true
        }
    }
    
    /** 清除登录状态 */
    func clean() {
        
        loginKey = nil
        uid = nil
        role_type = nil
        
        nickName = nil
        realName = nil
        birth = nil
        sex = nil
        
        feSetAttrib("YISAI", key: "currentUser", value: nil)
        feSetAttrib("YISAI", key: "loginKey", value: nil)
        feSetAttrib("YISAI", key: "role_type", value: nil)
        
        feSetAttrib("YISAI", key: "nickName", value: nil)
        feSetAttrib("YISAI", key: "realName", value: nil)
        feSetAttrib("YISAI", key: "birth", value: nil)
        feSetAttrib("YISAI", key: "sex", value: String(0))
        feSetAttrib("YISAI", key: "idcard", value: nil)
        feSetAttrib("YISAI", key: "region", value: nil)
        
        fe_std_data_set_json("YISAI", key: "conf", jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
        
        feSetAttrib("YISAI", key: "guidecompetition", value: String(0))
        feSetAttrib("YISAI", key: "guidecompetition", value: String(0))
    }
}

class YSGuide: NSObject {
    
    class func setUserGuideMine(newGuide: Int64) {
        
        feSetAttrib("YSGuide", key: "guidemine", value: String(newGuide))
    }
    
    class func setUserGuideCompetition(newGuide: Int64) {
        
        feSetAttrib("YSGuide", key: "guidecompetition", value: String(newGuide))
    }
    
    class func setUserGuideDiscovery(newGuide: Int64) {
        
        feSetAttrib("YSGuide", key: "guidediscovery", value: String(newGuide))
    }
    
    class func getUserGuideMine() -> Int64? {
        
        if let guideMine = feGetAttrib("YSGuide", key: "guideMine") {
            return Int64(guideMine)!
        }
        return nil
    }
    
    class func getUserGuideCompetition() -> Int64? {
        
        if let guidecompetition = feGetAttrib("YSGuide", key: "guidecompetition") {
            return Int64(guidecompetition)!
        }
        return nil
    }
    
    class func getUserGuideDiscovery() -> Int64? {
        
        if let guideDiscovery = feGetAttrib("YSGuide", key: "guideDiscovery") {
            return Int64(guideDiscovery)!
        }
        return nil
    }
}

class YSConfigure: NSObject {
    
    var cfid: String! // 配置ID
    var discovery_recording: Int! // 发现拍摄功能，0关闭，1开启
    var discovery_search: Int! // 搜索功能，0关闭，1开启
    var competition_search: Int! // 赛事筛选，0关闭，1开启
    var competition_participate: Int! // 我要报名，0关闭，1开启
    var my_awards: Int! // 我的获奖，0关闭，1开启
    var my_uploadmanagement: Int! // 上传管理，0关闭，1开启
    var my_work: Int! // 作品，0关闭，1开启
    var my_setting: Int! // 设置中心，0关闭，1开启
    var my_family: Int! // 我的家庭，0关闭，1开启
    var my_teacher: Int! // 我的老师，0关闭，1开启
    var my_friend: Int! // 我的好友，0关闭，1开启
    var my_message: Int! // 私信，0关闭，1开启
    var update_time: NSNumber! // 更新时间
    var export_my_winning_comp: Int! // 导出我的获奖经历，0关闭，1开启
    
    class func confWithAttributes(attributes: NSDictionary) -> YSConfigure {
        return YSConfigure().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSConfigure {
        
        cfid = attributes["cfid"] as? String
        discovery_recording = attributes["discovery_recording"] as? Int
        discovery_search = attributes["discovery_search"] as? Int
        competition_search = attributes["competition_search"] as? Int
        competition_participate = attributes["competition_participate"] as? Int
        my_awards = attributes["my_awards"] as? Int
        my_uploadmanagement = attributes["my_uploadmanagement"] as? Int
        my_work = attributes["my_work"] as? Int
        my_setting = attributes["my_setting"] as? Int
        my_family = attributes["my_family"] as? Int
        my_teacher = attributes["my_teacher"] as? Int
        my_friend = attributes["my_friend"] as? Int
        my_message = attributes["my_message"] as? Int
        update_time = attributes["update_time"] as? NSNumber
        export_my_winning_comp = attributes["export_my_winning_comp"] as? Int
        
        return self
    }
    
    /** APP配置信息 */
    class func fetchConf() {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/conf"
        let params = ["a", "conf", "uid", uid, "loginkey", loginkey] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: "conf" + uid, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    return
                }
                
                let resp_obj_conf = data!["obj_conf"] as? NSDictionary
                if resp_obj_conf == nil {
                    return
                }
                

                
                ysApplication.loginUser.setUserConf(resp_obj_conf!)
            })
            
        }, params: params)
    }
    
    /** （普通用户）作品的评委/老师评论是否呈现普通用户 */
    class func setWorkJudgeTeacherCommentStatus(status: Int, resp block: ((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/work"
        let params = ["a", "setWorkJudgeTeacherCommentStatus", "uid", uid, "loginkey", loginkey, "status", "\(status)"] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let resp = handler.content_jsonObj
                
               
                if resp == nil {
                    return
                }
                 print(resp)
                if block == nil {
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
                case -1, 0:
                    errorMsg = "获取数据失败"
                case 9000, 9001, 1001:
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
                    block(errorMsg)
                    return
                }
                
                block(nil)
            })
            
        }, params: params)
    }
    
    /** （普通用户）获取作品的评委/老师评论是否呈现普通用户 */
    class func getWorkJudgeTeacherCommentStatus(resp block: ((Int!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/work"
        let params = ["a", "getWorkJudgeTeacherCommentStatus", "uid", uid, "loginkey", loginkey] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let resp = handler.content_jsonObj
                
                
                if resp == nil {
                    return
                }
                print(resp)
                if block == nil {
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
                case -1, 0:
                    errorMsg = "获取数据失败"
                case 9000, 9001, 1001:
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
                    block(nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    return
                }
                
                let work_judge_teacher_comment_status = data!["work_judge_teacher_comment_status"] as? Int
                
                if work_judge_teacher_comment_status == nil {
                    return
                }
                
                block(work_judge_teacher_comment_status, nil)
            })
            
            }, params: params)
    }
}
