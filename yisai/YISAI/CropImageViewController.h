//
//  CropImageViewController.h
//  crop
//
//  Created by ddapp on 16/4/1.
//  Copyright © 2016年 techinone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CropImageViewController;

typedef void(^CropedImageCallBack)(UIImage *cropImage,CropImageViewController *viewController);

@interface CropImageViewController : UIViewController
@property (assign, nonatomic) CGSize cropSize;
@property (assign, nonatomic, getter=isFixCropSize) BOOL fixCropSize;
- (instancetype)initWithOriginImage:(UIImage *)originImage callBack:(CropedImageCallBack)callBack;
@end
