//
//  MKMQTTServerInterface.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMQTTServerInterface : NSObject

/**
 改变开关状态
 
 @param isOn isOn
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setSwitchState:(BOOL)isOn deviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target;

@end
