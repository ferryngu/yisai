//
//  FEAsyncHttpPost.swift
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

import Foundation

typealias fe_http_post_prepare_callback_t = (fe_http_post_handler)->()

typealias fe_http_post_progress_callback_t = (fe_http_post_handler)->()

typealias fe_http_post_finish_callback_t = (fe_http_post_handler)->()

class fe_http_post_handler {
    
    var prepare_callback:fe_http_post_prepare_callback_t!

    var progress_callback:fe_http_post_progress_callback_t!
    
    var finish_callback:fe_http_post_finish_callback_t!
    
    var httpContext:UnsafeMutablePointer<fe_sync_http_post_context>!
    
    var url:String!

    var content_text:String!

    var content_data:NSData!

    var content_jsonObj:NSDictionary!

    var httpError:Int32
    var httpSucceed:Bool = false
    var httpRespond:Int
    
    init () {
        httpError = FE_HTTP_ERROR_OTHER
        httpRespond = 0
    }

}

let fe_http_post_swift_cb:@convention(c) (ctx:UnsafeMutablePointer<fe_sync_http_post_context>) -> Void = {
    (ctx:UnsafeMutablePointer<fe_sync_http_post_context>) -> Void in

    let handler:fe_http_post_handler = unsafeBitCast(ctx.memory.udata, fe_http_post_handler.self)

}

private func fe_async_http_post_json(url:String, prepare_callback:fe_http_post_prepare_callback_t!, progress_callback:fe_http_post_progress_callback_t!, finish_callback:fe_http_post_finish_callback_t!,memsize:Int, timeout:Int, params:[String])->(fe_http_post_handler) {

    let handler = fe_http_post_handler()
    
    handler.url = url

    handler.prepare_callback = prepare_callback
    handler.progress_callback = progress_callback
    handler.finish_callback = finish_callback
    handler.content_text = nil
    handler.content_data = nil
    handler.content_jsonObj = nil
    
    if nil != handler.prepare_callback {
        handler.prepare_callback(handler)
    }

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        
        handler.content_text = fe_http_post(url, handler: handler, memsize: memsize, timeout: timeout, param: params)

        if nil != handler.content_text {
            handler.content_data = handler.content_text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        }
        
        if nil != handler.content_data {
            
            do {
                try  handler.content_jsonObj = NSJSONSerialization.JSONObjectWithData(handler.content_data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
            } catch {
                handler.content_jsonObj = nil
            }
            
        }

        handler.finish_callback(handler)

        return

    })

    return handler

}


/*
异步 post
例子:

let http_progress_callback:fe_http_post_prepare_callback_t = {
   (handler:fe_http_post_handler)->() in

}

let http_finish_callback:fe_http_post_finish_callback_t = {
   (handler:fe_http_post_handler)->() in

}

fe_async_http_post_json_std("ip:port", uri:"/interface", prepare_callback:http_progress_callback,finish_callback:http_finish_callback, params:["k1","v1","k2","v2","k3","v3"])
*/


func fe_async_http_post_json_std(host:String!, uri:String, cacheKey:String!, prepare_callback:fe_http_post_prepare_callback_t!, finish_callback:fe_http_post_finish_callback_t!,params:[String]!)->(fe_http_post_handler){

    let url = "http://" + host + uri
    
    return fe_async_http_post_json(url, prepare_callback:prepare_callback, progress_callback:nil, finish_callback:finish_callback, memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}


func fe_async_http_post_json_std(url:String!, prepare_callback:fe_http_post_prepare_callback_t!, finish_callback:fe_http_post_finish_callback_t!,params:[String]!)->(fe_http_post_handler) {

    return fe_async_http_post_json(url, prepare_callback: prepare_callback, progress_callback: nil, finish_callback: finish_callback,memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}
