//
//  FEJson.swift
//  FECoreHttp
//
//  Created by apps on 15/7/5.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation


public func feJsonGetNSDictionary(jsonDictionary:NSDictionary!, nodenames:[String])->(NSDictionary!) {

    var i = 0

    if nil == jsonDictionary {
        return nil
    }

    var obj:AnyObject! = jsonDictionary

    for i=0; i<nodenames.count; i++ {

        if nil == obj || !(obj is NSDictionary) {
            return nil
        }

        obj = obj[nodenames[i]]

    }

    if !(obj is NSDictionary) {
        return nil
    }

    return obj as! NSDictionary!

}

public func feJsonGetNSArray(jsonDictionary:NSDictionary!, nodenames:[String])->(NSArray!) {

    var i = 0
    
    if nil == jsonDictionary {
        return nil
    }
    
    var obj:AnyObject! = jsonDictionary
    
    for i=0; i<nodenames.count-1 ; i++ {
        
        if nil == obj || !(obj is NSDictionary) {
            return nil
        }
        
        obj = obj[nodenames[i]]
        
    }
    
    if !(obj is NSDictionary) {
        return nil
    }

    obj = obj[ nodenames[i] ]
    
    if !(obj is NSArray) {
        return nil
    }
    
    return obj as! NSArray!

}

public func feJsonSetNSArray(jsonDictionary:NSMutableDictionary!, nodenames:[String], array:NSArray!)->() {

    var i = 0
    
    if nil == jsonDictionary {
        return
    }

    var obj:NSMutableDictionary! = jsonDictionary

    for i=0; i<nodenames.count-1 ; i++ {
        
        if nil == obj {
            return
        }
        
        obj = obj[nodenames[i]] as! NSMutableDictionary
        
    }

    if nil == obj {
        return
    }

    obj[ nodenames[i] ] = NSMutableArray(array: array)
    
}


public func feJsonGetString(jsonDictionary:NSDictionary!, nodenames:[String], defaultString:String!)->(String!) {
    
    var i = 0
    
    if nil == jsonDictionary {
        return defaultString
    }
    
    var obj:AnyObject! = jsonDictionary
    
    for i=0; i<nodenames.count-1 ; i++ {
        
        if nil == obj || !(obj is NSDictionary) {
            return defaultString
        }
        
        obj = obj[nodenames[i]]
        
    }
    
    if !(obj is NSDictionary) {
        return defaultString
    }

    obj = obj[ nodenames[i] ]
    
    if !(obj is String) {
        return defaultString
    }
    
    return obj as! String!
    
}


public func feJsonGetInt(jsonDictionary:NSDictionary!, nodenames:[String], defaultInt:Int)->(Int) {
    
    var i = 0
    
    if nil == jsonDictionary {
        return defaultInt
    }
    
    var obj:AnyObject! = jsonDictionary
    
    for i=0; i<nodenames.count-1 ; i++ {
        
        if nil == obj || !(obj is NSDictionary) {
            return defaultInt
        }
        
        obj = obj[nodenames[i]]
        
    }
    
    if !(obj is NSDictionary) {
        return defaultInt
    }
    
    obj = obj[ nodenames[i] ]

    if nil == obj {
        return defaultInt
    }

    let retNumber: NSNumber! = obj as! NSNumber
    
    if nil == retNumber {
        return defaultInt
    }
    
    let retInt = retNumber!.integerValue
    
    return retInt

}

/*
public func feJsonGetInt64(jsonDictionary:NSDictionary!, nodenames:[String], defaultInt:Int64)->(Int64) {
    
    var i = 0
    
    if nil == jsonDictionary {
        return defaultInt
    }
    
    var obj:AnyObject! = jsonDictionary
    
    for i=0; i<nodenames.count-1 ; i++ {
        
        if nil == obj || !(obj is NSDictionary) {
            return defaultInt
        }
        
        obj = obj[nodenames[i]]
        
    }
    
    if !(obj is NSDictionary) {
        return defaultInt
    }
    
    obj = obj[ nodenames[i] ]
    
    if obj is String {
        let stringObj = obj as! String
        
        return Int64(stringObj)!
    }
    
    if (obj is Int64) {
        return Int(obj as! Int64)
    }
    
    
    if !(obj is Int) {
        return defaultInt
    }
    
    return defaultInt
    
}
*/




/*

合并规则
出现重复的数据，原数组去掉，追加的放后面

*/
public func feMergeNSArray(orgArray:NSArray!, appendArray:NSArray!, pkey:String)->(NSMutableArray!) {

    let newArray = NSMutableArray()
    
    var i = 0
    var j = 0

    var findObj:NSDictionary! = nil
    
    if nil==orgArray || nil==appendArray {
        return nil
    }
    
    for i=0; i < orgArray.count; i++ {
        
        let org_obj:NSDictionary! = orgArray.objectAtIndex(i) as! NSDictionary
        
        if nil == org_obj {
            continue
        }
        
        let org_value:String! = org_obj.objectForKey(pkey) as! String
        
        if nil == org_value {
            continue
        }
        
        findObj = nil

        for j=0; j < appendArray.count; j++ {
            
            let append_obj:NSDictionary! = appendArray.objectAtIndex(j) as! NSDictionary
            
            if nil == append_obj {
                continue
            }
            
            let append_value:String! = append_obj.objectForKey(pkey) as! String
            
            if nil == append_value {
                continue
            }
            
            if NSComparisonResult.OrderedSame == org_value.compare(append_value) {
                findObj = append_obj
                break
            }
            
        }
        
        if nil == findObj {

            newArray.addObject(org_obj)
            
        }

    }

    for j=0; j < appendArray.count; j++ {
    
        let append_obj:NSDictionary! = appendArray.objectAtIndex(j) as! NSDictionary
        
        if nil == append_obj {
            continue
        }

        newArray.addObject(append_obj)
    
    }

    return newArray

}

public func getObjectsByKeyFromNSArray(inArray:NSArray!, nodenames:[String], key:String,value:String)->(NSMutableArray!) {

    let returnArray = NSMutableArray()

    var i = 0

    for i=0; i < inArray.count; i++ {
        
        let objectInArray:NSDictionary! = inArray.objectAtIndex(i) as! NSDictionary
        
        if nil == objectInArray {
            return nil
        }

        let nodeObject = feJsonGetNSDictionary(objectInArray, nodenames:nodenames)
        
        if nil == nodeObject {
            continue
        }
        
        let stringValue:String! = nodeObject.objectForKey(key) as! String
        
        if nil == stringValue {
            continue
        }
        
        if stringValue == value {
            returnArray.addObject(nodeObject)
        }

    }

    return returnArray
    
}
