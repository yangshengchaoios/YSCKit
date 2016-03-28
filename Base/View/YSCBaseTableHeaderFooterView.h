//
//  BaseTableViewHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kParamHeaderIdentifier;
FOUNDATION_EXPORT NSString * const kParamFooterIdentifier;

@interface YSCBaseTableHeaderFooterView : UITableViewHeaderFooterView

#pragma mark - 注册与重用
+ (void)registerHeaderFooterToTableView:(UITableView *)tableView;
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView;
+ (NSString *)identifier;
+ (UINib *)nibNameOfView;

#pragma mark - 计算高度
+ (CGFloat)heightOfViewByObject:(NSObject *)object;//NOTE:子类只能实现这个

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object;

@end
