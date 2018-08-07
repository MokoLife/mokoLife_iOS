//
//  MKConfigServerController.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseViewController.h"

typedef NS_ENUM(NSInteger, MKConfigServerControllerType) {
    MKConfigServerForApp,       //app的mqtt服务器配置页面
    MKConfigServerForSmartPlug, //设备的mqtt服务器配置页面
    
};

@interface MKConfigServerController : MKBaseViewController

@property (nonatomic, assign)MKConfigServerControllerType controllerType;

@end
