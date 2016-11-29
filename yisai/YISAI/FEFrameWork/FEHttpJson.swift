//
//  FEHttpJson.swift
//  FECoreHttp
//
//  Created by apps on 15/9/12.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation

public let FE_HTTP_JSON_STATUS_JSON_ERR      = -1

public let FE_HTTP_JSON_STATUS_INIT          = 0
public let FE_HTTP_JSON_STATUS_FETCHING      = 1
public let FE_HTTP_JSON_STATUS_JSON_OK       = 2

public let FE_HTTP_DATAMODE_FETCH            = 0
public let FE_HTTP_DATAMODE_APPEND           = 1

let  FE_HTTP_JSON_CACHE_ZONE = "http_json_cache"

public class FEHttpJson {
    
    public var url:String!
    
    var httpParams:[String]!
    
    var	httpMethod = 0

    //操作的json对象
    public var httpJsonObject:NSDictionary!

    public var jsonObject:NSMutableDictionary!
    
    var jsonObjectLock:NSLock
    
    var canRequest:Bool

    public var httpContent:String!

    var prepareCallBack:( ()->() )!

    //在 View 退出时最好将 block 设置为 nil
    public var finishCallBack:( ()->() )!

    public var isSaveCacheCallBack:( ()->(Bool) )!
    
    var cacheKey:String!

    var http_get_handler:fe_http_get_handler!
    var http_post_handler:fe_http_post_handler!

    public var jsonStatus:Int

    public var dataMode:Int
    
    //jsonObject 来自cache
    public var isCacheHit:Bool

    //jsonObject 来自网络
    public var isFetched:Bool

    public var httpError:Int32
    public var httpResponse:Int

    public var expireSecond = 3*24*60*60
    
    public init() {

        prepareCallBack = nil
        finishCallBack = nil

        isCacheHit = false
        isFetched = false

        jsonStatus = FE_HTTP_JSON_STATUS_INIT
        httpResponse = 0;
        httpError = FE_HTTP_ERROR_NONE
    
        cacheKey = nil
        
        jsonObject = nil
        
        dataMode = FE_HTTP_DATAMODE_FETCH

        jsonObjectLock = NSLock()

        canRequest = true

    }

    public func getErrorString()->(String) {
        return get_fe_http_err_string(httpError)
    }

    func checkTaskFree()->(Bool) {

        jsonObjectLock.lock()
        if false == canRequest {
            jsonObjectLock.unlock()
            return false
        }
        canRequest = false
        jsonObjectLock.unlock()

        return true

    }

    func setTaskFree()->() {

        jsonObjectLock.lock()
        canRequest = true
        jsonObjectLock.unlock()
    
    }
    
    public func setHttpGetUrl(url:String, httpParams:[String]!) {
        self.url = url
        self.httpParams = httpParams
        self.httpMethod = 0
    }

    public func setHttpPostUrl( url:String, httpParams:[String]!) {
        self.url = url
        self.httpParams = httpParams
        self.httpMethod = 1
    }

    public func setCacheKey(cacheKey:String!) {
        
        self.cacheKey = cacheKey

    }
    
    private func handleHttpFinish() {

        var saveCache:Bool = false

        if FE_HTTP_JSON_STATUS_JSON_OK != self.jsonStatus {

            if nil != finishCallBack {
                finishCallBack()
                setTaskFree()
                return
            }

        }

        isFetched = true

        if nil != self.isSaveCacheCallBack && nil != self.cacheKey {
            saveCache = self.isSaveCacheCallBack()
        }

        if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
            print("FEHttpJson:handleHttpFinish url[\(url)] isFetched[\(isFetched)] isCacheHit[\(isCacheHit)] saveCache[\(saveCache)] ErrorString[\(self.getErrorString())]", terminator: "")
        }

        if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_1 {
            if FE_HTTP_JSON_STATUS_JSON_OK == self.jsonStatus {
                print("FEHttpJson:handleHttpFinish url[\(url)] jsonObject=[\(jsonObject)]", terminator: "")
            } else {
                print("FEHttpJson:handleHttpFinish url[\(url)] json error httpContent=[\(httpContent)]", terminator: "")
            }
        }

        if true == saveCache {
            
            fe_std_data_set_json(FE_HTTP_JSON_CACHE_ZONE, key:self.cacheKey, jsonValue:self.httpJsonObject, expire_sec:Int64(expireSecond) )

        }

        if nil == jsonObject && nil != httpJsonObject && FE_HTTP_DATAMODE_FETCH == dataMode {
            
            jsonObject = NSMutableDictionary(dictionary: httpJsonObject)
            
        }

        if nil != finishCallBack {
            finishCallBack()
            setTaskFree()
        }

    }

    private func handleCacheHit() {

        jsonStatus = FE_HTTP_JSON_STATUS_JSON_OK
        
        isCacheHit = true
        
        if FE_HTTP_DATAMODE_APPEND == dataMode {

            return

        }

        if nil == jsonObject && nil != httpJsonObject {
        
            jsonObject = NSMutableDictionary(dictionary: httpJsonObject)
        
        }

        if nil != finishCallBack {
            
            finishCallBack()

        }

    }

    public func request(notifyName:String) {

        self.finishCallBack = {
            
            NSNotificationCenter.defaultCenter().postNotificationName(notifyName, object: nil,userInfo:nil)

        }
        
        request()

    }
    
    public func request() {

        if nil != self.prepareCallBack {

            self.prepareCallBack()

        }

        if nil != cacheKey {

            httpJsonObject = fe_std_data_get_json(FE_HTTP_JSON_CACHE_ZONE, key:cacheKey)

            if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
                
                if nil != httpJsonObject {
                    print("FEHttpJson:request:CacheHit url[\(url)]", terminator: "")
                    
                    if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_1 {
                        print("FEHttpJson:request:CacheHit: url[\(url)] jsonObject=[\(jsonObject)]", terminator: "")
                    }
                } else {
                    print("FEHttpJson:request:CacheEmpty url[\(url)]", terminator: "")
                }
            }
    
            if nil != httpJsonObject {

                handleCacheHit()

            }

        }

        let isTaskFree = checkTaskFree()
        
        if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
            print("FEHttpJson:request url[\(url)] isTaskFree[\(isTaskFree)]", terminator: "")
        }

        if false == isTaskFree {
            return
        }

        if 0 == self.httpMethod {

            requestGet()

        } else  {

            requestPost()

        }

    }

    func requestGet() {

        let http_get_finish_callback:fe_http_get_finish_callback_t = {
            (handler:fe_http_get_handler)->() in

            if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
                print("FEHttpJson:fe_async_http_get_json_std:http_get_finish_callback url[\(self.url)] params[\(self.httpParams)] httpRespond[\(handler.httpRespond)] ErrorString[\(self.getErrorString())]", terminator: "")
            }

            self.httpError = handler.httpError
            self.httpResponse = handler.httpRespond            
            
            if true != handler.httpSucceed {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }

            if 200 != handler.httpRespond {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }

            self.httpContent = handler.content_text

            self.httpJsonObject = handler.content_jsonObj

            if nil == self.httpJsonObject {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }

            self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_OK

            self.handleHttpFinish()

            return

        }

        jsonStatus = FE_HTTP_JSON_STATUS_FETCHING

        if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
            print("FEHttpJson:fe_async_http_get_json_std url[\(self.url)] params[\(self.httpParams)]", terminator: "")
        }
        
        http_get_handler = fe_async_http_get_json_std(self.url, prepare_callback:nil, finish_callback:http_get_finish_callback, params:self.httpParams)
        
    }
    
    func requestPost() {

        let http_post_finish_callback:fe_http_post_finish_callback_t = {
            (handler:fe_http_post_handler)->() in
            
            if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
                print("FEHttpJson:fe_async_http_post_json_std:http_get_finish_callback url[\(self.url)] params[\(self.httpParams)] httpRespond[\(handler.httpRespond)] httpError[\(handler.httpError)]", terminator: "")
            }
            
            self.httpError = handler.httpError
            self.httpResponse = handler.httpRespond
            
            if true != handler.httpSucceed {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }
            
            if 200 != handler.httpRespond {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }
            
            self.httpContent = handler.content_text
            
            self.httpJsonObject = handler.content_jsonObj
            
            if nil == self.httpJsonObject {
                self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_ERR
                self.handleHttpFinish()
                return
            }
            
            self.jsonStatus = FE_HTTP_JSON_STATUS_JSON_OK
            
            self.handleHttpFinish()

            return
            
        }

        jsonStatus = FE_HTTP_JSON_STATUS_FETCHING
    
        if fe_http_request_debug_level > FE_HTTP_REQUEST_DEBUG_LEVEL_0 {
            print("FEHttpJson:fe_async_http_post_json_std url[\(self.url)] params[\(self.httpParams)]", terminator: "")
        }

        fe_async_http_post_json_std(self.url, prepare_callback:nil,finish_callback:http_post_finish_callback, params:self.httpParams)

    }
    
    public func mergeArray(pkey:String,nodenames:[String]) {
    
        if nil == jsonObject || nil == httpJsonObject {
            return
        }
        
        let orgArray = feJsonGetNSArray(jsonObject, nodenames:nodenames)
        let appendArray = feJsonGetNSArray(httpJsonObject, nodenames:nodenames)
        
        if nil == orgArray || nil == appendArray {
            return
        }
        
        
        let newArray = feMergeNSArray(orgArray, appendArray:appendArray, pkey:pkey)

        feJsonSetNSArray(jsonObject, nodenames:nodenames, array:newArray)

    }
    
    public func getArraySize(nodenames:[String])->(Int) {
        
        if nil == httpJsonObject {
            return 0
        }
        
        let list = feJsonGetNSArray(httpJsonObject, nodenames:nodenames)
        
        if nil == list {
            return 0
        }
        
        return list.count
        
    }
    
    public func getStringInArray(index:Int, nodenames:[String], name:String)->String! {
        
        if nil == httpJsonObject {
            return nil
        }
        
        let list = feJsonGetNSArray(httpJsonObject, nodenames:nodenames)
        
        if nil == list {
            return nil
        }
        
        let data:NSDictionary! = list.objectAtIndex(index) as? NSDictionary
        
        if nil == data {
            return nil
        }
        
        let value = data![name] as? String
        
        if value == nil {
            return nil
        }
        
        return value!
        
    }
    
    public func getIntInArray(index:Int, nodenames:[String], name:String,defaultInt:Int)->Int {
        
        if nil == httpJsonObject {
            return defaultInt
        }
        
        let list = feJsonGetNSArray(httpJsonObject, nodenames:nodenames)
        
        if nil == list {
            return defaultInt
        }
        
        let data:NSDictionary! = list.objectAtIndex(index) as? NSDictionary
        
        if nil == data {
            return defaultInt
        }
        
        let retNumber:NSNumber? = data![name] as? NSNumber
        
        if retNumber == nil {
            return defaultInt
        }
        
        let retInt = retNumber!.integerValue
        
        return retInt
        
    }

    
    
    public func getNSDictionary(nodenames:[String])->(NSDictionary!){

        return feJsonGetNSDictionary(httpJsonObject, nodenames:nodenames)

    }

    public func getNSArray(nodenames:[String])->(NSArray!) {
        
        return feJsonGetNSArray(httpJsonObject, nodenames: nodenames)

    }
    
    public func getString(nodenames:[String], defaultString:String!)->(String!){

        return feJsonGetString(httpJsonObject, nodenames:nodenames, defaultString:defaultString)

    }
    
    public func getInt(nodenames:[String],defaultInt:Int)->(Int){

        return feJsonGetInt(httpJsonObject, nodenames:nodenames, defaultInt:defaultInt)
    }

    public func getArrayInArray(index:Int, nodenames:[String], name:String) -> NSArray! {

        if nil == httpJsonObject {
            return nil
        }

        let list = feJsonGetNSArray(httpJsonObject, nodenames:nodenames)

        if nil == list {
            return nil
        }

        let data:NSDictionary! = list.objectAtIndex(index) as? NSDictionary

        if nil == data {
            return nil
        }

        let value = data![name] as? NSArray

        if value == nil {
            return nil
        }

        return value!

    }

}
