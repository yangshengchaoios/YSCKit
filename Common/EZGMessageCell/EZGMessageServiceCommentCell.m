//
//  EZGMessageServiceCommentCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageServiceCommentCell.h"

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
        self.commentTitleLabel.textColor = kBubbleTitleFontColor;
        self.commentTitleLabel.font = kBubbleTitleFont;
        self.commentTitleLabel.numberOfLines = 2;
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        self.separationLineLabel.backgroundColor = kDefaultBorderColor;
        
        for (UIImageView *imageView in self.rateImageViewArray) {
            imageView.width = AUTOLAYOUT_LENGTH(50);
            imageView.height = AUTOLAYOUT_LENGTH(50);
        }
        
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

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(EZGServiceCommentMessage *)message {
    CGFloat titleHeight = [NSString HeightOfNormalString:Trim(message.text)
                                                maxWidth:kBubbleServiceTextWidth
                                                withFont:kBubbleTitleFont];
    CGFloat contentHeight = titleHeight + kXHBubbleMarginVer * 3 + AUTOLAYOUT_LENGTH(1);
    contentHeight = MAX(AUTOLAYOUT_LENGTH(140), contentHeight);
    return CGSizeMake(kMaxContentWidth - (kXHBubbleArrowWidth - kXHBubbleTailWidth), contentHeight);
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
            imageView.image = [UIImage imageNamed:@"foregroundStar"];//黄色星星
        }
        else {
            imageView.image = [UIImage imageNamed:@"backgroundStar"];//灰色星星
        }
    }
    self.overLabel.text = [NSString stringWithFormat:@"%@\r\n本次服务已结束", [self formatMessageTimeByTimeStamp:message.sendTimestamp]];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = [self calculateContentFrame];
    
    //调整标题位置
    [self.commentTitleLabel sizeToFit];
    self.commentTitleLabel.origin = contentFrame.origin;
    self.commentTitleLabel.width = contentFrame.size.width;
    
    //调整分割线位置
    self.separationLineLabel.left = self.commentTitleLabel.left;
    self.separationLineLabel.top = self.commentTitleLabel.bottom + kXHBubbleMarginVer / 2;
    self.separationLineLabel.width = self.commentTitleLabel.width;
    
    //调整星星位置
    CGFloat starX = self.commentTitleLabel.left;
    CGFloat starY = self.separationLineLabel.bottom + kXHBubbleMarginVer / 2;
    CGFloat separater = (self.separationLineLabel.width - [self.rateImageViewArray count] * AUTOLAYOUT_LENGTH(50)) / 4.0f;
    for (UIImageView *imageView in self.rateImageViewArray) {
        imageView.left = starX;
        imageView.top = starY;
        starX = CGRectGetMaxX(imageView.frame) + separater;
    }
    
    //调整结束信息位置
    self.overLabel.top = self.bubbleImageView.bottom + kXHLabelPadding;
    self.overLabel.centerX = SCREEN_WIDTH / 2;
}


@end
