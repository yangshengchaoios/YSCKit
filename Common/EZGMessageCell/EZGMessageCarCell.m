//
//  EZGMessageCarCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageCarCell.h"

@implementation EZGMessageCarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.carTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.separationLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.carBrandLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.carNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.carTitleLabel];
        [self.contentView addSubview:self.separationLineLabel];
        [self.contentView addSubview:self.carBrandLabel];
        [self.contentView addSubview:self.carNumberLabel];
        
        self.carTitleLabel.backgroundColor = [UIColor clearColor];
        self.carTitleLabel.textColor = kDefaultTextColorBlack1;
        self.carTitleLabel.font = AUTOLAYOUT_FONT(self.carTitleLabel.font.pointSize);
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        
        self.carBrandLabel.backgroundColor = [UIColor clearColor];
        self.carBrandLabel.textColor = kDefaultTextColorBlack1;
        self.carBrandLabel.font = AUTOLAYOUT_FONT(self.carBrandLabel.font.pointSize);
        
        self.carNumberLabel.backgroundColor = [UIColor clearColor];
        self.carNumberLabel.textColor = kDefaultTextColorBlack1;
        self.carNumberLabel.font = AUTOLAYOUT_FONT(self.carNumberLabel.font.pointSize);
    }
    return self;
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGCarMessage *)message {
    return AUTOLAYOUT_SIZE_WH(300 + 14, 160);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGCarMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.carTitleLabel.text = message.text;
    MyCarModel *carModel = [[MyCarModel alloc] initWithString:message.attributes[MParamCarInfo] error:nil];
    self.carBrandLabel.text = [carModel formatCarModelName];
    self.carNumberLabel.text = [carModel formatCarNumber];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.carTitleLabel sizeToFit];
    self.carTitleLabel.width = self.bubbleImageView.width - (kXHBubbleMarginHor + kXHBubbleArrowWidth + kXHBubbleMarginHor);
    self.carTitleLabel.top = self.bubbleImageView.top + kXHBubbleMarginVer;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.carTitleLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginHor;
    }
    else {
        self.carTitleLabel.left = self.bubbleImageView.left + kXHBubbleMarginHor;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.carTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.carTitleLabel.frame) + kXHBubbleMarginVer;
    self.separationLineLabel.width = self.carTitleLabel.width;
    
    //调整车辆信息位置
    [self.carBrandLabel sizeToFit];
    self.carBrandLabel.width = self.carTitleLabel.width;
    self.carBrandLabel.left = self.carTitleLabel.left;
    self.carBrandLabel.top = self.separationLineLabel.bottom + kXHBubbleMarginVer;
    [self.carNumberLabel sizeToFit];
    self.carNumberLabel.width = self.carTitleLabel.width;
    self.carNumberLabel.left = self.carTitleLabel.left;
    self.carNumberLabel.top = self.carBrandLabel.bottom + kXHBubbleMarginVer;
}

@end
