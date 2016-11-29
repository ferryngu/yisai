//
//  FECoreDumpHandle.swift
//  FECore
//
//  Created by apps on 15/11/8.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation


public var gFeCoreDumpHandle:FECoreDumpHandle! = nil

public class FECoreDumpHandle {

    var ver:Int
    var url:String
    
    public var prepareResumeCallBackInMainThread:(()->Void)!

    public var finishResumeCallBackInMainThread:(()->Void)!
    
    
    /*
    版本号，配置url由 App 传入，App的代码这两个值应该在代码中 hare code 为常量,不要存在配置文件中
    */
    public init(Ver:Int,Url:String) {
        ver = Ver
        url = Url
    }

    public func handleCoreDumpOnLaunchInMainThrea()->Void {

        handleCoreDump()

//        fe_coredump_set_signal()
//
//        clean_coredump_flag_file()

    }

    func removeByArray(array:NSArray!) {
        
        if nil==array{
            return
        }
        
        var i = 0
        
        for i=0; i<array.count; i++ {
            
            let filepath:String! = array.objectAtIndex(i) as! String
            
            if nil == filepath {
                continue
            }
            
            fe_file_remove(filepath!)
            
        }
        
    }
    
    /*
    
    {
    
    "code":"1",
    
    "msg":"success",
    
    "data":{
    
    "lst_remove_document":[
    "",
    "",
    "",
    
    ],
    "lst_remove_cache":[
    "",
    "",
    "",
    
    ]
    
    }
    
    }
    
    */

    func handleCoreDump()->Void {
        
        if nil != prepareResumeCallBackInMainThread{
            prepareResumeCallBackInMainThread()
        }
        
        
        
//        let r = fe_coredump_check()
    
        //文件不存在
//        if 0 != r {
//            return
//        }
        
        // 同步 http GET 请求
        let dict = fe_http_get_json_std(url, params:["ver","\(ver)"])
        
        if nil == dict {
            return
        }
        
        let code = feJsonGetInt(dict, nodenames: ["code"],defaultInt:0)
        
        if 1 != code {
            return
        }
        
        if nil != prepareResumeCallBackInMainThread{
            prepareResumeCallBackInMainThread()
        }
        
        let remove_document_array = feJsonGetNSArray(dict, nodenames: ["data","lst_remove_document"])
        
        removeByArray(remove_document_array)
        
        let remove_cache_array = feJsonGetNSArray(dict, nodenames: ["data","lst_remove_cache"])
        removeByArray(remove_cache_array)
        
        let remove_temp_array = feJsonGetNSArray(dict, nodenames: ["data","lst_remove_temp"])
        removeByArray(remove_temp_array)
        
        if nil != finishResumeCallBackInMainThread {
            finishResumeCallBackInMainThread()
        }
    
    }

}



/*

void createCoreDumpFileFlag() {

char *filename;

filename = fe_getAppPath_dup ("/coredumpflag.bin", FE_DOCUMENTS);

int fd = fe_create_file(filename);

close(fd);

}
*/