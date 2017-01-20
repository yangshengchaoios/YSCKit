//
//  YSCBaseTableViewCell.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCBaseTableViewCell.h"

@implementation YSCBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder*)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //NOTE:解决UITableViewCell Color和设置的seperatorColor不一致问题
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

+ (void)registerCellToTableView:(UITableView *)tableView {
    NSString *cellName = NSStringFromClass(self.class);
    if (IS_NIB_EXISTS(cellName)) {
        [tableView registerNib:[UINib nibWithNibName:cellName bundle:nil]
        forCellReuseIdentifier:cellName];
    }
    else {
        [tableView registerClass:self.class forCellReuseIdentifier:cellName];
    }
}
+ (instancetype)dequeueCellByTableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
}

+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 44;
}
- (void)layoutObject:(NSObject *)object { }

@end
