//
//  EZGMessageServiceCommentCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageServiceCommentCell.h"

#define SeparationOfStar        AUTOLAYOUT_LENGTH(20) //两个星星之间的间隔

@implementation EZGMessageServiceCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.commentTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.separationLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.rateImageViewArray = [NSMutableArray array];
        self.overLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.commentTitleLabel];
        [self.contentView addSubview:self.separationLineLabel];
        [self.contentView addSubview:self.overLabel];
        for (int i = 0; i < 5; i++) {
            UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self.rateImageViewArray addObject:starImageView];
            [self.contentView addSubview:starImageView];
        }
        
        self.commentTitleLabel.backgroundColor = [UIColor clearColor];
        self.commentTitleLabel.textColor = kDefaultTextColorBlack1;
        self.commentTitleLabel.font = AUTOLAYOUT_FONT(self.commentTitleLabel.font.pointSize);
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        
        for (UIImageView *imageView in self.rateImageViewArray) {
            imageView.width = AUTOLAYOUT_LENGTH(50);
            imageView.height = AUTOLAYOUT_LENGTH(50);
        }
        
        self.overLabel.backgroundColor = [UIColor clearColor];
        self.overLabel.textColor = [UIColor whiteColor];
        self.overLabel.font = AUTOLAYOUT_FONT(self.overLabel.font.pointSize);
        self.overLabel.width = AUTOLAYOUT_LENGTH(300);
        self.overLabel.height = AUTOLAYOUT_LENGTH(80);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGServiceCommentMessage *)message {
    CGFloat maxTextWidth = SCREEN_WIDTH - 2 * (kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding) - kXHBubbleArrowWidth;
    return AUTOLAYOUT_SIZE_WH(maxTextWidth, 130);
}
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(EZGServiceCommentMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    CGFloat cellHeight = [super HeightOfCellByMessage:message displaysTimestamp:displayTimestamp];
    return cellHeight + AUTOLAYOUT_LENGTH(80) + kXHLabelPadding;
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGServiceCommentMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.commentTitleLabel.text = message.text;
    for (int i = 0; i < [self.rateImageViewArray count]; i++) {
        UIImageView *imageView = self.rateImageViewArray[i];
        if (i < [message.attributes[MParamRateScore] integerValue]) {
            imageView.image = [UIImage imageNamed:@""];//黄色星星
        }
        else {
            imageView.image = [UIImage imageNamed:@""];//灰色星星
        }
    }
    self.overLabel.text = [NSString stringWithFormat:@"%@\r\n本次服务已结束", [self formatMessageTimeByTimeStamp:message.sendTimestamp]];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.commentTitleLabel sizeToFit];
    self.commentTitleLabel.width = self.bubbleImageView.width - (kXHBubbleMarginHor + kXHBubbleArrowWidth + kXHBubbleMarginHor);
    self.commentTitleLabel.top = self.bubbleImageView.top + kXHBubbleMarginVer;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.commentTitleLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginHor;
    }
    else {
        self.commentTitleLabel.left = self.bubbleImageView.left + kXHBubbleMarginHor;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.commentTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.commentTitleLabel.frame) + kXHBubbleMarginVer;
    self.separationLineLabel.width = self.commentTitleLabel.width;
    
    //调整星星位置
    CGFloat currentStarX = self.commentTitleLabel.left;
    CGFloat starCenterY = self.separationLineLabel.bottom + (self.bubbleImageView.bottom - self.separationLineLabel.bottom) / 2;
    for (UIImageView *imageView in self.rateImageViewArray) {
        imageView.left = currentStarX;
        imageView.centerY = starCenterY;
        currentStarX += imageView.right + SeparationOfStar;
    }
    
    //调整结束信息位置
    self.overLabel.top = self.bubbleImageView.bottom + kXHLabelPadding;
    self.overLabel.centerX = SCREEN_WIDTH / 2;
}


@end
