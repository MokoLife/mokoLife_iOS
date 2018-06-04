//
//  MKNotBlinkAmberController.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseViewController.h"

@interface MKNotBlinkAmberController : MKBaseViewController

@property (nonatomic, copy)void (^blinkButtonPressedBlock)(void);

@end
