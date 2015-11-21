//
//  EZGMessageLocationCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageLocationCell.h"

#define kHeightOfMap                230                 //地图高度
#define kDefaultMapImageName        @"default_image"    //TODO:修改默认地图图片名称

@implementation EZGMessageLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubbleLocationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubbleLocationImageView];
        [self.contentView addSubview:self.addressLabel];
        
        self.addressLabel.backgroundColor = RGBA(0, 0, 0, 0.5);
        self.addressLabel.font = kBubbleDetailFont;
        self.addressLabel.numberOfLines = 2;
        self.addressLabel.textColor = [UIColor whiteColor];
        [self.bubbleLocationImageView makeRoundWithRadius:3];
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(AVIMLocationMessage *)message {
    return CGSizeMake(kBubbleServiceWidth, AUTOLAYOUT_LENGTH(kHeightOfMap));
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMLocationMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    NSInteger mapLevel = [message.attributes[MParamMapLevel] integerValue];
    if (0 == mapLevel) {
        mapLevel = 15;
    }
    NSString *locationUrl = [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage?markers=%f,%f&zoom=%ld&width=%.0f&height=%d", message.longitude, message.latitude, mapLevel, kBubbleServiceWidth / AUTOLAYOUT_SCALE, kHeightOfMap];
    [self.bubbleLocationImageView setImageWithURLString:locationUrl placeholderImageName:kDefaultMapImageName withFadeIn:NO];
    self.addressLabel.text = Trim(message.text);
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整默认位置图片大小和位置
    CGRect contentFrame = [self calculateContentFrame];
    self.bubbleLocationImageView.frame = CGRectInset(contentFrame, -kXHBubbleMarginHor, -kXHBubbleMarginVer);
    
    //调整文字大小和位置
    [self.addressLabel sizeToFit];
    self.addressLabel.width = self.bubbleLocationImageView.width;
    self.addressLabel.height += 5;
    self.addressLabel.left = self.bubbleLocationImageView.left;
    self.addressLabel.top = self.bubbleLocationImageView.bottom - self.addressLabel.height;
}

@end
