//
//  EZGMessageServiceCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageServiceCell.h"

@implementation EZGMessageServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.serviceTitleLabel.backgroundColor = [UIColor clearColor];
    self.serviceTitleLabel.textColor = kDefaultTextColorBlack1;
    self.serviceTitleLabel.font = AUTOLAYOUT_FONT(self.serviceTitleLabel.font.pointSize);
    
    self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
    
    self.serviceDetailLabel.backgroundColor = [UIColor clearColor];
    self.serviceDetailLabel.textColor = kDefaultTextColorBlack1;
    self.serviceDetailLabel.font = AUTOLAYOUT_FONT(self.serviceDetailLabel.font.pointSize);
    
    self.overLabel.backgroundColor = [UIColor clearColor];
    self.overLabel.textColor = [UIColor whiteColor];
    self.overLabel.font = AUTOLAYOUT_FONT(self.overLabel.font.pointSize);
    self.overLabel.width = AUTOLAYOUT_LENGTH(300);
    self.overLabel.height = AUTOLAYOUT_LENGTH(80);
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGServiceMessage *)message {
    return AUTOLAYOUT_SIZE_WH(300 + 14, 160);
}
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(EZGServiceMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    CGFloat cellHeight = [super HeightOfCellByMessage:message displaysTimestamp:displayTimestamp];
    if (EZGServiceTypeOver == [message.attributes[MParamServiceType] integerValue]) {
        return cellHeight + AUTOLAYOUT_LENGTH(80) + 2 * kXHLabelPadding;
    }
    else {
        return cellHeight;
    }
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGServiceMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.serviceTitleLabel.text = message.text;
    self.serviceDetailLabel.text = message.attributes[MParamDetailInfo];

    //设置详细内容显示样式
    EZGServiceType serviceType = [message.attributes[MParamServiceType] integerValue];
    if (EZGServiceTypeOver == serviceType) {//服务结束(有结束标志！)
        self.overLabel.hidden = NO;
        self.overLabel.text = [NSString stringWithFormat:@"%@\r\n本次服务已结束", [self formatMessageTimeByTimeStamp:message.sendTimestamp]];
        self.serviceDetailLabel.textAlignment = NSTextAlignmentCenter;
        self.serviceDetailLabel.numberOfLines = 1;
    }
    else if (EZGServiceTypeResume == serviceType) {//取消放弃操作
        self.overLabel.hidden = YES;
        self.serviceDetailLabel.textAlignment = NSTextAlignmentCenter;
        self.serviceDetailLabel.numberOfLines = 1;
    }
    else {
        self.overLabel.hidden = YES;
        self.serviceDetailLabel.textAlignment = NSTextAlignmentLeft;
        self.serviceDetailLabel.numberOfLines = 2;
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.serviceTitleLabel sizeToFit];
    self.serviceTitleLabel.width = self.bubbleImageView.width - (kXHBubbleMarginLeft + kXHBubbleArrowWidth + kXHBubbleMarginRight);
    self.serviceTitleLabel.top = self.bubbleImageView.top + kXHBubbleMarginTop;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.serviceTitleLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginLeft;
    }
    else {
        self.serviceTitleLabel.left = self.bubbleImageView.left + kXHBubbleMarginLeft;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.serviceTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.serviceTitleLabel.frame) + kXHBubbleMarginTop;
    self.separationLineLabel.width = self.bubbleImageView.width - (kXHBubbleMarginLeft + kXHBubbleArrowWidth + kXHBubbleMarginRight);
    
    //调整说明信息位置
    self.serviceDetailLabel.width = self.serviceTitleLabel.width;
    self.serviceDetailLabel.height = self.bubbleImageView.bottom - self.separationLineLabel.bottom - 2;
    self.serviceDetailLabel.centerX = self.separationLineLabel.centerX;
    self.serviceDetailLabel.top = self.separationLineLabel.bottom + 1;
    
    //调整结束信息位置
    self.overLabel.top = self.bubbleImageView.bottom + kXHLabelPadding;
    self.overLabel.centerX = SCREEN_WIDTH / 2;
}

@end