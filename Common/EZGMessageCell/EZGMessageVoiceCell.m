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
}

//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMAudioMessage *)message {
    float duration = message.duration;
    float gapDuration = (duration == 0 ? -1 : duration - 1.0f);
    CGSize voiceSize = CGSizeMake(90 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), 30);
    return voiceSize;
}
//显示message
- (void)layoutMessage:(AVIMAudioMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    
}

@end
