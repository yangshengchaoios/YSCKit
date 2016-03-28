//
//  BaseTableViewCell.m
//  YSCKit
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseTableViewCell.h"

NSString * const kParamCellIdentifier       = @"YSCKit_Cell";

@implementation YSCBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //NOTE:解决UITableViewCell Color和设置的seperatorColor不一致问题
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self resetFontSizeOfView];
    [self resetConstraintOfView];
}

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerNib:[[self class] nibNameOfCell] forCellReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView {
    YSCBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] identifier]];
    return cell;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)nibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算高度
+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 44;
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object { }
@end
