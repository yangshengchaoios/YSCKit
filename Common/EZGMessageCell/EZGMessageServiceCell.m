//
//  EZGMessageServiceCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageServiceCell.h"

@implementation EZGMessageServiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.serviceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.separationLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.serviceDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.overLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.serviceTitleLabel];
        [self.contentView addSubview:self.separationLineLabel];
        [self.contentView addSubview:self.serviceDetailLabel];
        [self.contentView addSubview:self.overLabel];
        
        self.serviceTitleLabel.backgroundColor = [UIColor clearColor];
        self.serviceTitleLabel.textColor = kBubbleTitleFontColor;
        self.serviceTitleLabel.font = kBubbleTitleFont;
        self.serviceTitleLabel.numberOfLines = 2;
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        self.separationLineLabel.backgroundColor = kDefaultBorderColor;
        
        self.serviceDetailLabel.backgroundColor = [UIColor clearColor];
        self.serviceDetailLabel.textColor = kBubbleDetailFontColor;
        self.serviceDetailLabel.font = kBubbleDetailFont;
        self.serviceDetailLabel.numberOfLines = 0;
        self.serviceDetailLabel.textAlignment = NSTextAlignmentLeft;
        
        self.overLabel.backgroundColor = RGB(177, 177, 177);
        self.overLabel.textColor = [UIColor whiteColor];
        self.overLabel.numberOfLines = 2;
        self.overLabel.textAlignment = NSTextAlignmentCenter;
        [self.overLabel makeRoundWithRadius:5];
        self.overLabel.font = AUTOLAYOUT_FONT(24);
        self.overLabel.width = AUTOLAYOUT_LENGTH(300);
        self.overLabel.height = AUTOLAYOUT_LENGTH(80);
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(EZGServiceMessage *)message {
    CGFloat titleHeight = [NSString HeightOfNormalString:Trim(message.text)
                                                maxWidth:kBubbleServiceTextWidth
                                                withFont:kBubbleTitleFont];
    CGFloat detailInfoHeight = [NSString HeightOfNormalString:Trim(message.attributes[MParamDetailInfo])
                                                   maxWidth:kBubbleServiceTextWidth
                                                   withFont:kBubbleDetailFont];
    CGFloat contentHeight = titleHeight + detailInfoHeight + kXHBubbleMarginVer * 0.5 + AUTOLAYOUT_LENGTH(1);
    contentHeight = MAX(AUTOLAYOUT_LENGTH(160), contentHeight);
    return CGSizeMake(kBubbleServiceWidth, contentHeight);
}
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(EZGServiceMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    CGFloat cellHeight = [super HeightOfCellByMessage:message displaysTimestamp:displayTimestamp];
    if (EZGServiceTypeOver == [message.attributes[MParamServiceType] integerValue]) {
        return cellHeight + AUTOLAYOUT_LENGTH(80) + kXHLabelPadding;
    }
    else {
        return cellHeight;
    }
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGServiceMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.serviceTitleLabel.text = Trim(message.text);
    self.serviceDetailLabel.text = Trim(message.attributes[MParamDetailInfo]);
    //设置详细内容显示样式
    if (EZGServiceTypeOver == [message.attributes[MParamServiceType] integerValue]) {//服务结束(有结束标志！)
        self.overLabel.hidden = NO;
        self.overLabel.text = [NSString stringWithFormat:@"%@\r\n本次服务已结束", [self formatMessageTimeByTimeStamp:message.sendTimestamp]];
    }
    else {
        self.overLabel.hidden = YES;
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = [self calculateContentFrame];
    
    //调整标题位置
    [self.serviceTitleLabel sizeToFit];
    self.serviceTitleLabel.origin = contentFrame.origin;
    self.serviceTitleLabel.width = contentFrame.size.width;
    
    //调整分割线位置
    self.separationLineLabel.left = self.serviceTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.serviceTitleLabel.frame) + kXHBubbleMarginVer / 2;
    self.separationLineLabel.width = self.serviceTitleLabel.width;
    
    //调整说明信息位置
    [self.serviceDetailLabel sizeToFit];
    self.serviceDetailLabel.top = self.separationLineLabel.bottom;
    self.serviceDetailLabel.left = self.serviceTitleLabel.left;
    self.serviceDetailLabel.width = self.serviceTitleLabel.width;
    self.serviceDetailLabel.height = CGRectGetMaxY(contentFrame) - self.separationLineLabel.bottom;
    
    //调整结束信息位置
    self.overLabel.top = self.bubbleImageView.bottom + kXHLabelPadding;
    self.overLabel.centerX = SCREEN_WIDTH / 2;
}

@end
