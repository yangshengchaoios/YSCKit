//
//  EZGMessageLocationCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageLocationCell.h"

@implementation EZGMessageLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.bubbleImageView addSubview:self.bubbleLocationImageView];
    self.bubbleLocationImageView.clipsToBounds = YES;
    [self.bubbleLocationImageView addSubview:self.addressLabel];
    self.addressLabel.font = AUTOLAYOUT_FONT(self.addressLabel.font.pointSize);
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMLocationMessage *)message {
    return [self SizeForPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"]];
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMLocationMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.bubbleLocationImageView.image = [UIImage imageNamed:@"Fav_Cell_Loc"];
    self.addressLabel.text = Trim(message.text);
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    //调整默认位置图片大小和位置
    self.bubbleLocationImageView.centerY = self.bubbleImageView.centerY;
    self.bubbleLocationImageView.height = self.bubbleImageView.height - 2.0;
    self.bubbleLocationImageView.width = self.bubbleImageView.width - kXHBubbleArrowWidth - 2;
    
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleLocationImageView.left = self.bubbleImageView.left - kXHBubbleArrowWidth - 1;
    }
    else {
        self.bubbleLocationImageView.right = self.bubbleImageView.right - kXHBubbleArrowWidth - 1;
    }
    
    //调整文字大小和位置
    self.addressLabel.width = self.bubbleLocationImageView.width - 2;
    [self.addressLabel sizeToFit];
    self.addressLabel.height += 4;
    self.addressLabel.left = self.bubbleLocationImageView.left - 1;
    self.addressLabel.bottom = self.bubbleLocationImageView.bottom - 1;
}

@end
