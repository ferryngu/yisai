//
//  YSPay.swift
//  YISAI
//
//  Created by Yufate on 15/8/8.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSPay: NSObject {
   
    /** 获取微信支付订单 */
    class func fetchWXPayOrderByCrid(crid: String,version: String, resp block:((YSWXPayOrder!, String!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        let path = "/pay"
        var params = ["a", "tenpay", "uid", uid, "loginkey", loginkey, "crid", crid] as [String]
        
        if (version != "")
        {
            params += ["version", version]
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
//                println(resp)
                if resp == nil {
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
                case -1:
                    errorMsg = "操作失败"
                case 8001:
                    errorMsg = "视频未上传成功，不能支付"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 5001:
                    if ysApplication.loginUser.role_type == "1"
                    {
                        errorMsg = "该赛事由老师发起，将由老师支付"
                    }
                    else
                    {
                        errorMsg = "该赛事由学生发起，将由学生支付"
                    }
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002, 3001:
                    errorMsg = "订单信息错误"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    block(nil, nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, "数据异常")
                    return
                }
                
                let tenpay = data!["tenpay"] as? NSDictionary
                let oid = data!["oid"] as? String
                if tenpay == nil || oid == nil {
                    block(nil, nil, "数据异常")
                }
                
                let resp_order = YSWXPayOrder.orderWithAttributes(tenpay!)
                block(resp_order, oid, nil)
            })
        }, params: params)
    }
    
    /** 获取支付宝支付订单 */
    class func fetchAliPayOrderByCrid(crid: String,version: String, resp block:((String!, String!, String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
         
        
        
        let path = "/pay"
        var params = ["a", "alipay", "uid", uid, "loginkey", loginkey, "crid", crid] as [String]
        
        if (version != "")
        {
            params += ["version", version]
        }
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
//                println(resp)
                if resp == nil {
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
                case -1:
                    errorMsg = "操作失败"
                case 8001:
                    errorMsg = "视频未上传成功，不能支付"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 5001:
                    if ysApplication.loginUser.role_type == "1"
                    {
                        errorMsg = "该赛事由老师发起，将由老师支付"
                    }
                    else
                    {
                       errorMsg = "该赛事由学生发起，将由学生支付"
                    }
                case 9004:
                    reLogin()
                    return
                case 1001, 1002, 2001, 2002, 3001:
                    errorMsg = "订单信息错误"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    
                     block(nil, nil, errorMsg)
                    return
                }
                
                let data = resp["data"] as? NSDictionary
                if data == nil {
                    block(nil, nil, "数据异常")
                    return
                }
                
                let orderInfo = data!["orderInfo"] as? String
                let oid = data!["oid"] as? String
                if orderInfo == nil || oid == nil {
                    block(nil, nil, "数据异常")
                }
                
                block(orderInfo, oid, nil)
            })
        }, params: params)
    }
    
    /** 支付宝支付同步通知 */
    class func updateAlipayStatus(oid: String, result_status: String, result: String, resp block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/order/payCallBack"
        let params = ["a", "alipay", "uid", uid, "loginkey", loginkey, "oid", oid, "result_status", result_status, "result", result] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
//                println(resp)
                if resp == nil {
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
                case -1:
                    errorMsg = "操作失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 9005, 9008:
                    errorMsg = "支付状态错误"
                case 1001, 1002, 3001, 3002:
                    errorMsg = "订单信息错误"
                case 2001:
                    errorMsg = "订单支付失败"
                case 2002:
                    errorMsg = "订单已支付"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    return
                }
                
                block(errorMsg)
            })
        }, params: params)
    }
    
    /** 微信支付同步通知 */
    class func updateWXPayStatus(oid: String, result: String, resp block:((String!) -> Void)!) {
        
        let uid = ysApplication.loginUser.uid
        let loginkey = ysApplication.loginUser.loginKey
        
        if uid == nil || loginkey == nil {
            return
        }
        
        let path = "/order/payCallBack"
        let params = ["a", "tenpay", "uid", uid, "loginkey", loginkey, "oid", oid, "result", result] as [String]
        
        fe_async_http_post_json_std(YSAPIHOST, uri: path, cacheKey: nil, prepare_callback: nil, finish_callback: { (handler: fe_http_post_handler) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if block == nil {
                    return
                }
                
                let resp = handler.content_jsonObj
                
//                println(resp)
                if resp == nil {
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
                case -1:
                    errorMsg = "操作失败"
                case 9000, 9001:
                    errorMsg = "参数错误"
                case 9002, 9003:
                    errorMsg = "用户信息错误"
                case 9004:
                    reLogin()
                    return
                case 9009:
                    errorMsg = "支付状态错误"
                case 1001, 1002, 3001, 3002:
                    errorMsg = "订单信息错误"
                case 2001:
                    errorMsg = "订单支付失败"
                case 2002:
                    errorMsg = "订单已支付"
                default:
                    errorMsg = "默认处理"
                    break
                }
                if errorMsg != nil {
                    return
                }
                
                block(errorMsg)
            })
        }, params: params)
    }
}

/** 微信支付订单数据 */
class YSWXPayOrder: NSObject {
    
    var prepayid: String! // 预支付交易会话ID，微信返回的支付交易会话ID
    var sign: String! // 签名，详见签名生成算法
    var package: String! // 扩展字段，暂填写固定值Sign=WXPay
    var noncestr: String! // 随机字符串，不长于32位。推荐随机数生成算法
    var appid: String! // 公众账号ID，微信分配的公众账号ID
    var timestamp: String! // 时间戳，请见接口规则-参数规定
    var partnerid: String! // 商户号，微信支付分配的商户号
    
    class func orderWithAttributes(attributes: NSDictionary) -> YSWXPayOrder {
        return YSWXPayOrder().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: NSDictionary) -> YSWXPayOrder {
        
        prepayid = attributes["prepayid"] as? String
        sign = attributes["sign"] as? String
        package = attributes["package"] as? String
        noncestr = attributes["noncestr"] as? String
        appid = attributes["appid"] as? String
        timestamp = attributes["timestamp"] as? String
        partnerid = attributes["partnerid"] as? String
        
        return self
    }
}
