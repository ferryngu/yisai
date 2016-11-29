//
//  FESyncHttpGet.swift
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

import Foundation


func fe_http_get_string(url:String, handler:AnyObject!, memsize:Int, timeout:Int, params:[String]!)->String!
{
    let ctx = fe_http_get_context_init(url, memsize, timeout)
    
    if nil != handler {
        ctx.memory.udata = unsafeBitCast(handler, UnsafeMutablePointer<Void>.self)
    }

    var i = 0
    
    if 0==params.count || 0 != params.count%2 {
        return nil
    }

    if nil != params {

        for i=0; i<params.count; i+=2 {
            fe_http_set_get_param(ctx,params[i],params[i+1]);
        }
    
    }

    fe_http_get(ctx)
    
    if ctx.memory.content_lenght <= 0 {
        return nil
    }
    
    let text_content:String! = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.buffer))
    
    fe_http_get_context_release(ctx)
    
    return text_content

}


func fe_http_get_json_std(url:String, params:[String]!) -> NSDictionary! {

    let content_text = fe_http_get_string(url, handler: nil, memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms),params: params)

    var content_data:NSData!

    var content_jsonObj:NSDictionary!

    if nil != content_text {
        content_data = content_text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    }

    if nil != content_data {
    
        try! content_jsonObj = NSJSONSerialization.JSONObjectWithData(content_data, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary

    }

    return content_jsonObj

}

/*
例子
let json = fe_http_get_json_std(host:"ip:port", uri:"testuri", ["aa","b&b","cc","测试"])
*/
func fe_http_get_json_std(host host:String, uri:String,params:[String]) -> NSDictionary!  {
    
    let url = "http://" + host + uri
    
    let content_jsonObj = fe_http_get_json_std(url, params: params)
    
    return content_jsonObj

}
