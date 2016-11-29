//
//  FEiOSUI.swift
//  FECore
//
//  Created by apps on 15/10/20.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation
import UIKit

public var feInputPadStoryBoard:UIStoryboard!


public func getFEBottomInputBarViewController()->(FEBottomInputBarViewController!) {
    
    let feBottomInputBarViewController = feInputPadStoryBoard.instantiateViewControllerWithIdentifier("FEBottomInputBar")  as! FEBottomInputBarViewController

    return feBottomInputBarViewController

}


public func getFEStdIputBarViewController()->(FEStdIputBarViewController!) {
    
    let feStdIputBarViewController = feInputPadStoryBoard.instantiateViewControllerWithIdentifier("FEStdInputBar")  as! FEStdIputBarViewController
    
    return feStdIputBarViewController
    
}



public func initFEiOSUI(){

    let frameworkPath = NSBundle.mainBundle().resourcePath! + "/Frameworks/FEiOSUI.framework"
    
    let bundle = NSBundle(path:frameworkPath)
    
    bundle?.load()

    feInputPadStoryBoard = UIStoryboard(name: "FEInputPad", bundle:bundle)

}
