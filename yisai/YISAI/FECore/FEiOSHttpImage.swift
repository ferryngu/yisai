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


func gerIncrementalImage(downloadFile:String)->(UIImage!) {

    let mem_block = fe_mmap(downloadFile)

    if 0 == mem_block.len {

        if nil != mem_block.ptr {

            fe_munmap(mem_block)

        }

        return nil

    }

    let cfdata:CFData! = CFDataCreate(nil, UnsafePointer(mem_block.ptr), Int(mem_block.len))

    if nil==cfdata {
        fe_munmap(mem_block)
        return nil
    }

    let incrementallyImgSource:CGImageSourceRef! = CGImageSourceCreateIncremental(nil)

    CGImageSourceUpdateData(incrementallyImgSource, cfdata, false)

    let imageRef:CGImageRef! = CGImageSourceCreateImageAtIndex(incrementallyImgSource, 0, nil)

    if ( nil==imageRef ) {
        fe_munmap(mem_block)
        return nil
    }

    let image:UIImage! = UIImage(CGImage: imageRef)

    fe_munmap(mem_block)

    return image

}



public func fe_ios_http_image(url:String, defaultImageName:String!, imageView:UIImageView) {

    if nil != defaultImageName {
    
        let defaultImage = UIImage(named:defaultImageName)

        if nil != defaultImage {
            imageView.image = defaultImage
        }

    } else {

        imageView.image = nil

    }
    
    let cache_file_path_buf = fe_http_fetch_cache_file_path_dup(url)
    
    if nil != cache_file_path_buf {
        
        let cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(cache_file_path_buf))
        
        free(cache_file_path_buf)

        let image = UIImage(contentsOfFile:cacheFile!)

        if nil == image {
            unlink(cacheFile!)
            return
        }
        
        if  NSThread.isMainThread() {

            imageView.image = image
            
        } else {
            
            dispatch_async ( dispatch_get_main_queue(), {
                imageView.image = image
            })
            
        }

        return

    }

    let http_finish_callback:fe_multi_finish_cb_t = {
        
        (handler:fe_multi_http_fetch_handler)->() in

        let image = UIImage(contentsOfFile:handler.cacheFile)
        
        dispatch_async ( dispatch_get_main_queue(), {
            imageView.image = image
        })

    }

    fe_multi_http_fetch(url, reuseId: nil, prepare_cb: nil, progress_cb: nil, finish_cb: http_finish_callback)

}


func fe_ios_http_reuse_image(url:String!, defaultImageName:String!, incremental:Int, notifyName:String, indexPath:NSIndexPath)->(UIImage!) {

    if checkInputEmpty(url) {
        return UIImage(named: defaultImageName)
    }

    let ctx = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))
    
    let cacheFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.cache_file_path))

    let downloadFile = String.fromCString(UnsafeMutablePointer<CChar>(ctx.memory.download_file_path))

    
    /*
    return value
    0 not in cache
    1 cache hit
    2 downloading
    */
    let s = fe_http_cache_status(ctx)

    fe_multi_http_fetch_release(ctx)
    
    if 1 == s {
        
        let image = UIImage(contentsOfFile:cacheFile!)

        if nil == image {
            unlink(cacheFile!)
            return nil
        }

        return image

    }

    if 2 == s && incremental>0 {

        let image = gerIncrementalImage(downloadFile!)
        return image
        
    }

    let http_progress_callback:fe_multi_progress_cb_t = {
        (handler:fe_multi_http_fetch_handler)->() in
        
        var info:[NSObject:AnyObject] = Dictionary()
        
        info["indexPath"] = indexPath
        info["url"] = url

        let ctx_tmp = fe_multi_http_fetch_ctx(url, 1, Int(fe_http_default_timeout_ms))
        let s = fe_http_cache_status(ctx_tmp)
        fe_multi_http_fetch_release(ctx_tmp)

        if 2 == s {
            NSNotificationCenter.defaultCenter().postNotificationName(notifyName, object:nil, userInfo:info)
        }

    }

    let http_finish_callback:fe_multi_finish_cb_t = {
        (handler:fe_multi_http_fetch_handler)->() in

        var info:[NSObject:AnyObject] = Dictionary()
        
        info["indexPath"] = indexPath
        info["url"] = url

        NSNotificationCenter.defaultCenter().postNotificationName(notifyName, object:nil, userInfo:info)
        
    }

    var progress_cb_block:fe_multi_progress_cb_t! = nil

    if incremental > 0 {
        
        progress_cb_block = http_progress_callback
        
    }

    fe_multi_http_fetch(url, reuseId: "\(notifyName)_\(indexPath.section)_\(indexPath.row)" , prepare_cb: nil, progress_cb: progress_cb_block, finish_cb: http_finish_callback)
    
    return UIImage(named:defaultImageName)
    
}


public func fe_ios_http_reuse_image(url:String!, defaultImageName:String!, notifyName:String, indexPath:NSIndexPath)->(UIImage!) {
    return fe_ios_http_reuse_image(url, defaultImageName: defaultImageName, incremental: 0, notifyName: notifyName, indexPath: indexPath)
}



