//
//  EZGMessageSceneCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageSceneCell.h"

#define kXHBubbleMarginPhoto        AUTOLAYOUT_LENGTH(8)    //现场图片四周边距

@implementation EZGMessageSceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sceneTextLabel.backgroundColor = [UIColor clearColor];
    self.sceneTextLabel.textColor = kDefaultTextColorBlack1;
    self.sceneTextLabel.font = AUTOLAYOUT_FONT(self.sceneTextLabel.font.pointSize);
    
    self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGSceneMessage *)message {
    return AUTOLAYOUT_SIZE_WH(300 + 14, 160);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGSceneMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.sceneTextLabel.text = message.text;
    
    if (EZGSceneTypeSingleCar == [message.attributes[MParamSceneType] integerValue]) {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"singlecar"];
    }
    else {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"multicar"];
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.sceneTextLabel sizeToFit];
    self.sceneTextLabel.width = self.bubbleImageView.width - (kXHBubbleMarginLeft + kXHBubbleArrowWidth + kXHBubbleMarginRight);
    self.sceneTextLabel.top = self.bubbleImageView.top + kXHBubbleMarginTop;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.sceneTextLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginLeft;
    }
    else {
        self.sceneTextLabel.left = self.bubbleImageView.left + kXHBubbleMarginLeft;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.sceneTextLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.sceneTextLabel.frame) + kXHBubbleMarginTop;
    self.separationLineLabel.width = self.sceneTextLabel.width;
    
    //调整图片位置
    self.bubbleSceneImageView.top = self.separationLineLabel.bottom + kXHBubbleMarginPhoto;
    self.bubbleSceneImageView.left = self.separationLineLabel.left - kXHBubbleMarginLeft + kXHBubbleMarginPhoto;
    self.bubbleSceneImageView.width = self.bubbleImageView.width - (kXHBubbleMarginPhoto + kXHBubbleArrowWidth + kXHBubbleMarginPhoto);
    self.bubbleSceneImageView.height = self.bubbleImageView.bottom - self.separationLineLabel.bottom - 2 * kXHBubbleMarginPhoto;
}

@end
