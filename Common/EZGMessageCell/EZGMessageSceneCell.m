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
        self.sceneTextLabel.textColor = kDefaultTextColorBlack1;
        self.sceneTextLabel.font = AUTOLAYOUT_FONT(self.sceneTextLabel.font.pointSize);
        
        self.separationLineLabel.height = AUTOLAYOUT_LENGTH(1);
    }
    return self;
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(EZGSceneMessage *)message {
    return AUTOLAYOUT_SIZE_WH(300 + 14, 210);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(EZGSceneMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.sceneTextLabel.text = message.text;
    
    if (EZGSceneTypeSingleCar == message.sceneType) {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"singlecar"];
    }
    else {
        self.bubbleSceneImageView.image = [UIImage imageNamed:@"multicar"];
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整标题位置
    [self.sceneTextLabel sizeToFit];
    self.sceneTextLabel.width = self.bubbleImageView.width - (kXHBubbleMarginHor + kXHBubbleArrowWidth + kXHBubbleMarginHor);
    self.sceneTextLabel.top = self.bubbleImageView.top + kXHBubbleMarginVer;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.sceneTextLabel.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginHor;
    }
    else {
        self.sceneTextLabel.left = self.bubbleImageView.left + kXHBubbleMarginHor;
    }
    
    //调整分割线位置
    self.separationLineLabel.left = self.sceneTextLabel.left;
    self.separationLineLabel.top = CGRectGetMaxY(self.sceneTextLabel.frame) + kXHBubbleMarginVer;
    self.separationLineLabel.width = self.sceneTextLabel.width;
    
    //调整图片位置
    self.bubbleSceneImageView.top = self.separationLineLabel.bottom + kXHBubbleMarginPhoto;
    self.bubbleSceneImageView.left = self.separationLineLabel.left - kXHBubbleMarginHor + kXHBubbleMarginPhoto;
    self.bubbleSceneImageView.width = self.bubbleImageView.width - (kXHBubbleMarginPhoto + kXHBubbleArrowWidth + kXHBubbleMarginPhoto);
    self.bubbleSceneImageView.height = self.bubbleImageView.bottom - self.separationLineLabel.bottom - 2 * kXHBubbleMarginPhoto;
}

@end
