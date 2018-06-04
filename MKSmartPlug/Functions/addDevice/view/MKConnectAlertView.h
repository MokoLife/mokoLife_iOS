//
//  MKConnectAlertView.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConnectAlertView : UIView

- (instancetype)initWithTitleMsg:(NSString *)titleMsg
                    cancelAction:(void (^)(void))cancelAction
                   confirmAction:(void (^)(void))confirmAction;

@end
