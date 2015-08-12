//
//  BaseTableViewCell.h
//  YSCKit
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableViewCell : UITableViewCell


+ (instancetype)dequeueCellByTableView:(UITableView *)tableView;
+ (void)registerCellToTableView:(UITableView *)tableView;
+ (NSString *)identifier;

+ (CGFloat)HeightOfCell;
+ (CGFloat)HeightOfCellByDataModel:(BaseDataModel *)dataModel;
+ (UINib *)NibNameOfCell;
- (void)layoutDataModel:(BaseDataModel *)dataModel;
- (void)layoutDataModels:(NSArray *)dataModelArray;

@end
