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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.sceneTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.separationLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bubbleSceneImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.sceneTextLabel];
        [self.contentView addSubview:self.separationLineLabel];
        [self.contentView addSubview:self.bubbleSceneImageView];
        
        self.sceneTextLabel.backgroundColor = [UIColor clearColor];
        self.sceneTextLabel.textColor = kBubbleTitleFontColor;
        self.sceneTextLabel.font = kBubbleTitleFont;
        self.sceneTextLabel.numberOfLines = 2;
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        self.separationLineLabel.backgroundColor = kDefaultBorderColor;
        
        self.bubbleSceneImageView.size = AUTOLAYOUT_SIZE_WH(280, 145);
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(EZGSceneMessage *)message {
    CGFloat titleHeight = [NSString HeightOfNormalString:Trim(message.text)
                                                maxWidth:kBubbleServiceTextWidth
                                                withFont:kBubbleTitleFont];
    CGFloat bubbleHeight = titleHeight + AUTOLAYOUT_LENGTH(145) + kXHBubbleMarginVer * 1 + AUTOLAYOUT_LENGTH(1);
    return CGSizeMake(kBubbleServiceWidth, bubbleHeight);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGSceneMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.sceneTextLabel.text = message.text;
    
    if (EZGSceneTypeSingleCar == [message.attributes[MParamSceneType] integerValue]) {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"icon_singlecar"];
    }
    else {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"icon_multicar"];
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = [self calculateContentFrame];
    
    //调整标题位置
    [self.sceneTextLabel sizeToFit];
    self.sceneTextLabel.origin = contentFrame.origin;
    self.sceneTextLabel.width = contentFrame.size.width;
    
    //调整分割线位置
    self.separationLineLabel.left = self.sceneTextLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.sceneTextLabel.frame) + kXHBubbleMarginVer / 2;
    self.separationLineLabel.width = self.sceneTextLabel.width;
    
    //调整图片位置
    self.bubbleSceneImageView.top = self.separationLineLabel.bottom + kXHBubbleMarginVer / 2;
    self.bubbleSceneImageView.centerX = self.separationLineLabel.centerX;
}

@end
