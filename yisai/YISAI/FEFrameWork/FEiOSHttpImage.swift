//
//  FEiOSHttpImage.swift
//  FECoreHttp
//
//  Created by apps on 15/5/2.
//  Copyright (c) 2015年 apps. All rights reserved.
//

import Foundation
import ImageIO
import UIKit

let FE_IMAGE_CACHE_EMPTY         = 0
let FE_IMAGE_CACHE_HIT           = 1
let FE_IMAGE_CACHE_FETCHING      = 2
let FE_IMAGE_CACHE_FETCH_CANCEL  = 3

let FE_MAX_HTTP_IMAGE_FETCH_TRY_TIMES = 3

class FEImageCacheObject {

    var image:UIImage!
    var status:Int
    var tryTimes:Int

    init() {
        status = FE_IMAGE_CACHE_EMPTY
        tryTimes = 0
        image = nil
    }

}

public class FEiOSHttpImageHandler {

    public var httpError:Int32
    public var httpResponse:Int
    public var image:UIImage!
    public var httpSucceed:Bool = false

    public init() {
        httpResponse = 0;
        httpError = FE_HTTP_ERROR_NONE
    }

    public func getErrorString()->(String) {
        return get_fe_http_err_string(httpError)
    }

}

public class FEiOSHttpImage {

    var imageCache:[String:FEImageCacheObject] = Dictionary()

    var currentTask:[String:[String]] = Dictionary()

    var taskLock:NSLock
    
    /*
    这个回调 block 可用于当一个 cell 的 图片下载完成后，刷新当前可视的cell
    也可以用在普通的UI异步加载图片
    加载这个 cell 的图片 及 触发其他cell去产生http请求去加载图片
    因为会有一种情境是当前http任务超过任务数量，会拒绝发起http请求
    该block被回调时会在UI线程中

    在 View 退出时最好将 block 设置为 nil
    */
    public var refreshCallBackInUIThread:( ()->() )!
    
    
    var tag:String

    public func setTag(inTag:String) {

        self.tag = inTag

    }

    public init() {
        taskLock = NSLock()
        tag = "StdTag"
    }

    deinit {
        print("## deinit FEiOSHttpImage\n", terminator: "")
    }
    
    
    func regTaskUrl(url:String) {
    
        taskLock.lock()
        
        var urlArray = currentTask[tag]

        if nil == urlArray {
            urlArray = [String]()
            urlArray?.append(url)
            currentTask[tag] = urlArray
            taskLock.unlock()
            return
        }

        var findUrl:Bool = false

        for urlInArray in urlArray! {
        
            if urlInArray == url {
                findUrl = true
            }
        
        }
        
        if true != findUrl{
            urlArray?.append(url)
        }
        
        currentTask[tag] = urlArray
        
        taskLock.unlock()

    }

    
    func unRegTaskUrl(url:String) {
        
        taskLock.lock()
        
        var urlArray = currentTask[tag]
        
        if nil == urlArray {
            currentTask[tag] = [String]()
        }
        
        var index:Int = 0

        for urlInArray in urlArray! {
            
            if urlInArray == url {
                urlArray?.removeAtIndex(index)
            }
         
            index++
        }

        currentTask[tag] = urlArray
        
        taskLock.unlock()
        
    }


    public func interruptTaskUrl(url:String) {
        
        taskLock.lock()
        
        var urlArray = currentTask[tag]
        
        if nil == urlArray {
            currentTask[tag] = [String]()
        }
        
        var index:Int = 0
        
        for urlInArray in urlArray! {

            if urlInArray == url {
//                fe_interrupt_fetch_http_task(urlInArray)
                urlArray?.removeAtIndex(index)
            }
            
            index++
        }
        
        currentTask[tag] = urlArray
        
        taskLock.unlock()
        
    }

    
    public func interruptTaskAllUrl() {
    
        taskLock.lock()
    
        let urlArray = currentTask[tag]
        
        if nil == urlArray {
            taskLock.unlock()
            return
        }
        
//        for urlInArray in urlArray! {
////            fe_interrupt_fetch_http_task(urlInArray)
//        }

        taskLock.unlock()

    }

    
    func getDefaultImage(defaultImageName:String!)->(UIImage?) {

        if nil == defaultImageName {
            return nil
        }
        
        return UIImage(named:defaultImageName)
    }
    
    func loadImageInCache(url:String!)->(UIImage!,Int32) {

        if nil == url {
            return (nil,FE_HTTP_CACHE_ZERO_FILE)
        }

        let ctx = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))
        
        let cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.cache_file_path))
        
        let downloadFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.download_file_path))

        let cache_status = fe_http_cache_status(ctx)
        
        fe_multi_http_fetch_release(ctx)

        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_1 {
            print("FEiOSHttpImageHandler:loadImageInCache cache_status[\(cache_status)] url[\(url)] downloadFile[\(downloadFile)] cacheFile[\(cacheFile)]", terminator: "")
        }

        if FE_HTTP_CACHE_HIT != cache_status {
            return (nil,cache_status)
        }
        
        if nil == cacheFile {
            return (nil,FE_HTTP_CACHE_ZERO_FILE)
        }
        
        let image = UIImage(contentsOfFile:cacheFile!)
        
        if nil == image {
            unlink(cacheFile!)
            return (nil,cache_status)
        }
        
        return (image,cache_status)
        
    }

    public func asyncHttpImageInUIThread(url:String!,defaultImageName:String!,finishCallbackInUIThread:((FEiOSHttpImageHandler)->Void)!)->(UIImage?) {

        if url == nil || url == "" {
            return nil
        }

        var imageCacheObject:FEImageCacheObject! = imageCache[url]

        if nil == imageCacheObject {

            imageCacheObject = FEImageCacheObject()
            imageCacheObject.image = nil
            imageCacheObject.status = FE_IMAGE_CACHE_EMPTY
            imageCacheObject.tryTimes = 0

            imageCache[url] = imageCacheObject
            
        }

        if imageCacheObject.tryTimes >= FE_MAX_HTTP_IMAGE_FETCH_TRY_TIMES {
            if imageCacheObject.tryTimes >= FE_MAX_HTTP_IMAGE_FETCH_TRY_TIMES {
                print("asyncHttpImageInUIThread url[\(url)] tryTimes[\(imageCacheObject.tryTimes)]", terminator: "")
            }
        }

        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            if FE_IMAGE_CACHE_HIT == imageCacheObject.status &&  nil != imageCacheObject.image {
                print("asyncHttpImageInUIThread url[\(url)] FE_IMAGE_CACHE_HIT", terminator: "")
            }
        }
        
        if FE_IMAGE_CACHE_HIT == imageCacheObject.status &&  nil != imageCacheObject.image {
            return imageCacheObject.image
        }

        
        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            if FE_IMAGE_CACHE_FETCH_CANCEL == imageCacheObject.status {
                print("asyncHttpImageInUIThread url[\(url)] FE_IMAGE_CACHE_FETCH_CANCEL", terminator: "")
            }
        }
        
        if FE_IMAGE_CACHE_FETCH_CANCEL == imageCacheObject.status {
            return getDefaultImage(defaultImageName)
        }

        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            if FE_IMAGE_CACHE_FETCHING == imageCacheObject.status {
                print("asyncHttpImageInUIThread url[\(url)] FE_IMAGE_CACHE_FETCHING", terminator: "")
            }
        }
/*
        if FE_IMAGE_CACHE_FETCHING == imageCacheObject.status {
            return getDefaultImage(defaultImageName)
        }
*/
        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            if FE_IMAGE_CACHE_EMPTY == imageCacheObject.status {
                print("asyncHttpImageInUIThread url[\(url)] FE_IMAGE_CACHE_EMPTY", terminator: "")
            }
        }

        if FE_IMAGE_CACHE_EMPTY == imageCacheObject.status {

            let (image,cache_status) = loadImageInCache(url)
            
            if nil != image {
                
                if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
                    print("asyncHttpImageInUIThread loadFileCache url[\(url)] FE_IMAGE_CACHE_HIT", terminator: "")
                }
                
                imageCacheObject.status = FE_IMAGE_CACHE_HIT
                imageCacheObject.image = image
                
                return imageCacheObject.image
                
            } else {
            
                if FE_HTTP_CACHE_HIT == cache_status {
                    imageCacheObject.tryTimes++
                    if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
                        print("asyncHttpImageInUIThread try to fetching [\(url)] tryTimes[\(imageCacheObject.tryTimes)]", terminator: "")
                    }
                }

            }

            imageCacheObject.status = FE_IMAGE_CACHE_FETCHING

            if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
                print("asyncHttpImageInUIThread:[\(url)] FE_IMAGE_CACHE_FETCHING", terminator: "")
            }

        }

        let http_finish_callback:fe_multi_finish_cb_t = {
            (handler:fe_multi_http_fetch_handler)->() in

            self.unRegTaskUrl(url)

            if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
                print("asyncHttpImageInUIThread:http_finish_callback [\(url)] downloadFile[\(handler.downloadFile)] cacheFile[\(handler.cacheFile)] httpSucceed[\(handler.httpSucceed)] httpError[\(get_fe_http_err_string(handler.httpError))]", terminator: "")
            }

            dispatch_async ( dispatch_get_main_queue(), {

                if true != handler.httpSucceed {
                    
                    if imageCacheObject.tryTimes >= FE_MAX_HTTP_IMAGE_FETCH_TRY_TIMES {
                        imageCacheObject.status = FE_IMAGE_CACHE_FETCH_CANCEL
                    }
                    
                    imageCacheObject.tryTimes++
                    
                    return
                    
                }

                imageCacheObject.status = FE_IMAGE_CACHE_EMPTY

                let (image,cache_status) = self.loadImageInCache(url)
                
                if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
                    if nil != image && FE_HTTP_CACHE_HIT == cache_status{
                        print("asyncHttpImageInUIThread:http_finish_callback [\(url)] cacheFile[\(handler.cacheFile)] loadImageInCache Succeed", terminator: "")
                    }
                }
                
                let feiOSHttpImageHandler = FEiOSHttpImageHandler()
                
                feiOSHttpImageHandler.httpError = handler.httpError
                feiOSHttpImageHandler.httpResponse = handler.httpRespond
                feiOSHttpImageHandler.httpSucceed = handler.httpSucceed
                
                if nil != image && FE_HTTP_CACHE_HIT == cache_status {
                    feiOSHttpImageHandler.image = image
                    imageCacheObject.image = image
                    imageCacheObject.status = FE_IMAGE_CACHE_HIT
                }
    
                if nil != finishCallbackInUIThread {
                    finishCallbackInUIThread(feiOSHttpImageHandler)
                }

                if nil != self.refreshCallBackInUIThread {
                    self.refreshCallBackInUIThread()
                }

            })

        }

        if fe_http_fetch_debug_level > FE_HTTP_FETCH_DEBUG_LEVEL_0 {
            print("asyncHttpImageInUIThread:fe_multi_http_fetch url[\(url)]", terminator: "")
        }
        
        self.regTaskUrl(url)

        fe_multi_http_fetch(url, prepare_cb:nil, progress_cb:nil, finish_cb:http_finish_callback)
        
        return getDefaultImage(defaultImageName)

    }


    public func asyncHttpImageEasy(imageView:UIImageView!, url:String!, defaultImageName:String!) {
        
        if nil == imageView {
            return
        }
    
        if nil == url {
            return
        }
    

        imageView.image = asyncHttpImageInUIThread(url, defaultImageName:defaultImageName, finishCallbackInUIThread: {
            (handler:FEiOSHttpImageHandler) in
            imageView.image = handler.image
            
        })

    }

    
}

