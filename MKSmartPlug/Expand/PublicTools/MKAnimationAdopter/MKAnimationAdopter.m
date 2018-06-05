//
//  MKAnimationAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAnimationAdopter.h"

@implementation MKAnimationAdopter

/**
 圆环动画
 
 @param endValue 动画结束时的位置
 @return animation
 */
+ (CABasicAnimation *)circleAnimationWithEndValue:(CGFloat)endValue{
    CABasicAnimation * circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = 1;
    circleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    circleAnimation.fromValue = @(0);
    circleAnimation.toValue = @(endValue);
    circleAnimation.autoreverses = NO;
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.removedOnCompletion = NO;
    return circleAnimation;
}

@end
