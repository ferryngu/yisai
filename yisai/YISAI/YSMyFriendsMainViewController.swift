//
//  YSMyFriendsMainViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/16.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

let MyFriendsReuseIdentifier = "YSMyFriendsCell"

class YSMyFriendsMainViewController: UICollectionViewController {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var fuid: String!
    var fetchFanType: Int!
    var lst_friends: [YSMyFriend]!
    let lab_noFan = UILabel()
    
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tips.duration = 1
        
        configureNoFanLab()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        
        collectionViewFlowLayout.itemSize = CGSize(width: (SCREEN_WIDTH - 40 - 20) / 5.0, height: (SCREEN_WIDTH - 40 - 20) / 5.0 + 54)
        
        fetchFriendList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNoFanLab() {
        
        lab_noFan.frame = CGRect(x: 0, y: 0, width: 200, height: 19)
        lab_noFan.center = CGPoint(x: view.center.x, y: 50)
        lab_noFan.text = "你的粉丝列表暂无成员哦"
        lab_noFan.textColor = UIColor.darkTextColor()
        lab_noFan.textAlignment = NSTextAlignment.Center
        lab_noFan.font = UIFont.boldSystemFontOfSize(15.0)
        view.addSubview(lab_noFan)
        lab_noFan.hidden = true
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods

    func fetchFriendList() {
        
        if fetchFanType == nil || fuid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSMyFriend.fetchMyFindwork(fetchFanType, shouldCache: true, fuid: fuid, startIndex: 0, fetchNum: 99) { [weak self] (resp_lst_friends: [YSMyFriend]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_friends = resp_lst_friends
            
            // 粉丝列表为空
            if self!.lst_friends.count < 1 {
                self!.lab_noFan.hidden = false
            } else {
                self!.lab_noFan.hidden = true
            }
            
            self!.collectionView!.reloadData()
        }
    }
    
    // 跳转到普通用户个人主页
    func gotoUserPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSUserPersonalInfoViewController") as! YSUserPersonalInfoViewController
        controller.fuid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到评委个人主页
    func gotoJudgePage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.Judge
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到老师个人主页
    func gotoTeacherPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.role_type = RoleType.Tutor
        controller.aid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到既是评委又是老师的个人主页
    func gotoJNTPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.JudgeAndTutor
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return lst_friends == nil ? 0 : lst_friends.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyFriendsReuseIdentifier, forIndexPath: indexPath) 
    
        if lst_friends == nil {
            return cell
        }
        
        let friend = lst_friends[indexPath.row]
        let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_name = cell.contentView.viewWithTag(12) as! UILabel
        let lab_concernStatus = cell.contentView.viewWithTag(13) as! UILabel
        let img_bgStatus = cell.contentView.viewWithTag(14) as! UIImageView
        
        img_avatar.layer.cornerRadius = (SCREEN_WIDTH - 40 - 20) / 5.0 / 2
        
        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(friend.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_avatar.image = self!.feiOSHttpImage.loadImageInCache(friend.avatar).0
            })
        lab_name.text = friend.username
        if fetchFanType == nil {
            return cell
        }
        if fetchFanType == 0 {
            lab_concernStatus.text = "已关注"
            lab_concernStatus.textColor = UIColor(red: 23.0/255.0, green: 138.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            img_bgStatus.image = UIImage(named: "wdhy_yiguanzhu")
        } else {
            if friend.type == 0 {
                lab_concernStatus.text = "关注"
                lab_concernStatus.textColor = UIColor(red: 245.0/255.0, green: 124.0/255.0, blue: 120.0/255.0, alpha: 1.0)
                img_bgStatus.image = UIImage(named: "wdhy_guanzhu")
            } else {
                lab_concernStatus.text = "互相关注"
                lab_concernStatus.textColor = UIColor(red: 120.0/255.0, green: 155.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                img_bgStatus.image = UIImage(named: "wdhy_huxiangguanzhu")
            }
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if lst_friends == nil {
            return
        }
        
        let friend = lst_friends[indexPath.row]
        
        if friend.role_type == nil || friend.uid == nil {
            return
        }
        
        // 0为未知，1为普通用户，2为评委，3为老师，4为评委/老师
        switch friend.role_type {
        case 1:
            gotoUserPage(friend.uid)
        case 2:
            gotoJudgePage(friend.uid)
        case 3:
            gotoTeacherPage(friend.uid)
        case 4:
            gotoJNTPage(friend.uid)
        default:
            break
        }
    }
}
