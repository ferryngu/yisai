//
//  YSFamilyInfo.swift
//  YISAI
//
//  Created by Yufate on 15/6/15.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSFamilyInfo: NSObject {
    
    /** 获取家庭动态列表 */
    class func fetchFamilyDynamic(shouldCache: Bool, startIndex: Int, num:Int, block: (([YSFamilyDynamic]!, [YSParentInfo]!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "familyDynamic" + "list"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/familyDynamic", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    block(nil, nil, errorMsg!)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, "数据错误")
                    return
                }
                
                let resp_lst_family_dynamic = data!["lst_family_dynamic"] as? NSArray
                let resp_lst_parent_info = data!["lst_parent_info"] as? NSArray
                
                var lst_parent_info = [YSParentInfo]()
                var lst_family_dynamic = [YSFamilyDynamic]()
                
                if resp_lst_family_dynamic != nil && resp_lst_parent_info != nil {
                    
                    // 家庭动态列表
                    for family_dynamic in resp_lst_family_dynamic! {
                        if family_dynamic as? NSDictionary == nil {
                            continue
                        }
                        let familyDynamic = YSFamilyDynamic.familyDynamicWithAttributes(family_dynamic as! NSDictionary)
                        lst_family_dynamic.append(familyDynamic)
                    }
                    
                    // 评委/指导老师评论列表
                    for parent_info in resp_lst_parent_info! {
                        if parent_info as? NSDictionary == nil {
                            continue
                        }
                        let parentInfo = YSParentInfo.parentInfoWithAttributes(parent_info as! NSDictionary)
                        lst_parent_info.append(parentInfo)
                    }
                    

                }
                
                block(lst_family_dynamic, lst_parent_info, nil)
            })
            
        }, params: ["a", "list", "uid", uid, "loginkey", loginkey, "start", "\(startIndex)", "num", "\(num)"])
    }
}

/** 家庭动态 */
class YSFamilyDynamic: NSObject {
    
    var update_time_year: String! // 更新年份
    var update_time_month_day: String! // 更新的月份和号数
    var lst_picture: [String]! // 照片URL列表
    var content: String! // 内容
    var video_url: String! // 视频URL
    var video_img_url: String! // 视频封面图URL
    
    class func familyDynamicWithAttributes(attributes: NSDictionary) -> YSFamilyDynamic {
        return YSFamilyDynamic().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSFamilyDynamic {
        
        update_time_year = attributes["update_time_year"] as? String
        update_time_month_day = attributes["update_time_month_day"] as? String
        content = attributes["content"] as? String
        video_url = attributes["video_url"] as? String
        video_img_url = attributes["video_img_url"] as? String
        
        lst_picture = [String]()
        if attributes["lst_picture"] as? NSArray != nil {
            for pictureUrl in attributes["lst_picture"] as! NSArray {
                if pictureUrl as? String == nil {
                    continue
                }
                lst_picture.append(pictureUrl as! String)
            }
        }
        
        return self
    }
    
    /** 发送家庭动态 */
    class func postFamilyDynamic(content: String?, videoFil: String?, imagesName: [String]?, block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        var postParams: [String] = ["a", "add", "uid", uid, "loginkey", loginkey]
        if content != nil {
            postParams = postParams + ["content", content!]
        }
        
        if videoFil != nil {
            postParams = postParams + ["videoFil", videoFil!]
        }
        
        if imagesName != nil {
            let imageIndex = ["picOneFil", "picTwoFil", "picThreeFil", "picFourFil", "picFiveFil", "picSixFil"]
//            for (index, imageName) in enumerate(imagesName!) {
//                postParams = postParams + [imageIndex[index], imageName]
//            }
            for index in 0..<imagesName!.count {
                let imageName = imagesName![index]
                postParams = postParams + [imageIndex[index],imageName]
            }
            
            
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/familyDynamic", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                    block(errorMsg!)
                    return
                }
                
                block(nil)
            })
            
        }, params: postParams)
    }
}

/** 父母信息 */
class YSParentInfo: NSObject {
    
    var avatar: String! // 头像
    var birth: String! // 出生日期
    var status: NSNumber! // 0为正常，1为待审核，其他为未知
    var uid: String! // 用户ID
    var update_time: NSNumber! // 该行记录插入或更新的时间
    var realname: String! // 姓名
    var piid: String! // 父母信息ID
    var type: NSNumber! // 父母标志，0为爸爸，1为妈妈
    
    class func parentInfoWithAttributes(attributes: NSDictionary) -> YSParentInfo {
        return YSParentInfo().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSParentInfo {
        
        avatar = attributes["avatar"] as? String
        birth = attributes["birth"] as? String
        status = attributes["status"] as? NSNumber
        uid = attributes["uid"] as? String
        update_time = attributes["update_time"] as? NSNumber
        realname = attributes["realname"] as? String
        piid = attributes["piid"] as? String
        type = attributes["type"] as? NSNumber
        
        return self
    }
    
    /** 更新父母信息 */
    class func updateParentInfo(realname: String, birth: String, type: Int, block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/parentInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001, 1001, 2001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 3001:
                    errorMsg = "请上传头像"
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
            
        }, params: ["a", "update", "uid", uid, "loginkey", loginkey, "realname", realname, "birth", birth, "type", "\(type)"])
    }
    
    /** 获取父母信息 */
    class func fetchParentInfo(piid: String, block: ((YSParentInfo!, String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        let cacheKey = uid + "parentInfo" + piid
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/parentInfo", cacheKey: cacheKey, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001, 1001, 2001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 3001:
                    errorMsg = "请上传头像"
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
                
                let parentInfo = YSParentInfo.parentInfoWithAttributes(data!)

                
                block(parentInfo, nil)
            })
            
        }, params: ["a", "one", "uid", uid, "loginkey", loginkey, "piid", piid])
    }
    
    /** 增加或更新父母头像 */
    class func updateParentAvatar(piid: String, filename: String, block: ((String!)-> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/parentInfo", cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 9000, 9001, 1001, 2001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 3001:
                    errorMsg = "请上传头像"
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
            
        }, params: ["a", "updateAvatar", "uid", uid, "loginkey", loginkey, "piid", piid, "filename", filename])
    }
}
