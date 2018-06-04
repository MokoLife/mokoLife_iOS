//
//  MKSelectDeviceTypeCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKSelectDeviceTypeModel;
@interface MKSelectDeviceTypeCell : UITableViewCell

@property (nonatomic, strong)MKSelectDeviceTypeModel *dataModel;

+ (MKSelectDeviceTypeCell *)initCellWithTable:(UITableView *)tableView;

@end
