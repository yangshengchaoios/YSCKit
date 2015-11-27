//
//  EZGCommonHeaderView.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/20.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "EZGCommonHeaderView.h"

@implementation EZGCommonHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundColor = kDefaultViewColor;
    self.bkgImageView.hidden = YES;
    self.lineBottomLabel.hidden = YES;
    self.arrowImageView.hidden = YES;
    self.leftSpace.constant = AUTOLAYOUT_LENGTH(20);
}

+ (CGFloat)HeightOfViewByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(70);
}

@end
