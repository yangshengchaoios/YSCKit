//
//  BaseTableViewHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableHeaderFooterView : UITableViewHeaderFooterView

+ (instancetype)dequeueHeaderByTableView:(UITableView *)tableView;
+ (void)registerHeaderToTableView:(UITableView *)tableView;
+ (NSString *)identifier;
+ (UINib *)NibNameOfView;

+ (CGFloat)HeightOfView DEPRECATED_ATTRIBUTE;
+ (CGFloat)HeightOfViewByObject:(NSObject *)object;

- (void)layoutObject:(NSObject *)object;
- (void)layoutDataModel:(BaseDataModel *)dataModel DEPRECATED_ATTRIBUTE;
- (void)layoutDataModels:(NSArray *)dataModelArray DEPRECATED_ATTRIBUTE;

@end
