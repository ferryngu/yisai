//
//  CameraPreviewView.swift
//  Crummy
//
//  Created by Yufate on 15/5/14.
//  Copyright (c) 2015年 Columbia University. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
     private  var previewLayer: AVCaptureVideoPreviewLayer!
    
  /*
    // AVCaptureVideoPreviewLayer 预览图层，来显示照相机拍摄到的画面
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder() as! AVCaptureVideoPreviewLayer.Type
    }
    //AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
    var session: AVCaptureSession! {
        get { return (layer as! AVCaptureVideoPreviewLayer).session }
        set(newSession) {
            (layer as! AVCaptureVideoPreviewLayer).session = newSession
        }
    }*/
    
    func commonInit(session1: AVCaptureSession) {
        // set the resize model
        
        previewLayer =  AVCaptureVideoPreviewLayer(session:session1)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        // add the previewLayer
        layer.addSublayer(previewLayer)
        clipsToBounds = true
    }
}
