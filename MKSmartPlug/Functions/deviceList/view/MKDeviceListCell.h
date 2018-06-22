//
//  MKDeviceListCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@protocol MKDeviceListCellDelegate;
@interface MKDeviceListCell : MKBaseCell

@property (nonatomic, weak)id <MKDeviceListCellDelegate>delegate;

@property (nonatomic, strong)MKDeviceModel *dataModel;

+ (MKDeviceListCell *)initCellWithTableView:(UITableView *)tableView;

@end

@protocol MKDeviceListCellDelegate <NSObject>

@optional
- (void)deviceSwitchStateChanged:(MKDeviceModel *)deviceModel isOn:(BOOL)isOn;

@end
