//
//  FESyncHttpPost.swift
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

import Foundation

func fe_http_post(url:String, handler:AnyObject!, memsize:Int, timeout:Int, param:[String])->String! {
    
    let ctx = fe_http_post_context_init(url, memsize, timeout)

    if nil != handler {
        ctx.memory.udata = unsafeBitCast(handler, UnsafeMutablePointer<Void>.self)
    }

    var i = 0

    if 0==param.count || 0 != param.count%2 {
        return nil
    }

    for i=0; i<param.count; i+=2 {
        fe_http_set_post_param(ctx,param[i],param[i+1]);
    }

    fe_http_post(ctx)

    if ctx.memory.content_lenght <= 0 {
        return nil
    }

    let text_content:String! = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.buffer))

    fe_http_post_context_release(ctx)

    return text_content

}


/*
例子:
let body = fe_http_post_string("http://ip:port/uri",  ["k1","v1","k2","v2","k3","v3"])
*/
func fe_http_post_string(url url:String, params:[String])->String! {
    let text_content:String! = fe_http_post(url, handler: nil, memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), param: params)
    return text_content
}

/*
例子:
let body = fe_http_post_string("ip:port", "uri", ["k1","v1","k2","v2","k3","v3"])
*/
func fe_http_post_string(host host:String, uri:String,params:[String])->String! {

    let url = "http://" + host + uri

    let text_content = fe_http_post_string(url:url, params: params)

    return text_content
}



func fe_http_post_json_std(url:String, params:[String]!) -> NSDictionary! {
    
    let content_text = fe_http_post(url, handler: nil, memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), param: params)
    
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


func fe_http_post_json_std(host host:String, uri:String,params:[String]) -> NSDictionary!  {
    
    let url = "http://" + host + uri
    
    let content_jsonObj = fe_http_post_json_std(url, params: params)
    
    return content_jsonObj
}
