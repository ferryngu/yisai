//
//  FEDoc.swift
//  FECoreHttp
//
//  Created by apps on 15/7/30.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation

public class FEDoc {

    var mutex:pthread_mutex_t
    var doc:NSMutableDictionary
    init() {
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        doc = NSMutableDictionary()
    }

    deinit{
        pthread_mutex_destroy(&mutex)
    }

    func get(key:String!)->(AnyObject!){

        var obj:AnyObject! = nil

        if nil == key {
            return nil
        }

        pthread_mutex_lock(&mutex)
        obj = doc.objectForKey(key)
        pthread_mutex_unlock(&mutex)
        return obj
    }

    func put(key:String!, value:AnyObject!)->() {
    
        if nil == key {
            return
        }

        pthread_mutex_lock(&mutex)
        
        if nil != value {
            doc.setObject(value, forKey:key)
        } else {
            doc.removeObjectForKey(key)
        }

        pthread_mutex_unlock(&mutex)
        
        return
        
    }

    func size()->(Int) {
        return doc.count
    }

}