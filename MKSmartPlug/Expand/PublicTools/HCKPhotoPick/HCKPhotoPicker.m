//
//  HCKPhotoPicker.m
//  FitPolo
//
//  Created by aa on 2018/5/29.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "HCKPhotoPicker.h"

@interface HCKPhotoPicker()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy)void (^pickPhotoBlock)(UIImage *bigImage, UIImage *smallImage);

@end

@implementation HCKPhotoPicker

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"HCKPhotoPicker销毁");
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    WS(weakSelf);
    //获取相册选取或者拍照的原始图片
    UIImage *bigImage;
    if (picker.allowsEditing) {
        bigImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        bigImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //1、子线程1：保存图片到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//如果是相机，则保存图片到相册
            UIImageWriteToSavedPhotosAlbum(bigImage,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    }
    dispatch_queue_t queueSave = dispatch_queue_create("savePending",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueSave, ^{
        //将大图处理成小图
        UIImage *smallImage = [UIImage handleImageBeforeUploadWithImage:bigImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.pickPhotoBlock) {
                weakSelf.pickPhotoBlock(bigImage, smallImage);
            }
            [picker dismissViewControllerAnimated:NO completion:nil];
        });
    });
}
//保存到相册失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        return;
    }
}

#pragma mark - event method

- (void)openCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [kAppRootController presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"The camera is not available"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"HCKPersonInfoSetController_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"HCKPersonInfoSetController_ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)openPhoto{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [kAppRootController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - public method
/**
 相机或者相册选择照片

 @param block 选择之后的回调，bigImage:原图，smallImage:处理之后的小图
 */
- (void)showPhotoPickerBlock:(void (^)(UIImage *bigImage, UIImage *smallImage))block{
    self.pickPhotoBlock = nil;
    self.pickPhotoBlock = block;
    [self showActionSheet];
}

#pragma mark - private method
- (void)showActionSheet{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:LS(@"HCKPersonInfoSetController_camera")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [[HCKSystemResource share] handleAccessCameraWithTarget:self selecter:@selector(openCamera)];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:LS(@"HCKPersonInfoSetController_photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[HCKSystemResource share] handleAccessPhotosWithTarget:self selecter:@selector(openPhoto)];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"HCKPersonInfoSetController_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

@end
