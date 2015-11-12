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
        self.displayTextView.font = kXHFontOfText;
        self.displayTextView.showsEditingMenuAutomatically = NO;
        self.displayTextView.highlighted = NO;
    }
    return self;
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
    CGFloat maxTextWidth = SCREEN_WIDTH - 2 * (kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding + kXHBubbleMarginHor) - kXHBubbleArrowWidth - kXHBubbleTailWidth;
    CGFloat dyWidth = MAX(AUTOLAYOUT_LENGTH(60), [self neededWidthForText:msgText]);
    NSAttributedString *attrStr = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:msgText];
    CGSize textSize = [SETextView frameRectWithAttributtedString:attrStr
                                                  constraintSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                                     lineSpacing:kXHTextLineSpacing
                                                            font:kXHFontOfText].size;
    CGFloat bubbleWidth = MIN(dyWidth, textSize.width) + kXHBubbleMarginHor * 2 + kXHBubbleArrowWidth + kXHBubbleTailWidth;
    CGFloat bubbleHeight = MAX(kXHAvatarImageSize, textSize.height + kXHBubbleMarginVer * 2) + kXHBubbleMarginVerOffset * 2;
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
