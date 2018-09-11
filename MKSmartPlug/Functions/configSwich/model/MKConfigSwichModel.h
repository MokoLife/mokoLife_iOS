//
//  MKConfigSwichModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKConfigSwichModel : NSObject

@property (nonatomic, copy)NSString *countdown;

@property (nonatomic, assign)BOOL isOn;

@property (nonatomic, copy)NSString *currentWaySwitchName;

@property (nonatomic, assign)NSInteger index;

@end
