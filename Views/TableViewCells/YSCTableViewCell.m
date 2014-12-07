//
//  YSCTableViewCell.m
//  KQ
//
//  Created by yangshengchao on 14/11/17.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCTableViewCell.h"

@implementation YSCTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconLeading.constant = AUTOLAYOUT_LENGTH(20);
    self.iconWidth.constant = AUTOLAYOUT_LENGTH(48);
    
    self.titleLeading.constant = AUTOLAYOUT_LENGTH(88);
    self.titleCenterY.constant = AUTOLAYOUT_LENGTH(0);
    
    self.seperatorTopHeight.constant = AUTOLAYOUT_LENGTH(1);
    self.seperatorBottomLeading.constant = AUTOLAYOUT_LENGTH(88);
    self.seperatorBottomHeight.constant = AUTOLAYOUT_LENGTH(1);
    
    self.switchTrailing.constant = AUTOLAYOUT_LENGTH(20);
    self.arrowTrailing.constant = AUTOLAYOUT_LENGTH(20);
    
    self.style = YSCTableViewCellStyleTitle;
}

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(70);
}

/**
 *  左边只支持以下几种显示格式：
 *  1. 只有title
 *  2. title + icon
 *  3. title + subtitle
 *  4. title + subtitle + icon
 *  右边只支持以下几种显示格式：
 *  1. 无
 *  2. 只有switch
 *  3. 只有arrow
 *  4. 只有subtitle
 *  5. arrow + subtitle
 *
 *  @param style
 */
- (void)setStyle:(YSCTableViewCellStyle)style {
    _style = style;
    //控制icon是否显示
    if (YSCTableViewCellStyleIcon == (YSCTableViewCellStyleIcon & style)) {
        self.iconImageView.hidden = NO;
        self.titleLeading.constant = AUTOLAYOUT_LENGTH(88);
    }
    else {
        self.iconImageView.hidden = YES;
        self.titleLeading.constant = AUTOLAYOUT_LENGTH(20);
        self.seperatorBottomLeading.constant = AUTOLAYOUT_LENGTH(20);
    }
    
    //控制seperator top是否显示
    if (YSCTableViewCellStyleSeperatorTop == (YSCTableViewCellStyleSeperatorTop & style)) {
        self.seperatorTopLabel.hidden = NO;
    }
    else {
        self.seperatorTopLabel.hidden = YES;
    }
    //控制seperator bottom是否显示
    if (YSCTableViewCellStyleSeperatorBottom == (YSCTableViewCellStyleSeperatorBottom & style)) {
        self.seperatorBottomLabel.hidden = NO;
    }
    else {
        self.seperatorBottomLabel.hidden = YES;
    }
    
    //控制switch是否显示
    if (YSCTableViewCellStyleSwitch == (YSCTableViewCellStyleSwitch & style)) {
        self.stateSwitch.hidden = NO;
        self.arrowImageView.hidden = YES;
        self.subtitleLabel.hidden = YES;
    }
    else {
        self.stateSwitch.hidden = YES;
        self.subtitleLabel.hidden = NO;
        self.stateChanged = nil;
        
        //控制arrow是否显示
        if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
            self.arrowImageView.hidden = NO;
        }
        else {
            self.arrowImageView.hidden = YES;
        }
        
        //控制subtitle的显示位置
        [self.subtitleLabel autoRemoveConstraintsAffectingView];
        if (YSCTableViewCellStyleSubtitleRight == (YSCTableViewCellStyleSubtitleRight & style)) {
            [self.subtitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.containerView withOffset:0];
            if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
                [self.subtitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.arrowImageView withOffset:AUTOLAYOUT_LENGTH(20)];
            }
            else {
                [self.subtitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.containerView withOffset:AUTOLAYOUT_LENGTH(-20)];
            }
        }
        else if (YSCTableViewCellStyleSubtitleLeft == (YSCTableViewCellStyleSubtitleLeft & style)) {
            [self.subtitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.containerView withOffset:0];
            [self.subtitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:AUTOLAYOUT_LENGTH(20)];
        }
        else if (YSCTableViewCellStyleSubtitleBottom == (YSCTableViewCellStyleSubtitleBottom & style)) {
            self.titleCenterY.constant = AUTOLAYOUT_LENGTH(15);
            [self.subtitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.containerView withOffset:AUTOLAYOUT_LENGTH(15)];
            [self.subtitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel withOffset:0];
        }
        else {
            self.subtitleLabel.hidden = YES;
        }
    }
}

- (IBAction)stateChanged:(id)sender {
    if (YSCTableViewCellStyleSwitch == (YSCTableViewCellStyleSwitch & self.style) && self.stateChanged) {
        self.stateChanged(self.stateSwitch.on);
    }
}

@end
