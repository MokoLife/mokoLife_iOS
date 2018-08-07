//
//  MKModifyLocalNameView.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKModifyLocalNameView : UIView

- (void)showConnectAlertView:(NSString *)text block:(void (^)(NSString *name))block;

@end
