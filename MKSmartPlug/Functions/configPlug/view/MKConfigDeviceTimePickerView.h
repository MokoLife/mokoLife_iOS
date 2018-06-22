//
//  MKConfigDeviceTimePickerView.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConfigDeviceTimeModel : NSObject

@property (nonatomic, copy)NSString *hour;

@property (nonatomic, copy)NSString *minutes;

@property (nonatomic, copy)NSString *titleMsg;

@end

@interface MKConfigDeviceTimePickerView : UIView

@property (nonatomic, strong)MKConfigDeviceTimeModel *timeModel;

- (void)showTimePickViewBlock:(void (^)(MKConfigDeviceTimeModel *timeModel))Block;

@end
