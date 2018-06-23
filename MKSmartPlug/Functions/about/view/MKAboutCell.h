//
//  MKAboutCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@class MKAboutModel;
@interface MKAboutCell : MKBaseCell

@property (nonatomic, strong)MKAboutModel *dataModel;

+ (MKAboutCell *)initCellWithTableView:(UITableView *)tableView;

@end
