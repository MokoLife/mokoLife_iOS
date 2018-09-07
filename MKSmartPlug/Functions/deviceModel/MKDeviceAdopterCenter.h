//
//  MKDeviceAdopterCenter.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDeviceAdopterCenter : NSObject

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect:(MKDeviceType)deviceType;

/**
 根据deviceModel返回当前所有可能订阅的主题

 @param deviceModel deviceModel
 @return 主题列表
 */
+ (NSArray <NSString *>*)allTopicForDevice:(MKDeviceModel *)deviceModel;

@end
