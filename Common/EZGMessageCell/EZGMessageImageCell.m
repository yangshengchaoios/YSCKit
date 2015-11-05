//
//  EZGMessageImageCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageImageCell.h"

@implementation EZGMessageImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMImageMessage *)message {
    UIImage *image = DefaultImage;
    NSData *data = [message.file getData:nil];
    if (data) {
        image = [UIImage imageWithData:data];
    }
    return [self SizeForPhoto:image];
}
//显示message
- (void)layoutMessage:(AVIMImageMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    
    WEAKSELF
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片
        self.bubblePhotoImageView.messagePhoto = DefaultImage;
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
            else {//TODO:下载完成后刷新界面
                weakSelf.bubblePhotoImageView.messagePhoto = [UIImage imageWithData:data];
            }
        }];
    }
    else {
        UIImage *image = DefaultImage;
        NSData *data = [message.file getData:nil];
        if (data) {
            image = [UIImage imageWithData:data];
        }
        self.bubblePhotoImageView.messagePhoto = image;
    }
}

@end
