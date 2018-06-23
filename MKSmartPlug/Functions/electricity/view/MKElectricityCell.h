//
//  MKElectricityCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@class MKElectricityModel;
@interface MKElectricityCell : MKBaseCell

@property (nonatomic, strong)MKElectricityModel *dataModel;

+ (MKElectricityCell *)initCellWithTableView:(UITableView *)tableView;

@end
