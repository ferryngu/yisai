//
//  YSUtil.swift
//  YISAI
//
//  Created by Yufate on 15/5/28.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

/** 验证手机号格式是否正确 */
func checkTelNumber(telNumber: String!) -> Bool {
    
  //  let pattern = "^1+[3578]+\\d{9}"
   // let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
   // let isMatch = pred.evaluateWithObject(telNumber)
  //  return isMatch
    
    let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
    let  CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
    let  CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
    let  CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
    let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
    let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
    let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
    if ((regextestmobile.evaluateWithObject(telNumber) == true)
        || (regextestcm.evaluateWithObject(telNumber)  == true)
        || (regextestct.evaluateWithObject(telNumber) == true)
        || (regextestcu.evaluateWithObject(telNumber) == true))
    {
        return true
    }
    else
    {
        return false
    }

}
/** 验证nicheng格式是否正确 */
func checkRealName(telNumber: String!) -> Bool {
    
    //  let pattern = "^1+[3578]+\\d{9}"
    // let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
    // let isMatch = pred.evaluateWithObject(telNumber)
    //  return isMatch
    
    let mobile = "[a-zA-Z0-9\u{4E00}-\u{9FA5}]+"
  
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)

    if (regextestmobile.evaluateWithObject(telNumber) == true)
    {
        return true
    }
    else
    {
        return false
    }
    
}
/** 判断输入是否为空和只输出空格 */
func checkInputEmpty(str: String!) -> Bool {
    
    if str == nil {
        return true
    } else {
        let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimedString = str.stringByTrimmingCharactersInSet(set) as NSString
        if trimedString.length == 0 {
            return true
        } else {
            return false
        }
    }
}

/** 判断是否同一天 */
func isSameDay(date1: NSDate, theOtherDay date2: NSDate) -> Bool {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-M-d"
    
    let tDateStr1 = dateFormatter.stringFromDate(date1)
    let tDateStr2 = dateFormatter.stringFromDate(date2)
    
    if tDateStr1 == tDateStr2 {
        return true
    } else {
        return false
    }
}

/* handle the time format */
func handleTime(dateStr: String!, style: Int) -> String {
    
    if dateStr == nil {
        return ""
    }
    
    let dateFormatter = NSDateFormatter()
    switch style {
    case 1:
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    default:
        break
    }
    
    let date = dateFormatter.dateFromString(dateStr)
    
    if date == nil {
        return ""
    }
    
    if isSameDay(date!, theOtherDay: NSDate()) {
        dateFormatter.dateFormat = "今天 HH:mm"
        let dateStr = dateFormatter.stringFromDate(date!)
        return dateStr
    }
    
    dateFormatter.dateFormat = "M月d日 HH:mm"
    let dateStr = dateFormatter.stringFromDate(date!)
    
    return dateStr
}

/** 时间戳格式化 */
func formatTimeInterval(timeInterval: NSTimeInterval, type: Int) -> String? {
    
    let dateFormatter = NSDateFormatter()
    switch type {
    case 0:
         dateFormatter.dateFormat = "yyyy/M/d"
    case 1:
        dateFormatter.dateFormat = "yyyy-M-d"
    case 2:
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    default:
        break
    }
    
    return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeInterval / 1000))
}

/** 延时调用函数 */
func delayCall(delaytime: CGFloat, block: dispatch_block_t) {
    
    let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(delaytime * CGFloat(NSEC_PER_SEC)))
    
    dispatch_after(time, dispatch_get_main_queue(), {
        block()
    })
}

/** 重新登录 */
func reLogin() {
    
    let errorMsg = "你的账号已经在其他地方登录"
    let tips: FETips = FETips()
    tips.duration = 1
    tips.showTipsInMainThread(Text: errorMsg)
    
     ysApplication.loginUser.clean()
    
    
    delayCall(1.0, block: { () -> Void in
        ysApplication.switchViewController(MAIN_VIEWCONTROLLER)
    })
}

/** 判断当前是否iPad */
func isUsingiPad() -> Bool {
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        return true
    }
    return false
}

func BackTransition() -> CATransition
{
    let transition = CATransition()
    transition.duration = 0.3
    transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    return transition
}

func AddTransition() -> CATransition
{
    let transition = CATransition()
    transition.duration = 0.3
    transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    return transition
}

