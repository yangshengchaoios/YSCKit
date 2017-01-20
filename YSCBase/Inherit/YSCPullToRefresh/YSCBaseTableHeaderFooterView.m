//
//  YSCBaseTableHeaderFooterView.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCBaseTableHeaderFooterView.h"

@implementation YSCBaseTableHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
}

+ (void)registerHeaderFooterToTableView:(UITableView *)tableView {
    NSString *headerFooterName = NSStringFromClass(self.class);
    if (IS_NIB_EXISTS(headerFooterName)) {
        [tableView registerNib:[UINib nibWithNibName:headerFooterName bundle:nil]
forHeaderFooterViewReuseIdentifier:headerFooterName];
    }
    else {
        [tableView registerClass:self.class forHeaderFooterViewReuseIdentifier:headerFooterName];
    }
}
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(self.class)];
}

+ (CGFloat)heightOfViewByObject:(NSObject *)object {
    return 35.0f;
}
- (void)layoutObject:(NSObject *)object {}

@end
