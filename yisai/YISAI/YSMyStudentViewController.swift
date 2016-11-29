//
//  YSMyStudentViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/23.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

let MyStudentReuseIdentifier = "YSMyStudentsCell"

class YSMyStudentViewController: UICollectionViewController {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var tips: FETips = FETips()
    var lst_students: [YSTutorStudent]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        YSBudge.setBindTutor("0")
        
        tips.duration = 1
        
        self.collectionViewFlowLayout.itemSize = CGSize(width: (SCREEN_WIDTH - 60) / 5.0, height: (SCREEN_WIDTH - 60) / 5.0 + 33.0)
        
        fetchMyStudents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchMyStudents() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchMyStudents(0, num: 99) { [weak self] (resp_lst_students: [YSTutorStudent]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_students = resp_lst_students
            self!.collectionView?.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return lst_students == nil ? 0 : lst_students.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyStudentReuseIdentifier, forIndexPath: indexPath) 
    
        if lst_students == nil || lst_students.count < 1 {
            return cell
        }
        
        let student = lst_students[indexPath.row]
        let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_name = cell.contentView.viewWithTag(12) as! UILabel
        
        img_avatar.layer.cornerRadius = (SCREEN_WIDTH - 60) / 5.0 / 2
        
        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(student.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_avatar.image = self!.feiOSHttpImage.loadImageInCache(student.avatar).0
            })
        
        lab_name.text = student.realname
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if lst_students == nil || lst_students.count < 1 {
            return
        }
        
        let student = lst_students[indexPath.row]
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSUserPersonalInfoViewController") as! YSUserPersonalInfoViewController
        controller.fuid = student.uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
