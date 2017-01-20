//
//  TestPullToRefreshPromptTableViewCell.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestPullToRefreshPromptTableViewCell.h"

@implementation TestPullToRefreshPromptTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 30;
}

- (void)layoutObject:(SearchPromptModel *)model {
    self.promptTitleLabel.text = TRIM_STRING(model.promptName);
}

@end
