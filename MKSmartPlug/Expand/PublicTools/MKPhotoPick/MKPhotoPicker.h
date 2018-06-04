//
//  MKPhotoPicker.h
//  FitPolo
//
//  Created by aa on 2018/5/29.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseDataModel.h"

@interface MKPhotoPicker : MKBaseDataModel

/**
 相机或者相册选择照片
 
 @param block 选择之后的回调，bigImage:原图，smallImage:处理之后的小图
 */
- (void)showPhotoPickerBlock:(void (^)(UIImage *bigImage, UIImage *smallImage))block;

@end
