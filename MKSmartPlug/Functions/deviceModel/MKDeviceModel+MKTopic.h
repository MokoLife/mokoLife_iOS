//
//  MKDeviceModel+MKTopic.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel (MKTopic)

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect:(MKDeviceType)deviceType;

/**
 订阅的主题
 
 @param topicType 主题类型，是app发布数据的主题还是设备发布数据的主题
 @param function 主题功能
 @return 设备功能/设备名称/型号/mac/topicType/function
 */
- (NSString *)subscribeTopicInfoWithType:(deviceModelTopicType)topicType
                                function:(NSString *)function;

/**
 app可以订阅的主题

 @return topicList
 */
- (NSArray <NSString *>*)allTopicList;

@end
