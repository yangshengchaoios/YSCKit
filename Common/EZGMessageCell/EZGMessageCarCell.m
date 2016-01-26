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
        self.carTitleLabel.textColor = kBubbleTitleFontColor;
        self.carTitleLabel.font = kBubbleTitleFont;
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        self.separationLineLabel.backgroundColor = kDefaultBorderColor;
        
        self.carBrandLabel.backgroundColor = [UIColor clearColor];
        self.carBrandLabel.textColor = kBubbleDetailFontColor;
        self.carBrandLabel.font = kBubbleDetailFont;
        self.carBrandLabel.numberOfLines = 2;
        
        self.carNumberLabel.backgroundColor = [UIColor clearColor];
        self.carNumberLabel.textColor = kBubbleDetailFontColor;
        self.carNumberLabel.font = kBubbleDetailFont;
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(EZGCarMessage *)message {
    MyCarModel *carModel = [MyCarModel ObjectWithKeyValues:Trim(message.attributes[MParamCarInfo])];
    CGFloat titleHeight = [NSString HeightOfNormalString:Trim(message.text)
                                                maxWidth:kBubbleServiceTextWidth
                                                withFont:kBubbleTitleFont];
    CGFloat carBrandHeight = [NSString HeightOfNormalString:Trim([carModel formatCarModelName])
                                                   maxWidth:kBubbleServiceTextWidth
                                                   withFont:kBubbleDetailFont];
    CGFloat carNumberHeight = [NSString HeightOfNormalString:Trim([carModel formatCarNumber])
                                                   maxWidth:kBubbleServiceTextWidth
                                                   withFont:kBubbleDetailFont];
    CGFloat bubbleHeight = titleHeight + carBrandHeight + carNumberHeight + kXHBubbleMarginVer * 3.5;
    bubbleHeight = MAX(AUTOLAYOUT_LENGTH(160), bubbleHeight);
    return CGSizeMake(kBubbleServiceWidth, bubbleHeight);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGCarMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.carTitleLabel.text = message.text;
    MyCarModel *carModel = [MyCarModel ObjectWithKeyValues:Trim(message.attributes[MParamCarInfo])];
    self.carBrandLabel.text = [carModel formatCarModelName];
    self.carNumberLabel.text = [carModel formatCarNumber];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = [self calculateContentFrame];
    
    //调整标题位置
    [self.carTitleLabel sizeToFit];
    self.carTitleLabel.origin = contentFrame.origin;
    self.carTitleLabel.width = contentFrame.size.width;
    
    //调整分割线位置
    self.separationLineLabel.left = self.carTitleLabel.left;
    self.separationLineLabel.top = self.carTitleLabel.bottom + kXHBubbleMarginVer / 2;
    self.separationLineLabel.width = self.carTitleLabel.width;
    
    //调整车辆信息位置
    [self.carBrandLabel sizeToFit];
    self.carBrandLabel.width = self.carTitleLabel.width;
    self.carBrandLabel.left = self.carTitleLabel.left;
    self.carBrandLabel.top = self.separationLineLabel.bottom + kXHBubbleMarginVer / 2;
    [self.carNumberLabel sizeToFit];
    self.carNumberLabel.width = self.carTitleLabel.width;
    self.carNumberLabel.left = self.carTitleLabel.left;
    self.carNumberLabel.top = self.carBrandLabel.bottom + kXHBubbleMarginVer / 2;
}

@end
