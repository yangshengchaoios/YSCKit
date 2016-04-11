//
//  BaseTableViewHeaderFooterView.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseTableHeaderFooterView.h"

NSString * const kParamHeaderIdentifier     = @"YSCKit_Header";
NSString * const kParamFooterIdentifier     = @"YSCKit_Footer";

@implementation YSCBaseTableHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    [self resetSize];
}

#pragma mark - 注册与重用
+ (void)registerHeaderFooterToTableView:(UITableView *)tableView {
    [tableView registerNib:[[self class] nibNameOfView] forHeaderFooterViewReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView {
    YSCBaseTableHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[[self class] identifier]];
    return header;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)nibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算高度
+ (CGFloat)heightOfViewByObject:(NSObject *)object {
    return 35.0f;
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object {}

@end
