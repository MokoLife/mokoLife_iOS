//
//  HCKHexKeyboard.h
//  FitPolo
//
//  Created by aa on 2018/3/22.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HCKHexKeyboardInputValueChangedBlock)(NSString *keyboardValue);

@interface HCKHexKeyboard : UIView

/**
 键盘最大输出长度
 */
@property (nonatomic, assign)NSInteger maxOutputLen;

- (void)showHexKeyboardBlock:(HCKHexKeyboardInputValueChangedBlock)block;

@end
