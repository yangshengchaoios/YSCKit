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
    self.style = YSCTableViewCellStyleTitle;
    self.iconLeading.constant = AUTOLAYOUT_LENGTH(20);
    self.titleLeading.constant = AUTOLAYOUT_LENGTH(20);
    self.subtitleTrailing.constant = AUTOLAYOUT_LENGTH(40);
    self.switchTrailing.constant = AUTOLAYOUT_LENGTH(20);
    self.arrowTrailing.constant = AUTOLAYOUT_LENGTH(20);
    self.seperatorTopHeight.constant = AUTOLAYOUT_LENGTH(1);
    self.seperatorBottomHeight.constant = AUTOLAYOUT_LENGTH(1);
}

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(70);
}

/**
 *  左边只支持以下几种显示格式：
 *  1. 只有title
 *  2. title + icon
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
    if (YSCTableViewCellStyleIcon == (YSCTableViewCellStyleIcon & style)) {
        self.iconImageView.hidden = NO;
        self.iconWidth.constant = AUTOLAYOUT_LENGTH(48);
    }
    else {
        self.titleLeading.constant = 0;
        self.iconImageView.hidden = YES;
        self.iconWidth.constant = 0;
    }
    
    if (YSCTableViewCellStyleSwitch == (YSCTableViewCellStyleSwitch & style)) {
        self.stateSwitch.hidden = NO;
        self.arrowImageView.hidden = YES;
        self.subtitleLabel.hidden = YES;
    }
    else {
        self.stateSwitch.hidden = YES;
        self.stateChanged = nil;
        if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
            self.arrowImageView.hidden = NO;
        }
        else {
            self.arrowImageView.hidden = YES;
        }
        
        if (YSCTableViewCellStyleSubtitle == (YSCTableViewCellStyleSubtitle & style)) {
            self.subtitleLabel.hidden = NO;
            if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
                self.subtitleTrailing.constant = AUTOLAYOUT_LENGTH(40);
            }
            else {
                self.subtitleTrailing.constant = AUTOLAYOUT_LENGTH(20);
            }
        }
        else {
            self.subtitleLabel.hidden = YES;
        }
    }
}

- (IBAction)stateChanged:(id)sender {
    if (YSCTableViewCellStyleSwitch == (YSCTableViewCellStyleSwitch & self.style) &&
        self.stateChanged) {
        self.stateChanged(self.stateSwitch.on);
    }
}

@end
