//
//  YSMyFindwork.swift
//  YISAI
//
//  Created by Yufate on 15/7/3.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyFindwork: NSObject {
   
    /** 获取我的作品页 */
    class func fetchMyFindwork(shouldCache: Bool, startIndex: Int!, fetchNum: Int!, resp block: (([YSDiscoveryMainFindWork]!, String!)-> Void)!) {
        
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
        
        let cacheKey = uid + "work" + "listWithUid"
        
        fe_async_http_post_json_std(YSAPIHOST, uri: "/work", cacheKey: shouldCache ? cacheKey : nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
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
                case 1001:
                    errorMsg = "用户信息错误"
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
                
                let lst_findwork = data!["lst_work"] as? [AnyObject]
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
        }, params: ["a", "listWithUid", "uid", uid, "loginkey", loginkey, "start", "\(start)", "num", "\(num)"])
    }
}
