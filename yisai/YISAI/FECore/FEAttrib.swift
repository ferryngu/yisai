    //
//  FEAttrib.swift
//  ch74
//
//  Created by apps on 14/11/11.
//  Copyright (c) 2014年 apps. All rights reserved.
//

import Foundation

/** 构建本地数据库 */
func feInitAttrib()->() {
    fe_attrib_misc_init()
}

func feSetAttrib(id:String, key:String, value:String!)->() {

    if nil == value {
        fe_attrib_delete(id,key)
        return
    }

    fe_attrib_set_string(id,key,value)

}

func feSetAttribInt64(id:String, key:String, valueInt64:Int64)->() {

    fe_attrib_set_string(id,key,String(format:"%ld",valueInt64))

}
    
func feSetJson(id: String, key: String, jsonValue: NSDictionary!) {
    
    if nil == jsonValue {
        fe_attrib_delete(id,key)
        return
    }
    
    let jsonData = try! NSJSONSerialization.dataWithJSONObject(jsonValue, options: NSJSONWritingOptions.PrettyPrinted)
    var jsonString: String? = nil
    if jsonData.length > 0 {
        jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
    }
    
    fe_attrib_set_string(id, key, jsonString!)
}

func feGetAttrib(id:String, key:String)->(String!) {

    let valuebuf = fe_attrib_string_dup(id, key)

    let value = String.fromCString(UnsafeMutablePointer<CChar>(valuebuf))

    free(valuebuf)

    return value

}

func feGetAttribInt64(id:String, key:String,default_value:Int64)->(Int64) {

    return fe_attrib_int64(id,key, default_value)
}
    
func feGetJson(id: String, key: String) -> NSDictionary! {
    
    let valuebuf = fe_attrib_string_dup(id, key)
    
    let value = String.fromCString(UnsafeMutablePointer<CChar>(valuebuf))?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    
    free(valuebuf)
    
    if value == nil {
        return nil
    }
    
//    var error: NSError? = nil
//    let jsonDic = NSJSONSerialization.JSONObjectWithData(value!, options: NSJSONReadingOptions.MutableLeaves, error: &error) as! NSDictionary
    
//    if error != nil {
//        return nil
//    }
    let jsonDic:NSDictionary?
    
    do {
        jsonDic = try NSJSONSerialization.JSONObjectWithData(value!, options: NSJSONReadingOptions.MutableLeaves) as? NSDictionary
    }catch {
        return nil
    }

    
    
    return jsonDic
}
    
public func feGetAttribAllKey(id:String,size:Int)->([(String, String)])! {

    let attrib_list = fe_attrib_all_keys(id, size)

    let attrib = attrib_list.memory.attrib

    var list:[(String, String)] = [(String, String)]()
    
    if 0 == attrib_list.memory.size {
        return nil
    }

    for var i=0; i < Int(attrib_list.memory.size) ; i++ {

        let key = String.fromCString(UnsafeMutablePointer<CChar>((attrib+i).memory.key))!
        let value = String.fromCString(UnsafeMutablePointer<CChar>((attrib+i).memory.string_value))!
        
        let tuple = (key, value)
        list.append(tuple)


    }

    fe_attrib_list_release(attrib_list);

    return list

}


