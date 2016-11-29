//
//  FEStdData.swift
//  FECoreHttp
//
//  Created by chenyuning on 15/6/11.
//  Copyright (c) 2015年 apps. All rights reserved.
//

import Foundation

public func fe_std_data_init()->() {
    
    fe_std_data_misc_init()
    
}

public func fe_std_data_set(id:String, key:String, value:String!, expire_sec:Int64)->(){

    if nil == value {
        fe_std_data_atom_set(id, key, nil, expire_sec)
        return
    }

    fe_std_data_atom_set(id, key, value, expire_sec)
    
}

public func fe_std_data_set_json(id: String, key: String, jsonValue: NSDictionary!, expire_sec:Int64) {
    
    if nil == jsonValue {
        fe_std_data_atom_set(id, key, nil, 0)
        return
    }
    
    var jsonData:NSData!
    
    do {
        
        try jsonData = NSJSONSerialization.dataWithJSONObject(jsonValue, options: NSJSONWritingOptions.PrettyPrinted)
        
    } catch {
        
        return
        
    }
    
    var jsonString: String? = nil
    
    if jsonData?.length > 0 {
        jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as? String
    }
    
    fe_std_data_atom_set(id, key, jsonString!, expire_sec)
}

public func fe_std_data_get(id:String, key:String)->(String!) {
    
    let valuebuf = fe_std_data_atom_get_dup(id, key)
    
    if nil == valuebuf{
        return nil
    }
    
    let value = String.fromCString(UnsafeMutablePointer<CChar>(valuebuf))
    
    free(valuebuf)
    
    return value
    
}

public func fe_std_data_get_json(id: String, key: String) -> NSDictionary! {
    
    let valuebuf = fe_std_data_atom_get_dup(id, key)
    
    if nil == valuebuf{
        return nil
    }
    
    let value = String.fromCString(UnsafeMutablePointer<CChar>(valuebuf))?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    
    free(valuebuf)
    
    if value == nil {
        return nil
    }
    
    var jsonDic:NSDictionary!
    
    do {
        
        try jsonDic = NSJSONSerialization.JSONObjectWithData(value!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
        
    } catch {
        
        return nil
        
    }
    
    return jsonDic
}

public func feSetAttrib(id:String, key:String, value:String!){
    fe_std_data_set(id, key:key, value:value, expire_sec:10*365*24*60*60)
}

public func feGetAttrib(id:String, key:String)->(String!) {
    return fe_std_data_get(id, key:key)
}

