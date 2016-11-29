//
//  TableViewCell.swift
//  YISAI
//
//  Created by 周超创 on 16/9/7.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    var title:UILabel!
    var clickBtn:UIButton!
    var left_img:UIImageView!
    
    var name:UILabel!
    var product:UILabel!
    var group:UILabel!
    var bgview:UIView!
    var right_img:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if !self.isEqual(nil) {
            //title = UILabel(frame: CGRectMake(20, 20, 200, 30))
          //  self.contentView.addSubview(title)
            bgview = UIView(frame: CGRectMake(0, 4, SCREEN_WIDTH, 70))
            bgview.backgroundColor = UIColor.whiteColor()
            self.contentView.addSubview(bgview)
            
            left_img =  UIImageView(frame: CGRectMake(15, 10, 50, 50))
            bgview.addSubview(left_img)
            
            name = UILabel(frame: CGRectMake(80, 10, 200, 15))
            name.font = UIFont.systemFontOfSize(15.0)
            
            bgview.addSubview(name)
            
            product = UILabel(frame: CGRectMake(80, 27, 200, 15))
            product.font = UIFont.systemFontOfSize(15.0)
            
            bgview.addSubview(product)
            
            group = UILabel(frame: CGRectMake(80, 44, 200, 15))
            group.font = UIFont.systemFontOfSize(15.0)
            bgview.addSubview(group)
            
            right_img =  UIImageView(frame: CGRectMake(SCREEN_WIDTH-100, 10, 50, 50))
            bgview.addSubview(right_img)
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
