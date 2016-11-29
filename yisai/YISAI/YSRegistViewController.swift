//
//  YSRegistViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/10/11.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSRegistViewController: UIViewController {

    
    var tips: FETips = FETips()
    var  btn_Current:UIButton!
    var  btn_local:UIButton!
    var  btn_select1:UIButton!
    var  btn_select2:UIButton!
    var  role_type: String!
    var  btn_next:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "注册"
        
        tips.duration = 1
        
        self.view.backgroundColor = viewbackColor
        
        
        let btn_width:CGFloat = SCREEN_WIDTH/4
        
        
        
        let imageView = UIView(frame: CGRectMake(0,SCREEN_HEIGHT/4,SCREEN_WIDTH,btn_width+100))
        imageView.backgroundColor =  UIColor.clearColor()
        self.view?.addSubview(imageView)
        
        
        btn_Current = UIButton(frame: CGRectMake(SCREEN_WIDTH/2-btn_width-25,0,btn_width,btn_width))
        btn_Current.backgroundColor = UIColor.clearColor()
        btn_Current.addTarget(self,action:#selector(Select1),forControlEvents:.TouchUpInside)
        btn_Current.setBackgroundImage(UIImage(named: "Student"), forState: UIControlState.Normal)
        imageView.addSubview(btn_Current)
        
        
        let lab_Current = UILabel(frame: CGRectMake(SCREEN_WIDTH/2-btn_width-25,btn_width+12,btn_width,30))
        lab_Current.top = btn_Current.bottom+3;
        //lab_title.textColor = UIColor.grayColor()
        lab_Current.textAlignment = NSTextAlignment.Center
        lab_Current.text = "我是学生"
        lab_Current.font = UIFont.systemFontOfSize(15)
        imageView.addSubview(lab_Current)
        
         btn_select1 = UIButton(frame: CGRectMake(SCREEN_WIDTH/2+25,0,40,40))
        btn_select1.backgroundColor = UIColor.clearColor()
       btn_select1.addTarget(self,action:#selector(Select1),forControlEvents:.TouchUpInside)
        btn_select1.setBackgroundImage(UIImage(named: "Select_no"), forState: UIControlState.Normal)
        imageView.addSubview(btn_select1)
        
        btn_select1.top  =  lab_Current.bottom
        btn_select1.left = lab_Current.left+lab_Current.width/2 - 20;
        
        
        btn_local = UIButton(frame: CGRectMake(SCREEN_WIDTH/2+25,0,btn_width,btn_width))
        btn_local.backgroundColor = UIColor.clearColor()
       // btn_local.image = UIImage(named: "Teacher")
        btn_local.setBackgroundImage(UIImage(named: "Teacher"), forState: UIControlState.Normal)
         btn_local.addTarget(self,action:#selector(Select2),forControlEvents:.TouchUpInside)
        imageView.addSubview(btn_local)
        
        //  btn_local.frame.origin.y = lab_title.frame.origin.x+lab_title.frame.size.height+50
        
        let lab_local = UILabel(frame: CGRectMake(SCREEN_WIDTH/2+25,btn_width+12,btn_width,30))
        lab_local.top = btn_local.bottom+3;
        //lab_title.textColor = UIColor.grayColor()
        lab_local.textAlignment = NSTextAlignment.Center
        lab_local.text = "我是老师"
        lab_local.font = UIFont.systemFontOfSize(15)
        imageView.addSubview(lab_local)
        

        btn_select2 = UIButton(frame: CGRectMake(SCREEN_WIDTH/2+25,0,40,40))
        btn_select2.backgroundColor = UIColor.clearColor()
         btn_select2.addTarget(self,action:#selector(Select2),forControlEvents:.TouchUpInside)
        btn_select2.setBackgroundImage(UIImage(named: "Select_no"), forState: UIControlState.Normal)
        imageView.addSubview(btn_select2)
        
        btn_select2.top  =  lab_Current.bottom
        btn_select2.left = lab_local.left+lab_local.width/2 - 20;
        
        
         btn_next = UIButton(frame: CGRect(x: 15, y: 20, width: SCREEN_WIDTH-30, height: 50))
        btn_next.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 0.4)
        btn_next.setTitle("下一个", forState:.Normal)
        btn_next.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn_next.layer.cornerRadius = 5;
        btn_next.top = imageView.bottom + 10
        btn_next.addTarget(self,action:#selector(Next),forControlEvents:.TouchUpInside)
        self.view.addSubview(btn_next)
        
        let lab_choose = UILabel(frame: CGRectMake(SCREEN_WIDTH/4,btn_width,SCREEN_WIDTH/2,30))
        lab_choose.bottom = imageView.top - 20;
        lab_choose.textColor = UIColor.grayColor()
        lab_choose.textAlignment = NSTextAlignment.Center
        lab_choose.text = "请选择身份注册"
        lab_choose.font = UIFont.systemFontOfSize(17)
        self.view.addSubview(lab_choose)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func Next()
    {
        if(role_type == nil || role_type.isEmpty )
        {
            tips.showTipsInMainThread(Text:"请选择角色")
            return
        }
        
        
        let controller = YSRegistSubmitViewController()
        controller.role_type = role_type
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func Select1()
    {
        

        btn_Current.setBackgroundImage(UIImage(named: "Student_select"), forState: UIControlState.Normal)
        btn_local.setBackgroundImage(UIImage(named: "Teacher"), forState: UIControlState.Normal)
        
        role_type = "1"
        
        
        btn_select1.setBackgroundImage(UIImage(named: "Select_yes"), forState: UIControlState.Normal)
        btn_select2.setBackgroundImage(UIImage(named: "Select_no"), forState: UIControlState.Normal)
        
        btn_next.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 1)
        
    }
    
    func Select2()
    {
        
        role_type = "2"
        
        
        btn_Current.setBackgroundImage(UIImage(named: "Student"), forState: UIControlState.Normal)
        btn_local.setBackgroundImage(UIImage(named: "Teacher_select"), forState: UIControlState.Normal)
        
        btn_select1.setBackgroundImage(UIImage(named: "Select_no"), forState: UIControlState.Normal)
        btn_select2.setBackgroundImage(UIImage(named: "Select_yes"), forState: UIControlState.Normal)
        
        
        btn_next.backgroundColor = UIColor.init(red: 236/255.0, green: 82/255.0, blue: 82/255.0, alpha: 1)
    }
    
}
