//
//  EZGMessageTextCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageTextCell.h"

#define kXHTextLineSpacing  3.0
#define kFontOfText         [UIFont systemFontOfSize:16]

@implementation EZGMessageTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.displayTextView.backgroundColor = [UIColor clearColor];
    self.displayTextView.selectable = NO;
    self.displayTextView.lineSpacing = 3.0;
    self.displayTextView.font = kFontOfText;
    self.displayTextView.showsEditingMenuAutomatically = NO;
    self.displayTextView.highlighted = NO;
}
+ (CGFloat)neededWidthForText:(NSString *)text {
    CGSize size;
#if IOS7_OR_LATER
    size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 19)
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName : kFontOfText}
                              context:nil].size;
#else
    size = [text sizeWithFont:kFontOfText constrainedToSize:CGSizeMake(CGFLOAT_MAX, 19) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    return roundf(size.width);
}
//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMTypedMessage *)message {
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.55);
    CGFloat dyWidth = [self neededWidthForText:message.text];
    CGSize textSize = [SETextView frameRectWithAttributtedString:[[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:message.text] constraintSize:CGSizeMake(maxWidth, MAXFLOAT) lineSpacing:kXHTextLineSpacing font:kFontOfText].size;
    return CGSizeMake((dyWidth > textSize.width ? textSize.width : dyWidth) + kBubblePaddingRight * 2 + kXHArrowMarginWidth, textSize.height + kMarginTop * 2);
}
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.displayTextView.attributedText = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:[message text]];
}

@end
