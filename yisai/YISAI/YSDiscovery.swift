//
//  YSDiscovery.swift
//  YISAI
//
//  Created by Yufate on 15/6/5.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSDiscovery: NSObject {
   
    /** 发现首页 */
    class func findModule(shouldCache: Bool, startIndex: Int!, fetchNum: Int!, resp block: (([YSDiscoveryMainFindWork]!, [YSDiscoveryMainSlide]!, String!)-> Void)!) {
        
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
        
        if uid == nil
        {
            uid = ""
        }
        if loginkey == nil
        {
            loginkey = ""
        }
        let cacheKey = "findModule" + "findModuleData"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/findModule", cacheKey: shouldCache ? cacheKey : nil , prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                
                let lst_findwork = data!["lst_findwork"] as? [AnyObject]
                let lst_slide = data!["lst_slide"] as? [AnyObject]
                
                var resp_lst_findwork = [YSDiscoveryMainFindWork]()
                var resp_lst_slide = [YSDiscoveryMainSlide]()
                
                if lst_findwork != nil && lst_slide != nil {
                    for attributes in lst_findwork! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let findwork = YSDiscoveryMainFindWork.findworkWithAttributes(attributes as! NSDictionary)
                        resp_lst_findwork.append(findwork)
                    }
                    for attributes in lst_slide! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let slide = YSDiscoveryMainSlide.slideWithAttributes(attributes as! NSDictionary)
                        resp_lst_slide.append(slide)
                    }
                }
                
                block(resp_lst_findwork, resp_lst_slide, nil)
            })
            
        }, params: ["a", "findModuleData", "uid", uid, "loginkey", loginkey, "start", "\(start)", "num", "\(num)"])
    }
    
    /** 获取搜索关键字有关的作品列表 */
    class func searchFindWork(keyword: String, startIndex: Int!, fetchNum: Int!, resp block: (([YSDiscoveryMainFindWork]!, String!)-> Void)!) {
        
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
        
        if uid == nil
        {
            uid = ""
        }
        if loginkey == nil
        {
            loginkey = ""
        }
        
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/search", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                
                let lst_findwork = data!["lst_search_work"] as? [AnyObject]
                var resp_lst_findwork = [YSDiscoveryMainFindWork]()
                if lst_findwork != nil {
                    for attributes in lst_findwork! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let findwork = YSDiscoveryMainFindWork.findworkWithAttributes(attributes as! NSDictionary)
                        resp_lst_findwork.append(findwork)
                    }
                }
                block(resp_lst_findwork, nil)
            })
            
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey, "keyword", keyword, "start", "\(start)", "num", "\(num)"])
    }
    
    /** 赞和取消赞 */
    class func praise(praiseType: Int, wid: String, block: ((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var action = ""
        if praiseType == 0 {
            // type = 0, 点赞
            action = "addWorkPraiseCount"
        } else {
            // type = 1, 取消点赞
            action = "reduceWorkPraiseCount"
        }
        
        let params = ["a", action, "uid", uid, "loginkey", loginkey, "wid", wid] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/work", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    errorMsg = "操作失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 1004:
                    errorMsg = "点赞作品信息错误"
                case 1003:
                    errorMsg = "尚未提交点赞请求"
                case 3001:
                    errorMsg = "已提交点赞请求"
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
    
    /** 提交评论 */
    class func comment(wid: String, content: String, block: ((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let params = ["a", "addComment", "uid", uid, "loginkey", loginkey, "wid", wid, "content", content] as [String]
        
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
                    errorMsg = "操作失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "评论作品信息错误"
                case 2001:
                    errorMsg = "请填写评论内容"
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

    /** 获取热门分类 */
    class func getHotSearch(resp block: (([YSDiscoveryHotSearch]!, String!)-> Void)!) {
        
        //let uid = ysApplication.loginUser.uid
        //let loginkey = ysApplication.loginUser.loginKey
        
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
        
        
        let cacheKey = "search" + "hot"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/search", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
//                println(resp)
                
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
                
                let lst_hot_search = data!["lst_hot_search_record"] as? [AnyObject]
                var resp_lst_hot_search = [YSDiscoveryHotSearch]()
                
                if lst_hot_search != nil {
                    for attributes in lst_hot_search! {
                        if attributes as? NSDictionary == nil {
                            continue
                        }
                        let hot_search = YSDiscoveryHotSearch.hotSearchWithAttributes(attributes as! NSDictionary)
                        resp_lst_hot_search.append(hot_search)
                    }
                }
                
                block(resp_lst_hot_search, nil)
            })
            
        }, params: ["a", "hot", "uid", uid, "loginkey", loginkey])
    }
    
    /** 累计播放次数 */
    class func addVideoView(wid: String, block: ((String!) -> Void)!) {
        
        //let uid = ysApplication.loginUser.uid
        //let loginkey = ysApplication.loginUser.loginKey
        
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
        
        
        let params = ["a", "addWorkVideoView", "uid", uid, "loginkey", loginkey, "wid", wid] as [String]
        
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
                    errorMsg = "操作失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 1001, 1002:
                    errorMsg = "作品信息错误"
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

/** 发现详情 */
class YSDiscoveryDetail: NSObject {
    
    var video_url: String! // 作品（视频）URL
    var video_img_url: String! // 作品（视频）封面图URL
    var username: String! // 用户名
    var praise_count: NSNumber! // 点赞数
    var lst_comment_normal: [YSDiscoveryComment]! // 普通用户评论列表
    var uid: String! // 用户（发布此作品）ID
    var lst_comment_judge_teacher: [YSDiscoveryComment]! // 评委/指导老师评论列表
    var avatar: String! // 用户（发布此作品）头像URL
    var title: String! // 作品标题
    var wid: String! // 作品ID
    var praise_status: NSNumber! // 标识用户是否已点赞该作品，0为否，1为是
    var uid_status: NSNumber! // 标识用户与作品关系，0为普通用户/评委/老师，1为该作品的作者/评委/老师，2为已评论该作品的评委/老师
    var role_type: Int! // 角色标识，0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
    var video_view: String! // 累计播放次数
    var category_name: String! // 赛事分类名称
    var update_time: String! // 更新时间
    var workuid_role: Int! // 更新时间
    
    
    
    class func detailWithAttributes(attributes: NSDictionary) -> YSDiscoveryDetail {
        return YSDiscoveryDetail().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSDiscoveryDetail {
        
        video_url = attributes["video_url"] as? String
        video_img_url = attributes["video_img_url"] as? String
        username = attributes["username"] as? String
        praise_count = attributes["praise_count"] as? NSNumber
        
        lst_comment_normal = [YSDiscoveryComment]()
        if attributes["lst_comment_normal"] as? NSArray != nil {
            for comment_normal in attributes["lst_comment_normal"] as! NSArray {
                if comment_normal as? NSDictionary == nil {
                    continue
                }
                let comment = YSDiscoveryComment.commentWithAttributes(comment_normal as! NSDictionary)
                lst_comment_normal.append(comment)
            }
        }
        
        uid = attributes["uid"] as? String
        
        var resp_lst_comment_judge_teacher = [YSDiscoveryComment]()
        if attributes["lst_comment_judge_teacher"] as? NSArray != nil {
            for comment_judge_teacher in attributes["lst_comment_judge_teacher"] as! NSArray {
                if comment_judge_teacher as? NSDictionary == nil {
                    continue
                }
                let comment = YSDiscoveryComment.commentWithAttributes(comment_judge_teacher as! NSDictionary)
                resp_lst_comment_judge_teacher.append(comment)
            }
        }
        lst_comment_judge_teacher = resp_lst_comment_judge_teacher
        
        avatar = attributes["avatar"] as? String
        title = attributes["title"] as? String
        wid = attributes["wid"] as? String
        praise_status = attributes["praise_status"] as? NSNumber
        uid_status = attributes["uid_status"] as? NSNumber
        role_type = attributes["role_type"] as? Int
        video_view = attributes["video_view"] as? String
        category_name = attributes["category_name"] as? String
        update_time = attributes["update_time"] as? String
        workuid_role = attributes["workuid_role"] as? Int
        return self
    }
    
    /** 获取作品详情 */
    class func fetchWorkDetail(wid: String, block: ((YSDiscoveryDetail!, String!)-> Void)!) {
        
       // let uid = ysApplication.loginUser.uid
       // let loginkey = ysApplication.loginUser.loginKey
        
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
                
                 print(resp)
                
                
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
                case 1001, 1002:
                    errorMsg = "作品信息错误"
                case 2001, 2002:
                    errorMsg = "匿名作品"
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
                
                let obj_work_detail = data!["obj_work_detail"] as? NSDictionary
                if obj_work_detail == nil {
                    block(nil, "数据错误")
                    return
                }
                
                let resp_detail = YSDiscoveryDetail.detailWithAttributes(obj_work_detail!)
                
                
                block(resp_detail, nil)
            })
            
        }, params: ["a", "detail", "uid", uid, "loginkey", loginkey, "wid", wid])
    }
}

/** 发现首页作品 */
class YSDiscoveryMainFindWork: NSObject {
    
    var avatar: String! // 头像URL
    var praise_count: Int! // 点赞数
    var uid: String! // 用户ID
    var video_url: String! // 视频URL
    var wid: String! // 作品ID
    var video_img_url: String! // 视频封面图URL
    var title: String! // 标题
    var update_time: NSNumber! // 更新时间
    
    class func findworkWithAttributes(attributes: NSDictionary) -> YSDiscoveryMainFindWork {
        return YSDiscoveryMainFindWork().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSDiscoveryMainFindWork {
        
        avatar = attributes["avatar"] as? String
        praise_count = attributes["praise_count"] as? Int
        uid = attributes["uid"] as? String
        video_url = attributes["video_url"] as? String
        wid = attributes["wid"] as? String
        video_img_url = attributes["video_img_url"] as? String
        title = attributes["title"] as? String
        update_time = attributes["update_time"] as? NSNumber
        
        return self
    }
}

/** 发现首页幻灯片 */
class YSDiscoveryMainSlide: NSObject {
    
    var photo: String! // 图片URL
    var sort_number: Int! // 排序字段
    var is_show: Int! // 是否显示，1为显示，0为不显示
    var title: String! // 标题
    var update_time: NSNumber! // 该行记录插入或更新的时间
    var sid: String! // 幻灯片ID
    var note: String! // 备注
    var type: Int! // 广告类型，0为链接类型，1为应用赛事
    var advertisement_url: String! // web链接
    var advertisement_cpid: String! // 赛事ID
    var wcid: String! // 赛事分类ID
    var work_category_name: String! // 赛事分类名称
    var status: String! // 标识该赛事ID是否存在，0为否，1为是
    
    class func slideWithAttributes(attributes: NSDictionary) -> YSDiscoveryMainSlide {
        return YSDiscoveryMainSlide().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSDiscoveryMainSlide {
        
        photo = attributes["photo"] as? String
        sort_number = attributes["sort_number"] as? Int
        is_show = attributes["is_show"] as? Int
        title = attributes["title"] as? String
        update_time = attributes["update_time"] as? NSNumber
        sid = attributes["sid"] as? String
        note = attributes["note"] as? String
        type = attributes["type"] as? Int
        advertisement_url = attributes["advertisement_url"] as? String
        advertisement_cpid = attributes["advertisement_cpid"] as? String
        wcid = attributes["wcid"] as? String
        work_category_name = attributes["work_category_name"] as? String
        status = attributes["status"] as? String
        
        return self
    }
}

/** 详情评论 */
class YSDiscoveryComment: NSObject {
    
    var avatar: String! // 用户（评委/指导老师）头像URL
    var uid: String! // 用户（评委/指导老师）ID
    var update_time: String! // 评论更新时间
    var content: String! // 评论内容
    var username: String! // 用户名
    var commentator_type: Int! // 角色标识，0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
    
    class func commentWithAttributes(attributes: NSDictionary) -> YSDiscoveryComment {
        return YSDiscoveryComment().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSDiscoveryComment {
        
        avatar = attributes["avatar"] as? String
        uid = attributes["uid"] as? String
        update_time = attributes["update_time"] as? String
        content = attributes["content"] as? String
        username = attributes["username"] as? String
        commentator_type = attributes["commentator_type"] as? Int
        
        return self
    }
}

/** 热门搜索 */
class YSDiscoveryHotSearch: NSObject {
    
    var keyword: String! // 搜索内容
    var update_time: NSNumber! // 更新时间
    var is_show: NSNumber! // 是否显示，1为显示，0为不显示
    var hsr_id: String! // 热门搜索ID
    var sort_number: NSNumber! // 用户名
    
    class func hotSearchWithAttributes(attributes: NSDictionary) -> YSDiscoveryHotSearch {
        return YSDiscoveryHotSearch().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSDiscoveryHotSearch {
        
        keyword = attributes["keyword"] as? String
        update_time = attributes["update_time"] as? NSNumber
        is_show = attributes["is_show"] as? NSNumber
        hsr_id = attributes["hsr_id"] as? String
        sort_number = attributes["sort_number"] as? NSNumber
        
        return self
    }
}
