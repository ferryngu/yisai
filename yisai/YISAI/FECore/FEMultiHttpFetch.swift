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

var fe_multi_tasks:NSMutableDictionary = NSMutableDictionary()

class fe_multi_http_fetch_handler {
    
    var prepare_callback:fe_multi_prepare_cb_t!
    
    var progress_callback:fe_multi_progress_cb_t!
    
    var finish_callback:fe_multi_finish_cb_t!
    
    var url:String!
    
    var cacheFile:String!
    
    var downloadFile:String!
    
    var cacheHit = 0
    
    var finish = 0

    var reuseId:String!

    deinit {
        
     //print("###################### deinit fe_multi_http_fetch_handler  ######################")
        
    }
    
}

@asmname("fe_multi_http_fetch_process_swift_cb") func fe_multi_http_fetch_process_swift_cb(ctx:UnsafeMutablePointer<fe_multi_http_fetch_context>)->() {
    
    let url:String! = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.url))
    
    if nil == url {
        print("ctx err\n")
    }

    let handler_chain:NSMutableArray! = fe_multi_tasks.objectForKey(url) as? NSMutableArray
    
    if nil == handler_chain {
        return
    }

    for obj in handler_chain {

        let handler = obj as? fe_multi_http_fetch_handler
        
        if nil == handler {
            continue
        }

        if nil != handler!.progress_callback {
            handler!.progress_callback(handler!)
        }

    }

}


@asmname("fe_multi_http_fetch_finish_swift_cb") func fe_multi_http_fetch_finish_swift_cb(ctx:UnsafeMutablePointer<fe_multi_http_fetch_context>)->() {

    let url:String! = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.url))
    
    if nil == url {
        print("ctx err\n")
    }
    
    let handler_chain:NSMutableArray! = fe_multi_tasks.objectForKey(url) as? NSMutableArray
    
    if nil == handler_chain {
        return
    }

    for obj in handler_chain {

        let handler = obj as? fe_multi_http_fetch_handler
        
        if nil == handler {
            continue
        }

        if ctx.memory.status & FE_HTTP_STATUS_FINISH != 0 && 0 != ctx.memory.status & FE_HTTP_STATUS_ERROR  {
            //跳过失败的请求
            continue
        }

        if nil != handler!.finish_callback {
            handler!.finish_callback(handler!)
        }

    }

    fe_multi_http_fetch_release(ctx)
    fe_multi_tasks.removeObjectForKey(url)
    
}


func fe_multi_http_fetch(url:String, reuseId:String!, prepare_cb:fe_multi_prepare_cb_t!, progress_cb:fe_multi_progress_cb_t!, finish_cb:fe_multi_finish_cb_t!)->() {

    dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        
        if url.characters.count == 0 {
            return
        }
        
        var handler_chain:NSMutableArray! = fe_multi_tasks.objectForKey(url) as? NSMutableArray
        
        if nil == handler_chain {
        
            let ctx = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))

            let handler = fe_multi_http_fetch_handler()
            
            handler.url = url
            
            handler.prepare_callback = prepare_cb
            handler.progress_callback = progress_cb
            handler.finish_callback = finish_cb
            
            handler.cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.cache_file_path))
            
            handler.downloadFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.download_file_path))
            
            handler.reuseId = reuseId
        
            handler_chain = NSMutableArray()
            handler_chain!.addObject(handler)
            fe_multi_tasks.setObject(handler_chain!, forKey: url)
//print("## start url \(url) #####\n")
            let ret = fe_start_fetch_http_task(ctx)

            if 0 != ret {
//print("# #err# # fe_start_fetch_http_task ret = \(ret)\n")
                
                fe_multi_http_fetch_release(ctx)
                fe_multi_tasks.removeObjectForKey(url)
            }
            
            return

        }
        
        if nil != reuseId {
            
            for obj in handler_chain {
                
                let handler = obj as? fe_multi_http_fetch_handler
                
                if nil == handler || nil == handler!.reuseId {
                    continue
                }
                
                if handler!.reuseId == reuseId {
//                    print("same reuseId \(reuseId)\n")
                    return
                }

            }

        }

        let handler = fe_multi_http_fetch_handler()
        
        handler.url = url
        
        handler.prepare_callback  = prepare_cb
        handler.progress_callback = progress_cb
        handler.finish_callback   = finish_cb

        let ctx = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))
        handler.cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.cache_file_path))
        handler.downloadFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.download_file_path))
        fe_multi_http_fetch_release(ctx)

        handler.reuseId = reuseId
        
        handler_chain!.addObject(handler)
        fe_multi_tasks.setObject(handler_chain!, forKey: url)
    
    })

}

