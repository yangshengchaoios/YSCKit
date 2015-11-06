//
//  EZGMessageTextCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageTextCell.h"
#import "CDEmotionUtils.h"

#define kXHTextLineSpacing  AUTOLAYOUT_LENGTH(5)
#define kXHFontOfText       [UIFont systemFontOfSize:16]

@implementation EZGMessageTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.displayTextView.backgroundColor = [UIColor clearColor];
    self.displayTextView.selectable = NO;
    self.displayTextView.lineSpacing = kXHTextLineSpacing;
    self.displayTextView.font = kXHFontOfText;
    self.displayTextView.showsEditingMenuAutomatically = NO;
    self.displayTextView.highlighted = NO;
}
+ (CGFloat)neededWidthForText:(NSString *)text {
    CGSize size;
#if IOS7_OR_LATER
    size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 19)
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName : kXHFontOfText}
                              context:nil].size;
#else
    size = [text sizeWithFont:kFontOfText constrainedToSize:CGSizeMake(CGFLOAT_MAX, 19) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    return roundf(size.width);
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMTypedMessage *)message {
    NSString *msgText = [CDEmotionUtils emojiStringFromString:message.text];//将原始字符串转换为带emoji的字符串
    CGFloat maxTextWidth = SCREEN_WIDTH - 2 * (kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding) - kXHBubbleArrowWidth;
    CGFloat dyWidth = [self neededWidthForText:msgText];
    NSAttributedString *attrStr = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
    CGSize textSize = [SETextView frameRectWithAttributtedString:attrStr
                                                  constraintSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                                     lineSpacing:kXHTextLineSpacing
                                                            font:kXHFontOfText].size;
    CGFloat bubbleWidth = MIN(dyWidth, textSize.width) + kXHBubbleMarginLeft + kXHBubbleMarginRight + kXHBubbleArrowWidth;//NOTE:注意箭头宽度
    CGFloat bubbleHeight = MAX(kXHAvatarImageSize, textSize.height + kXHBubbleMarginTop + kXHBubbleMarginBottom);
    return CGSizeMake(bubbleWidth, bubbleHeight);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    NSString *msgText = [CDEmotionUtils emojiStringFromString:message.text];//将原始字符串转换为带emoji的字符串
    self.displayTextView.attributedText = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *msgText = [CDEmotionUtils emojiStringFromString:self.typedMessage.text];//将原始字符串转换为带emoji的字符串
    CGFloat maxTextWidth = SCREEN_WIDTH - 2 * (kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding) - kXHBubbleArrowWidth;
    CGFloat dyWidth = [self.class neededWidthForText:msgText];
    NSAttributedString *attrStr = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
    CGSize textSize = [SETextView frameRectWithAttributtedString:attrStr
                                                  constraintSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                                     lineSpacing:kXHTextLineSpacing
                                                            font:kXHFontOfText].size;
    self.displayTextView.width = MIN(dyWidth, textSize.width);
    self.displayTextView.height = textSize.height;
    self.displayTextView.top = self.bubbleImageView.top + kXHBubbleMarginTop;
    if (XHBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.displayTextView.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginLeft;
        self.displayTextView.textColor = kDefaultTextColorBlack1;
    }
    else {
        self.displayTextView.left = self.bubbleImageView.left + kXHBubbleMarginLeft;
        self.displayTextView.textColor = [UIColor whiteColor];
    }
}

@end
