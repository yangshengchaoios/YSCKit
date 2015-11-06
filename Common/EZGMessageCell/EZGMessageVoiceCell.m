//
//  EZGMessageVoiceCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageVoiceCell.h"

@implementation EZGMessageVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.animationVoiceImageView.width = AUTOLAYOUT_LENGTH(40);
    self.animationVoiceImageView.height = AUTOLAYOUT_LENGTH(40);
    self.voiceDurationLabel.backgroundColor = [UIColor clearColor];
    self.voiceDurationLabel.font = AUTOLAYOUT_FONT(self.voiceDurationLabel.font.pointSize);
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMAudioMessage *)message {
    float duration = message.duration;
    float gapDuration = (duration == 0 ? -1 : duration - 1.0f);
    return CGSizeMake(90 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), kXHAvatarImageSize);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMAudioMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.voiceDurationLabel.text = [NSString stringWithFormat:@"%.1f", message.duration];
    [self resetVoiceAnimations];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.voiceDurationLabel sizeToFit];
    self.voiceDurationLabel.centerY = self.bubbleImageView.centerY;
    self.animationVoiceImageView.centerY = self.bubbleImageView.centerY;
    if (XHBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.animationVoiceImageView.left = self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginLeft;
        self.voiceDurationLabel.textColor = kDefaultTextColorBlack1;
        self.voiceDurationLabel.right = CGRectGetMaxX(self.bubbleImageView.frame) - kXHBubbleMarginRight;
    }
    else {
        self.animationVoiceImageView.right = CGRectGetMaxX(self.bubbleImageView.frame) - (kXHBubbleMarginRight + kXHBubbleArrowWidth);
        self.voiceDurationLabel.textColor = [UIColor whiteColor];
        self.voiceDurationLabel.left = self.bubbleImageView.left + kXHBubbleMarginLeft;
    }
}

//重置播放的音频动画
- (void)resetVoiceAnimations {
    [self.animationVoiceImageView.layer removeAllAnimations];
    NSString *imageSepatorName;
    if (XHBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        imageSepatorName = @"Receiver";
    }
    else {
        imageSepatorName = @"Sender";
    }
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i ++) {
        UIImage *image = [UIImage imageNamed:[imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld", (long)i]];
        if (image)
            [images addObject:image];
    }
    self.animationVoiceImageView.image = [UIImage imageNamed:[imageSepatorName stringByAppendingString:@"VoiceNodePlaying"]];
    self.animationVoiceImageView.animationImages = images;
    self.animationVoiceImageView.animationDuration = 1.0;
    [self.animationVoiceImageView stopAnimating];
}

@end
