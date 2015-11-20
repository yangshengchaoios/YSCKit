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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.displayTextView];
        
        self.displayTextView.backgroundColor = [UIColor clearColor];
        self.displayTextView.selectable = NO;
        self.displayTextView.lineSpacing = kXHTextLineSpacing;
        self.displayTextView.font = kBubbleTextFont;
        self.displayTextView.showsEditingMenuAutomatically = NO;
        self.displayTextView.highlighted = NO;
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(AVIMTextMessage *)message {
    NSString *msgText = [CDEmotionUtils emojiStringFromString:message.text];//将原始字符串转换为带emoji的字符串
    CGFloat msgTextWidth = [NSString WidthOfNormalString:msgText maxHeight:MAXFLOAT withFont:kBubbleTextFont];
    msgTextWidth = MAX(AUTOLAYOUT_LENGTH(60), msgTextWidth);
    NSAttributedString *attrStr = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
    CGSize textSize = [SETextView frameRectWithAttributtedString:attrStr
                                                  constraintSize:CGSizeMake(kMaxContentWidth - 2 * kXHBubbleMarginHor, MAXFLOAT)
                                                     lineSpacing:kXHTextLineSpacing
                                                            font:kXHFontOfText].size;
    CGFloat bubbleWidth = MIN(msgTextWidth, textSize.width) + kXHBubbleMarginHor * 2;
    CGFloat bubbleHeight = MAX(kXHAvatarImageSize, textSize.height + kXHBubbleMarginVer * 2);
    return CGSizeMake(bubbleWidth, bubbleHeight);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTextMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    NSString *msgText = [CDEmotionUtils emojiStringFromString:message.text];//将原始字符串转换为带emoji的字符串
    self.displayTextView.attributedText = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayTextView.frame = [self calculateContentFrame];
    
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.displayTextView.textColor = [UIColor blackColor];
    }
    else {
        self.displayTextView.textColor = [UIColor whiteColor];
    }
}

#pragma mark - Menu Actions
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copyed:);
}
- (void)copyed:(id)sender {
    [[UIPasteboard generalPasteboard] setString:Trim(self.displayTextView.text)];
    [self resignFirstResponder];
}

@end
