//
//  BaseTableViewCell.h
//  YSCKit
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableViewCell : UITableViewCell

#pragma mark - 注册与重用
+ (void)registerCellToTableView:(UITableView *)tableView;
+ (instancetype)dequeueCellByTableView:(UITableView *)tableView;
+ (NSString *)identifier;
+ (UINib *)NibNameOfCell;

#pragma mark - 计算高度
+ (CGFloat)HeightOfCellByObject:(NSObject *)object;//NOTE:子类只能实现这个
+ (CGFloat)HeightOfCell;//NOTE:子类不能实现该方法，但业务层可以调用该方法

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object;
- (void)layoutDataModel:(BaseDataModel *)dataModel DEPRECATED_ATTRIBUTE;
- (void)layoutDataModels:(NSArray *)dataModelArray DEPRECATED_ATTRIBUTE;

@end
