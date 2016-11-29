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

class fe_http_post_handler:NSObject {
    
    var prepare_callback:fe_http_post_prepare_callback_t!

    var progress_callback:fe_http_post_progress_callback_t!
    
    var finish_callback:fe_http_post_finish_callback_t!
    
    var httpContext:UnsafeMutablePointer<fe_sync_http_post_context>!
    
    var url:String!

    var cacheHit = 0

    var content_text:String!

    var content_data:NSData!

    var content_jsonObj:NSDictionary!

    var cancelFlag = 0;
    
    var cacheKey:String!
    
    func cancel() {
        cancelFlag = 1
    }
    
    func saveCache() {
        
        if nil != self.content_jsonObj && nil != self.cacheKey {
            feSetJson("http_post_cache", key: cacheKey, jsonValue: self.content_jsonObj)
        }

    }
    
    
    
}

@asmname("fe_http_post_call_back") func fe_http_post_call_back( ctx:UnsafeMutablePointer<fe_sync_http_post_context> )->() {
    
    let handler:fe_http_post_handler = unsafeBitCast(ctx.memory.udata, fe_http_post_handler.self)

    if 1 == handler.cancelFlag {
        ctx.memory.status = FE_HTTP_STATUS_CANCEL
        return
    }

    if nil != handler.progress_callback {
        handler.progress_callback(handler)
        return
    }
    
}


/*

cbFlag 
0: cache hit 后，网络返回后也会回调
1: cache hit 后，网络返回后不会回调
*/
private func fe_async_http_post_json(url:String, cacheKey:String!, cbFlag:Int, prepare_callback:fe_http_post_prepare_callback_t!, progress_callback:fe_http_post_progress_callback_t!, finish_callback:fe_http_post_finish_callback_t!,memsize:Int, timeout:Int, params:[String])->(fe_http_post_handler) {


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
    
    if nil != cacheKey {
        
        handler.content_jsonObj = feGetJson("http_post_cache", key: cacheKey)
        handler.cacheKey = cacheKey
        if nil != handler.content_jsonObj {
            handler.cacheHit = 1
        }
        
        if nil != handler.finish_callback && nil != handler.content_jsonObj {
            
            handler.finish_callback(handler)
        }

    }

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

        handler.content_text = fe_http_post(url, handler: handler, memsize: memsize, timeout: timeout, param: params)
    
        if nil != handler.content_text {
            
            handler.content_data = handler.content_text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

        }

        if nil != handler.content_data {

            handler.content_jsonObj = try! NSJSONSerialization.JSONObjectWithData(handler.content_data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary

        } else {
            handler.content_jsonObj = nil
        }

/*
        if 1 == handler.cacheHit && 1 == cbFlag {
            return
        }
*/
        if nil != handler.finish_callback {
            handler.finish_callback(handler)
        }

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


func fe_async_http_post_json_std(host:String, uri:String, cacheKey:String!, finish_callback:fe_http_post_finish_callback_t!,params:[String])->(fe_http_post_handler){
    
    let url = "http://" + host + uri
    
    return fe_async_http_post_json(url, cacheKey: cacheKey, cbFlag: 0, prepare_callback: nil, progress_callback: nil, finish_callback: finish_callback,memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}

func fe_async_http_post_json_std(host:String, uri:String, cacheKey:String!, cbFlag:Int, finish_callback:fe_http_post_finish_callback_t!, params:[String])->(fe_http_post_handler) {
    
    let url = "http://" + host + uri
    
    return fe_async_http_post_json(url, cacheKey: cacheKey, cbFlag: cbFlag, prepare_callback: nil, progress_callback: nil, finish_callback: finish_callback,memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}

func fe_async_http_post_json_std(url:String, cacheKey:String!, finish_callback:fe_http_post_finish_callback_t!,params:[String])->(fe_http_post_handler) {
    
    return fe_async_http_post_json(url, cacheKey: cacheKey, cbFlag: 0,prepare_callback: nil, progress_callback: nil, finish_callback: finish_callback,memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}




func fe_async_http_post_json_std(url:String, cacheKey:String!, cbFlag:Int, prepare_callback:fe_http_post_prepare_callback_t!, finish_callback:fe_http_post_finish_callback_t!,params:[String])->(fe_http_post_handler) {
    
    return fe_async_http_post_json(url, cacheKey: cacheKey, cbFlag: cbFlag, prepare_callback: prepare_callback, progress_callback: nil, finish_callback: finish_callback,memsize: Int(fe_http_default_content_lenght), timeout: Int(fe_http_default_timeout_ms), params: params)
    
}












