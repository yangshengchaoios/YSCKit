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
        self.cancelTitleLabel.textColor = kDefaultTextColorBlack1;
        self.cancelTitleLabel.font = AUTOLAYOUT_FONT(self.cancelTitleLabel.font.pointSize);
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
        
        self.cancelDetailLabel.backgroundColor = [UIColor clearColor];
        self.cancelDetailLabel.textColor = kDefaultTextColorBlack1;
        self.cancelDetailLabel.font = AUTOLAYOUT_FONT(self.cancelDetailLabel.font.pointSize);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGServiceCancelMessage *)message {
    return AUTOLAYOUT_SIZE_WH(300 + 14, 160);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGServiceCancelMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.cancelTitleLabel.text = Trim(message.text);
    self.cancelDetailLabel.text = Trim(message.detailInfo);
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.cancelTitleLabel sizeToFit];
    self.cancelTitleLabel.width = self.bubbleImageView.width - (kXHBubbleMarginHor + kXHBubbleArrowWidth + kXHBubbleMarginHor);
    self.cancelTitleLabel.top = self.bubbleImageView.top + kXHBubbleMarginVer;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.cancelTitleLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginHor;
    }
    else {
        self.cancelTitleLabel.left = self.bubbleImageView.left + kXHBubbleMarginHor;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.cancelTitleLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.cancelTitleLabel.frame) + kXHBubbleMarginVer;
    self.separationLineLabel.width = self.cancelTitleLabel.width;
    
    //调整icon位置
    self.cancelIconImageView.left = self.separationLineLabel.left;
    self.cancelIconImageView.top = self.separationLineLabel.bottom + kXHBubbleMarginVer;
    self.cancelIconImageView.height = self.bubbleImageView.bottom - self.separationLineLabel.bottom - 2 * kXHBubbleMarginVer;
    self.cancelIconImageView.width = self.cancelIconImageView.height;
    
    //调整文字位置
    self.cancelDetailLabel.left = self.cancelIconImageView.right + kXHBubbleMarginVer;
    self.cancelDetailLabel.top = self.cancelIconImageView.top;
    self.cancelDetailLabel.height = self.cancelIconImageView.height;
    self.cancelDetailLabel.width = self.separationLineLabel.right - self.cancelDetailLabel.left;
}

@end
