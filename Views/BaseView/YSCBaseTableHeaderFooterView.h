//
//  BaseTableViewHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableHeaderFooterView : UITableViewHeaderFooterView

#pragma mark - 注册与重用
+ (void)registerHeaderFooterToTableView:(UITableView *)tableView;
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView;
+ (NSString *)identifier;
+ (UINib *)NibNameOfView;

#pragma mark - 计算高度
+ (CGFloat)HeightOfViewByObject:(NSObject *)object;//NOTE:子类只能实现这个
+ (CGFloat)HeightOfView DEPRECATED_ATTRIBUTE;//NOTE:子类不能实现该方法，但业务层可以调用该方法

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object;
- (void)layoutDataModel:(BaseDataModel *)dataModel DEPRECATED_ATTRIBUTE;
- (void)layoutDataModels:(NSArray *)dataModelArray DEPRECATED_ATTRIBUTE;

@end
