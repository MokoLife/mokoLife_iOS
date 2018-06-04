//
//  MKSystemResource.m
//  FitPolo
//
//  Created by aa on 17/7/4.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKSystemResource.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>

@implementation MKSystemResource

+ (instancetype)share{
    static dispatch_once_t t;
    static MKSystemResource *service = nil;
    dispatch_once(&t, ^{
        service = [[MKSystemResource alloc] init];
    });
    return service;
}

+ (BOOL)isAlowPosition;{
    return ([CLLocationManager locationServicesEnabled]
            && ( kCLAuthorizationStatusDenied !=  [CLLocationManager authorizationStatus]));
}

+ (BOOL)isAllowAccessCamera{
    AVAuthorizationStatus AVStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (BOOL)isAllowAccessPhotos{
    PHAuthorizationStatus ALStatus = [PHPhotoLibrary authorizationStatus];
    if (ALStatus == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (BOOL)isAllowAccessMicrophone{
    __block BOOL bCanRecord = YES;
    if (iOS7) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
}

+ (BOOL)isAllowAccessTelephone{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPod touch"]
       || [deviceType isEqualToString:@"iPad"]
       || [deviceType isEqualToString:@"iPhone Simulator"]){
        return NO;
    }
    return YES;
}

/**
 *  2016年09月03日 add by 胡仕君： 处理调用相机
 *
 *  @param target   响应方法的界面
 *  @param selector 允许使用相机资源后调用的方法
 */
- (void)handleAccessCameraWithTarget:(id) target selecter:(SEL)selector
{
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector];
    [[MKSystemResource share] handleAccessCamera:invocation];
}

/**
 *  2016年09月03日 add by 胡仕君： 处理调用相册
 *
 *  @param target   响应方法的界面
 *  @param selector 允许使用相册资源后调用的方法
 */
- (void)handleAccessPhotosWithTarget:(id) target selecter:(SEL)selector
{
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector];
    [[MKSystemResource share] handleAccessPhotos:invocation];
}

/**
 2016年09月19日 add by 胡仕君：处理调用麦克风
 
 @param target   响应方法的界面
 @param selector 允许使用麦克风资源后调用的方法
 */
- (void)handleAccessMicrophoneWithTarget:(id) target selecter:(SEL)selector
{
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector];
    [[MKSystemResource share] handleAccessMicrophone:invocation];
}

- (void)handleAccessCamera:(NSInvocation *)allowInvocation
{
    if ([[self class] isAllowAccessCamera])
        {
        [allowInvocation invoke];
        return;
        }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *promtpMessage = LS(@"MKSystemResource_camera");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:promtpMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] skipToPrivacy];
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
    }
    
    if(status == AVAuthorizationStatusNotDetermined)
        {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted)
         {
         
         BOOL isMain = [[NSThread currentThread] isMainThread];
         if (isMain)
             {
             if(granted)
                 {
                 [allowInvocation invoke];
                 } else {
                     [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
                 }
             }
         
         else{
             dispatch_sync(dispatch_get_main_queue(), ^{
                 if(granted)
                     {
                     [allowInvocation invoke];
                     } else {
                         [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
                     }
             });
         }
         }];
        }
}

- (void)handleAccessPhotos:(NSInvocation *)allowInvocation{
    if ([[self class] isAllowAccessPhotos])
        {
        [allowInvocation invoke];
        return;
        }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [allowInvocation invoke];
        return;
    }
    
    NSString *promtpMessage = LS(@"MKSystemResource_photo");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:promtpMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] skipToPrivacy];
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
}

- (void)handleAccessMicrophone:(NSInvocation *)allowInvocation{
    if ([[self class] isAllowAccessMicrophone])
        {
        [allowInvocation invoke];
        return;
        }
    NSString *promtpMessage = LS(@"MKSystemResource_video");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:promtpMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"MKAdvancedController_ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] skipToPrivacy];
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
}

@end
