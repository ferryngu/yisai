//
//  FEMultiHttpFetch.swift
//  FECoreHttp
//
//  Created by apps on 15/7/25.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation

typealias fe_multi_prepare_cb_t  = (fe_multi_http_fetch_handler)->()

typealias fe_multi_progress_cb_t = (fe_multi_http_fetch_handler)->()

typealias fe_multi_finish_cb_t   = (fe_multi_http_fetch_handler)->()

class fe_multi_http_fetch_handler {
    
    var prepare_callback:fe_multi_prepare_cb_t!
    
    var progress_callback:fe_multi_progress_cb_t!
    
    //var finish_callback:fe_multi_finish_cb_t!
    
    var url:String!
    
    var cacheFile:String!
    
    var downloadFile:String!
    
    var httpError:Int32

    var httpSucceed:Bool = false

    var httpRespond:Int

    var finish_callback_chain:Array<fe_multi_finish_cb_t>!

    init () {
        httpError = FE_HTTP_ERROR_NONE
        httpRespond = 0
    }

    /*
    deinit {
        print("#### deinit fe_multi_http_fetch_handler ####")
    }
    */

}


var MultiHttphandlerDictionary:[String:fe_multi_http_fetch_handler] = Dictionary()

var MultiHttphandlerDictionaryLock =  NSLock()

let fe_multi_http_fetch_progress_callback:@convention(c) (UnsafeMutablePointer<fe_multi_http_fetch_context>) -> Void = {
    (ctx) -> Void in
    
    return
}

let fe_multi_http_fetch_finish_callback:@convention(c) (UnsafeMutablePointer<fe_multi_http_fetch_context>) -> Void = {
    (ctx:UnsafeMutablePointer<fe_multi_http_fetch_context>) -> Void in

    if nil == ctx.memory.udata {
        fe_multi_http_fetch_release(ctx)
        return
    }

    let handler:fe_multi_http_fetch_handler = unsafeBitCast(ctx.memory.udata, fe_multi_http_fetch_handler.self)

    if  0 != ctx.memory.http_status & FE_HTTP_STATUS_ERROR {

        handler.httpError = ctx.memory.http_error

        handler.httpRespond = ctx.memory.http_respond

    } else {

        handler.httpSucceed = true

    }
    
    MultiHttphandlerDictionaryLock.lock()

    if nil == handler.finish_callback_chain {

        MultiHttphandlerDictionary[handler.url] = nil

        fe_multi_http_fetch_release(ctx)
        
        MultiHttphandlerDictionaryLock.unlock()
        
        return
    }

    var n = 0
    
    for finish_callback in handler.finish_callback_chain {
        
        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            print("fe_multi_http_fetch_finish_callback finish_callback_chain[\(handler.url)] num[\(n)]", terminator: "")
        }
        
        n++

        finish_callback(handler)
        
    }

    fe_multi_http_fetch_release(ctx)

    MultiHttphandlerDictionary[handler.url] = nil
    
    MultiHttphandlerDictionaryLock.unlock()
    
    return

}


func fe_multi_http_fetch(url:String, prepare_cb:fe_multi_prepare_cb_t!, progress_cb:fe_multi_progress_cb_t!, finish_cb:fe_multi_finish_cb_t!)->() {
    
    var handler:fe_multi_http_fetch_handler!

    MultiHttphandlerDictionaryLock.lock()
    
    handler = MultiHttphandlerDictionary[url]
    
    if nil != handler {
        
        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            print("fe_multi_http_fetch same url append to finish_callback_chain[\(url)]", terminator: "")
        }
        
        handler.finish_callback_chain.append(finish_cb)

        MultiHttphandlerDictionary[url] = handler
        
        MultiHttphandlerDictionaryLock.unlock()

        return
    }

    
    let ctx = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))

    ctx.memory.http_fetch_progress_call_back = fe_multi_http_fetch_progress_callback
    ctx.memory.http_fetch_finish_call_back = fe_multi_http_fetch_finish_callback

    ctx.memory.resume_flag = 1;
    
    handler = fe_multi_http_fetch_handler()

    MultiHttphandlerDictionary[url] = handler

    ctx.memory.udata = unsafeBitCast(handler, UnsafeMutablePointer<Void>.self)
    
    handler.url = url
    
    handler.prepare_callback = prepare_cb
    handler.progress_callback = progress_cb
    
    
    handler.finish_callback_chain = Array<fe_multi_finish_cb_t>()
    
    handler.finish_callback_chain.append(finish_cb)
    
    handler.cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.cache_file_path))
    
    handler.downloadFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.download_file_path))

    let ret = fe_start_fetch_http_task(ctx)

    if FE_MULTI_HTTP_ADD_TASK_SUCCESS != ret {

        MultiHttphandlerDictionary[url] = nil
        
        fe_multi_http_fetch_release(ctx)

        MultiHttphandlerDictionaryLock.unlock()

        return

    }

    MultiHttphandlerDictionaryLock.unlock()

    return

}

