//
//  EZGMessageVoiceCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageVoiceCell.h"

@implementation EZGMessageVoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.animationVoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        self.voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        [self.contentView addSubview:self.animationVoiceImageView];
        [self.contentView addSubview:self.voiceDurationLabel];
        
        self.animationVoiceImageView.width = AUTOLAYOUT_LENGTH(40);
        self.animationVoiceImageView.height = AUTOLAYOUT_LENGTH(40);
        self.voiceDurationLabel.backgroundColor = [UIColor clearColor];
        self.voiceDurationLabel.font = AUTOLAYOUT_FONT(26);
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(AVIMAudioMessage *)message {
    float duration = (message.duration == 0 ? message.text.floatValue : message.duration);
    float gapDuration = (duration == 0 ? -1 : duration - 1.0f);
    return CGSizeMake(80 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), kXHAvatarImageSize);
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMAudioMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.voiceDurationLabel.hidden = (message.duration <= 0);
    if (message.duration > 0) {
        self.voiceDurationLabel.text = [NSString stringWithFormat:@"%.1f\"", message.duration];
    }
    [self resetVoiceAnimations];
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentFrame = [self calculateContentFrame];
    [self.voiceDurationLabel sizeToFit];
    self.voiceDurationLabel.centerY = CGRectGetMidY(contentFrame);
    self.animationVoiceImageView.centerY = CGRectGetMidY(contentFrame);
    
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.animationVoiceImageView.left = contentFrame.origin.x;
        self.voiceDurationLabel.textColor = [UIColor blackColor];
        self.voiceDurationLabel.left = CGRectGetMaxX(contentFrame) - self.voiceDurationLabel.width;
    }
    else {
        self.animationVoiceImageView.left = CGRectGetMaxX(contentFrame) - self.animationVoiceImageView.width;
        self.voiceDurationLabel.textColor = [UIColor whiteColor];
        self.voiceDurationLabel.left = contentFrame.origin.x;
    }
}

//重置播放的音频动画
- (void)resetVoiceAnimations {
    [self.animationVoiceImageView.layer removeAllAnimations];
    NSString *imageSepatorName;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        imageSepatorName = @"Receiver";
    }
    else {
        imageSepatorName = @"Sender";
    }
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i ++) {
        UIImage *image = [UIImage imageNamed:[imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%d", i]];
        if (image) {
            [images addObject:image];
        }
    }
    self.animationVoiceImageView.image = [UIImage imageNamed:[imageSepatorName stringByAppendingString:@"VoiceNodePlaying"]];
    self.animationVoiceImageView.animationImages = images;
    self.animationVoiceImageView.animationDuration = 1.0;
    [self.animationVoiceImageView stopAnimating];
}

@end
