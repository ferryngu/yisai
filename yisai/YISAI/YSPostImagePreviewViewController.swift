//
//  YSPostImagePreviewViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/17.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSPostImagePreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagePath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: imagePath)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteImage(sender: AnyObject) {
        
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            objc_setAssociatedObject(self.navigationController, &AssociatedPostFamilyDynamic.GetDeleteStatus, "1", objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.navigationController?.popViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let controller = UIAlertController(title: nil, message: "确定删除该照片?", preferredStyle: UIAlertControllerStyle.Alert)
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        
        if isUsingiPad() {
            
            controller.popoverPresentationController?.sourceView = self.view
            controller.popoverPresentationController?.sourceRect = self.view.frame
        }
        
        self.presentViewController(controller, animated: true, completion: nil)
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
