//
//  FEMisc.swift
//  ch74
//
//  Created by apps on 14/11/12.
//  Copyright (c) 2014年 apps. All rights reserved.
//

import Foundation
import UIKit


public func initFEiOSMiscSwift()->() {

    let root_path = NSHomeDirectory()

    let temp_path = NSTemporaryDirectory()

    let documents_path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask,true)[0] as String
    
    let cache_path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask,true)[0] as String
    
    initFEiOSAppPath(root_path, temp_path, documents_path, cache_path)

    fe_http_init_once()

    init_misc()

    fe_std_data_init()

    fe_clean_http_temp_dir()

    
    
}

/*
public func initFEiOSDataSwift()->() {

}
*/


func initAPNSInterface() {
/*
    let notificationType: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
    let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: notificationType, categories: nil )
    UIApplication.sharedApplication().registerUserNotificationSettings( settings )
*/
}


//在 AppDelegate.swift 中加入
/*
func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    application.registerForRemoteNotifications()
}


func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    handleDeviceToken( deviceToken )
}

func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
    handleDeviceToken(nil)
    print("didFailToRegisterForRemoteNotificationsWithError \(error)\n");
}
*/


/*
func handleDeviceToken( deviceToken:NSData! ) {
    
    if (nil==deviceToken) {
        return
    }

    var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
    
    var deviceTokenString: String = ( deviceToken.description as NSString )
        .stringByTrimmingCharactersInSet( characterSet )
        .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
    
    FENotification.saveiOSDeviceToken(deviceTokenString)

    println("handleDeviceToken \(deviceTokenString)\n")

}
*/



public func FEReadTextFile(filename:String!)->(String!) {

    let mem_block = fe_mmap(filename)
    
    if 0 == mem_block.len {
        
        if nil != mem_block.ptr {
            
            fe_munmap(mem_block)
            
        }
        
        return nil
        
    }
    
    let text:String! = String.fromCString(UnsafeMutablePointer<CChar>(mem_block.ptr))

    fe_munmap(mem_block)
    
    return text

}
