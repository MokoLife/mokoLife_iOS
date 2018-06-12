//
//  MKDeviceListCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@class MKDeviceModel;
@interface MKDeviceListCell : MKBaseCell

@property (nonatomic, strong)MKDeviceModel *dataModel;

+ (MKDeviceListCell *)initCellWithTableView:(UITableView *)tableView;

@end
