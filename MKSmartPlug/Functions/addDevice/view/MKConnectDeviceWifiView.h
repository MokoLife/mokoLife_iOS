//
//  MKConnectDeviceWifiView.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConnectDeviceWifiView : UIView

- (void)showAlertViewWithCancelAction:(void (^)(void))cancelAction
                        confirmAction:(void (^)(NSString *wifiSSID, NSString *password))confirmAction;

@end
