//
//  MKAnimationAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKAnimationAdopter : NSObject

/**
 圆环动画
 
 @param endValue 动画结束时的位置
 @return animation
 */
+ (CABasicAnimation *)circleAnimationWithEndValue:(CGFloat)endValue;

@end
