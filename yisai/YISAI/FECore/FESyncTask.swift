//
//  FESyncTask.swift
//  ch74
//
//  Created by apps on 14/12/2.
//  Copyright (c) 2014年 apps. All rights reserved.
//

import UIKit

typealias fe_synctask_block_t = ()->Void
typealias fe_syncfinish_block_t = () ->Void

//typealias fe_tips_timeout_block_t = (c:Int) -> Int

class FESyncTask: NSObject {

    var taskStatus:Int!;

    /*
    launchBlockTask 是执同步且不可以取消的操作
    因此点击Tips只是让Tips消失，且不执行任务完成后的后继操作，对执行中的任务无法终止
    timeout单位 秒
    */
    func launchBlockTask(viewController:UIViewController, Title title:String, Task task:fe_synctask_block_t!, Finish finish:fe_syncfinish_block_t!, Timeout timeout:UInt64) {

        let feTips:FETips = FETips()
        
        feTips.duration = timeout

        /***************************************
          发起异步任务，完成后调用UI线程的Block
        ***************************************/
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

            if nil != task {

                self.taskStatus = 1

                feTips.showTipsInMainThread(Text: title)
                
                task()

                if 1 != self.taskStatus {
                    return
                }
                
                self.taskStatus = 0
                
                feTips.disappearTipsInMainThread()

            }

            dispatch_async ( dispatch_get_main_queue(), {

                finish()

            })

        })

        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(timeout * NSEC_PER_SEC))

        dispatch_after(time, dispatch_get_main_queue(), {

            if 1 != self.taskStatus {
                return
            }

            print("time out!!!\n")
            self.taskStatus = 0
            feTips.disappearTipsInMainThread()

        })

    }

}

