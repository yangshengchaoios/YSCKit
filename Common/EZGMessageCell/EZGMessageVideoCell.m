//
//  EZGMessageVideoCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageVideoCell.h"

@implementation EZGMessageVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubbleVideoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.videoPlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubbleVideoImageView];
        [self.contentView addSubview:self.videoPlayImageView];
        
        [self.bubbleImageView addSubview:self.bubbleVideoImageView];
        self.videoPlayImageView.size = AUTOLAYOUT_SIZE(self.videoPlayImageView.frame.size);
    }
    return self;
}

//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMVideoMessage *)message {
    return [self SizeForPhoto:[self videoConverPhotoWithVideoPath:message.file.localPath]];
}
//显示message
- (void)layoutMessage:(AVIMVideoMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    //TODO:下载和发送的缓存文件没有处理好
    WEAKSELF
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片
        self.bubbleVideoImageView.image = DefaultImage;
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
            else {
                UIImage *image = [self.class videoConverPhotoWithVideoPath:message.file.localPath];
                if (image) {
                    weakSelf.bubbleVideoImageView.image = image;
                }
            }
        }];
    }
    else {
        UIImage *image = [self.class videoConverPhotoWithVideoPath:message.file.localPath];
        if (image) {
            self.bubbleVideoImageView.image = image;
        }
        else {
            self.bubbleVideoImageView.image = DefaultImage;
        }
    }
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整默认位置图片大小和位置
    self.bubbleVideoImageView.centerY = self.bubbleImageView.centerY;
    self.bubbleVideoImageView.height = self.bubbleImageView.height - 2.0;
    self.bubbleVideoImageView.width = self.bubbleImageView.width - kXHBubbleArrowWidth - 2;
    
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleVideoImageView.left = self.bubbleImageView.left - kXHBubbleArrowWidth - 1;
    }
    else {
        self.bubbleVideoImageView.right = self.bubbleImageView.right - kXHBubbleArrowWidth - 1;
    }
    
    //调整播放按钮的位置
    self.videoPlayImageView.center = self.bubbleVideoImageView.center;
}


//获取视频封面图片
+ (UIImage *)videoConverPhotoWithVideoPath:(NSString *)videoPath {
    if (!videoPath)
        return nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 0;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    CGImageRelease(thumbnailImageRef);
    
    return thumbnailImage;
}

@end
