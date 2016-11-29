//
//  CircleDataView.swift
//  YISAI
//
//  Created by 周超创 on 16/9/12.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

@IBDesignable
class CircleDataView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var fontSize:CGFloat = 15
    var lineSize:CGFloat = 1
    var process:CGFloat = 0
    @IBInspectable var  progress:CGFloat{
        get{
            return process
        }
        set(newval) {
            let val = newval*3.6
            self.process = val
            setNeedsDisplay()
        }
    }
    override func drawRect(rect: CGRect) {
        
        // println("开始画画.........")
        
        
        //获取画图上下文
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        
        
        //移动坐标
        let x = frame.size.width/2
        let y = frame.size.height/2
        var center = CGPointMake(x,y)
        
        
        //第一段文本
        let font:UIFont! = UIFont.systemFontOfSize(fontSize)
        var textAttributes: [String: AnyObject] = [
            NSForegroundColorAttributeName :  UIColor.grayColor(),
            NSFontAttributeName:font
        ]
        
        
        // println("\(process)...............")
        
        let showp = process/3.6
        
        let str = NSAttributedString(string: "\(Int(showp))%", attributes: textAttributes)
        
        let size:CGSize = str.size()
        
        let stry:CGFloat = y-(size.height/2)
        let stryend:CGFloat = y+(size.height/2)
        
        
        str.drawAtPoint(CGPointMake(x-(size.width/2),stry-5))
     /*   //第二段文本
        let tips:NSString = "保本保收益"
        var textAttributes2: [String: AnyObject] = [
            NSForegroundColorAttributeName : UIColor(white: 0.0, alpha: 1.0),
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize/2)
        ]
        let tipsSize:CGSize = tips.sizeWithAttributes(textAttributes2)
        
        tips.drawAtPoint(CGPointMake(x-(tipsSize.width/2), stryend), withAttributes: textAttributes2)
        
        */
        //灰色圆圈
        let radius = frame.size.width/2-20
        CGContextSetLineWidth(context, 0.5)
        
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextAddArc(context, x, y, radius-4, 0, 360, 0)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        
        //两个圆圈
        CGContextSetLineWidth(context, lineSize)
        
        CGContextSetStrokeColorWithColor(context, UIColor.yellowColor().CGColor)
        CGContextAddArc(context, x, y, radius, 0, 360, 0)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        //
        CGContextSetStrokeColorWithColor(context,  UIColor.greenColor().CGColor)
        process  = process * CGFloat(M_PI/180.0)
        CGContextAddArc(context, x, y, radius,0, process, 0)
        
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        
        // println("结束画画........")
        
        
    }
    
    
}
