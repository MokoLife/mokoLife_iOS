//
//  MKConnectDeviceView.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConnectDeviceView : UIView

- (void)showAlertViewWithCancelAction:(void (^)(void))cancelAction confirmAction:(void (^)(void))confirmAction;

@end
