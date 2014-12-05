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
    
    self.subTitleLeading.constant = AUTOLAYOUT_LENGTH(347);
    self.subTitleLeading1.constant = AUTOLAYOUT_LENGTH(547);
    self.subTitleTrailing.constant = AUTOLAYOUT_LENGTH(40);
    self.subTitleCenterY.constant = AUTOLAYOUT_LENGTH(0);
    
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
        self.stateChanged = nil;
        
        //控制arrow是否显示
        if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
            self.arrowImageView.hidden = NO;
        }
        else {
            self.arrowImageView.hidden = YES;
        }
        
        self.subTitleLeading.priority = UILayoutPriorityDefaultLow;
        self.subTitleLeading1.priority = UILayoutPriorityDefaultLow;
        self.subTitleTrailing.priority = UILayoutPriorityDefaultLow;
        
        //控制subtitle的显示位置
        if (YSCTableViewCellStyleSubtitleRight == (YSCTableViewCellStyleSubtitleRight & style)) {
            self.subtitleLabel.hidden = NO;
            self.subTitleTrailing.priority = UILayoutPriorityRequired;
            self.subTitleLeading1.constant = 0;
            if (YSCTableViewCellStyleArrow == (YSCTableViewCellStyleArrow & style)) {
                self.subTitleTrailing.constant = AUTOLAYOUT_LENGTH(40);
            }
            else {
                self.subTitleTrailing.constant = AUTOLAYOUT_LENGTH(20);
            }
        }
        else if (YSCTableViewCellStyleSubtitleLeft == (YSCTableViewCellStyleSubtitleLeft & style)) {
            self.subtitleLabel.hidden = NO;
            self.subTitleLeading.priority = UILayoutPriorityRequired;
            self.subTitleLeading.constant = AUTOLAYOUT_LENGTH(10);
        }
        else if (YSCTableViewCellStyleSubtitleBottom == (YSCTableViewCellStyleSubtitleBottom & style)) {
            self.subtitleLabel.hidden = NO;
            self.subTitleLeading1.priority = UILayoutPriorityRequired;
            self.subTitleCenterY.constant = -10;
            self.titleCenterY.constant = 10;
            
            if (YSCTableViewCellStyleIcon == (YSCTableViewCellStyleIcon & style)) {
                self.subTitleLeading1.constant = AUTOLAYOUT_LENGTH(88);
            }
            else {
                self.subTitleLeading1.constant = AUTOLAYOUT_LENGTH(20);
            }
        }
        else {
            self.subtitleLabel.hidden = YES;
            self.subTitleLeading.priority = UILayoutPriorityRequired;
            self.subTitleLeading.constant = 0;
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
