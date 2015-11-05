//
//  EZGMessageLocationCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageLocationCell.h"

@implementation EZGMessageLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMLocationMessage *)message {
    return [self SizeForPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"]];
}
//显示message
- (void)layoutMessage:(AVIMLocationMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.geolocationsLabel.text = Trim(message.text);
    self.bubblePhotoImageView.messagePhoto = [UIImage imageNamed:@"Fav_Cell_Loc"];
}

@end
