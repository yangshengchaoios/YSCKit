//
//  EZGMessageVideoCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageVideoCell.h"
#import "XHMessageVideoConverPhotoFactory.h"

@implementation EZGMessageVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMVideoMessage *)message {
    return [self SizeForPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:message.file.localPath]];
}
//显示message
- (void)layoutMessage:(AVIMVideoMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    //TODO:下载和发送的缓存文件没有处理好
    WEAKSELF
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片
        self.bubblePhotoImageView.messagePhoto = DefaultImage;
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
            else {//TODO:下载完成后刷新界面
                UIImage *image = [XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:message.file.localPath];
                if (image) {
                    weakSelf.bubblePhotoImageView.messagePhoto = image;
                }
            }
        }];
    }
    else {
        UIImage *image = [XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:message.file.localPath];
        if (image) {
            self.bubblePhotoImageView.messagePhoto = image;
        }
        else {
            self.bubblePhotoImageView.messagePhoto = DefaultImage;
        }
        
    }
}

@end
