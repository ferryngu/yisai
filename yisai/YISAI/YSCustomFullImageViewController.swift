//
//  YSCustomFullImageViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/19.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCustomFullImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var imgUrl: String!
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(imgUrl, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            
            if self == nil {
                return
            }
            
            self!.imageView.image = self!.feiOSHttpImage.loadImageInCache(self!.imgUrl).0
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
