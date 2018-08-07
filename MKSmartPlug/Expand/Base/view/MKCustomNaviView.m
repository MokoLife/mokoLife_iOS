//
//  MKCustomNaviView.m
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKCustomNaviView.h"

@implementation MKCustomNaviView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = MKFont(18);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = COLOR_WHITE_MACROS;
        _titleLabel.backgroundColor = COLOR_CLEAR_MACROS;
        [self addSubview:_titleLabel];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _leftButton.backgroundColor = COLOR_CLEAR_MACROS;
        [_leftButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_leftButton.titleLabel setFont:MKFont(16)];
        [self addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 50,
                                                                  22,
                                                                  40,
                                                                  40)];
        _rightButton.backgroundColor = COLOR_CLEAR_MACROS;
        [_rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_rightButton.titleLabel setFont:MKFont(16)];
        [self addSubview:_rightButton];
        
        _rightCorner = [[UIView alloc] initWithFrame:CGRectMake(35.0f, 7.0f, 7.0f, 7.0f)];
        _rightCorner.hidden = YES;
        _rightCorner.clipsToBounds = YES;
        _rightCorner.layer.cornerRadius = 3.5f;
        _rightCorner.backgroundColor = RGBCOLOR(253, 115, 38);
        [_rightButton addSubview:_rightCorner];
    }
    return self ;
}

- (void)setRightButton:(UIButton *)rightButton{
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    _rightButton = rightButton;
    
    [self addSubview:_rightButton];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat xoffset = 10.0;
    CGFloat yoffset = 10.0;
    
    _leftButton.frame = CGRectMake(xoffset,
                                   22,
                                   140,
                                   40);
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake((self.width - _titleLabel.width) / 2,
                                   (self.height - _titleLabel.height) / 2  + yoffset,
                                   _titleLabel.width, _titleLabel.height);
    [super layoutSubviews];
}

@end
