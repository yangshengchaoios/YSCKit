//
//  EZGMessageServiceCancelCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageServiceCancelCell.h"

@implementation EZGMessageServiceCancelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cancelTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.separationLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.cancelIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.cancelDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.cancelTitleLabel];
        [self.contentView addSubview:self.separationLineLabel];
        [self.contentView addSubview:self.cancelIconImageView];
        [self.contentView addSubview:self.cancelDetailLabel];
        
        self.cancelTitleLabel.backgroundColor = [UIColor clearColor];
        self.cancelTitleLabel.textColor = kDefaultTextColorRed1;
        self.cancelTitleLabel.font = kBubbleTitleFont;
        self.cancelTitleLabel.numberOfLines = 2;
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        self.separationLineLabel.backgroundColor = kDefaultBorderColor;
        
        self.cancelDetailLabel.backgroundColor = [UIColor clearColor];
        self.cancelDetailLabel.textColor = kBubbleDetailFontColor;
        self.cancelDetailLabel.font = kBubbleDetailFont;
        self.cancelDetailLabel.numberOfLines = 2;
        
        self.cancelIconImageView.size = AUTOLAYOUT_SIZE_WH(100, 70);
        self.cancelIconImageView.image = [UIImage imageNamed:@"icon_cancel_rescue"];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(EZGServiceCancelMessage *)message {
    CGFloat titleHeight = [NSString HeightOfNormalString:Trim(message.text)
                                                maxWidth:kBubbleServiceTextWidth
                                                withFont:kBubbleTitleFont];
    CGFloat contentHeight = titleHeight + kXHBubbleMarginVer * 1 + AUTOLAYOUT_LENGTH(1);
    contentHeight = MAX(AUTOLAYOUT_LENGTH(150), contentHeight);
    return CGSizeMake(kBubbleServiceWidth, contentHeight);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGServiceCancelMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.cancelTitleLabel.text = Trim(message.text);
    self.cancelDetailLabel.text = Trim(message.attributes[MParamDetailInfo]);
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = [self calculateContentFrame];
    
    //调整标题位置
    [self.cancelTitleLabel sizeToFit];
    self.cancelTitleLabel.origin = contentFrame.origin;
    self.cancelTitleLabel.width = contentFrame.size.width;
    
    //调整分割线位置
    self.separationLineLabel.left = self.cancelTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.cancelTitleLabel.frame) + kXHBubbleMarginVer / 2;
    self.separationLineLabel.width = self.cancelTitleLabel.width;
    
    //调整icon位置
    self.cancelIconImageView.left = self.cancelTitleLabel.left;
    self.cancelIconImageView.top = self.separationLineLabel.bottom + kXHBubbleMarginVer / 2;
    
    //调整文字位置
    self.cancelDetailLabel.left = self.cancelIconImageView.right;
    self.cancelDetailLabel.top = self.cancelIconImageView.top;
    self.cancelDetailLabel.height = self.cancelIconImageView.height;
    self.cancelDetailLabel.width = self.separationLineLabel.width - self.cancelIconImageView.width;
}

@end
