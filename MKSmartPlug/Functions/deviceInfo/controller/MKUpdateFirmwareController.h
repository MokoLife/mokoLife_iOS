//
//  MKUpdateFirmwareController.h
//  MKSmartPlug
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseViewController.h"

extern NSString *const updateTopic;
extern NSString *const updateResultTopic;
extern NSString *const deviceMacAddress;

@interface MKUpdateFirmwareController : MKBaseViewController

@property (nonatomic, strong)NSDictionary *topicParam;

@end
