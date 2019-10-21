//
//  UIView+MKAdd.m
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "UIView+MKAdd.h"

@implementation UIView (MKAdd)

#pragma mark - Base

- (void)addTapAction:(id)target selector:(SEL)selector
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)addLongPressAction:(id)target selector:(SEL)selector
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:selector];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:recognizer];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (UIImage *)screenShotImage{
    if (!self) {
        return nil;
    }
    
    CGSize resultImageSize = CGSizeMake(self.width, self.height);;
    
    UIGraphicsBeginImageContextWithOptions(resultImageSize, YES, 0);
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

/**
 屏幕中间提示，黑条白字

 @param message 提示内容
 */
- (void)showCentralToast:(NSString *)message{
    [self makeToast:message duration:0.8 position:CSToastPositionCenter style:nil];
}


/**
 view图层颜色渐变

 @param startColor 最上面的颜色
 @param endColor 最下面的颜色
 */
- (void)insertColorGradient:(UIColor *)startColor
                andEndColor:(UIColor *)endColor{
    if (![startColor isKindOfClass:[UIColor class]]
        || ![endColor isKindOfClass:[UIColor class]]) {
        return;
    }
    NSArray *colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    NSArray *locations = @[@(0.0),@(1.0)];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    
    [self.layer insertSublayer:headerLayer
                         above:0];
    
}


/**
 绘制颜色渐变的layer

 @param frame layer的坐标
 @param colors 渐变颜色数组
 @param locations 渐变颜色的区间分布
 */
- (void)insertColorGradientWithFrame:(CGRect )frame
                              colors:(NSArray *)colors
                           locations:(NSArray *)locations{
    
    if (!ValidArray(colors) || !ValidArray(locations)) {
        return;
    }
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.frame = frame;
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.startPoint = CGPointMake(0, 1);
    headerLayer.endPoint = CGPointMake(0, 0);
    
    [self.layer insertSublayer:headerLayer
                         below:0];
}

/**
 ** lineView:	   需要绘制成虚线的view
 ** lineLength:	 虚线的宽度
 ** lineSpacing:	虚线的间距
 ** lineColor:	  虚线的颜色
 **/
+ (void)drawDashLine:(UIView *)lineView
          lineLength:(NSInteger)lineLength
         lineSpacing:(NSInteger)lineSpacing
           lineColor:(UIColor *)lineColor{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2,
                                        CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:COLOR_CLEAR_MACROS.CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:@[@(lineLength),@(lineSpacing)]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,
                      NULL,
                      0,
                      0);
    CGPathAddLineToPoint(path,
                         NULL,
                         CGRectGetWidth(lineView.frame),
                         0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
