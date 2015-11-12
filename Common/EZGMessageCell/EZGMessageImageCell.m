//
//  EZGMessageImageCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageImageCell.h"

@implementation EZGMessageImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubblePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubblePhotoImageView];
        
        [self.bubblePhotoImageView makeRoundWithRadius:4];
    }
    return self;
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMImageMessage *)message {
    UIImage *image = DefaultImage;
    NSData *data = [message.file getData:nil];
    if (data) {
        image = [UIImage imageWithData:data];
    }
    return [self SizeForPhoto:image];
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMImageMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    
    WEAKSELF
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片
        self.bubblePhotoImageView.image = DefaultImage;
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
            else {//TODO:下载完成后刷新界面
                weakSelf.bubblePhotoImageView.image = [UIImage imageWithData:data];
            }
        }];
    }
    else {
        UIImage *image = DefaultImage;
        NSData *data = [message.file getData:nil];
        if (data) {
            image = [UIImage imageWithData:data];
        }
        self.bubblePhotoImageView.image = image;
    }
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentFrame = [self calculateContentFrame];
    self.bubblePhotoImageView.frame = CGRectInset(contentFrame, -kXHBubbleMarginHor + AUTOLAYOUT_LENGTH(5), -kXHBubbleMarginVer);
    self.bubblePhotoImageView.left -= AUTOLAYOUT_LENGTH(3);//FIXME:标准
}

#pragma mark - Menu Actions
#pragma mark - Menu Actions
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(save:);
}
- (void)save:(id)sender {
    //FIXME:判断是否显示图片
    [self resignFirstResponder];
    [UIView showHUDLoadingOnWindow:@"正在保存"];
    [[ALAssetsLibrary new] saveImage:self.bubblePhotoImageView.image toAlbum:@"EZGoal" completion:^(NSURL *assetURL, NSError *error) {
        [UIView showResultThenHideOnWindow:@"保存成功"];
    } failure:^(NSError *error) {
        [UIView showResultThenHideOnWindow:@"保存失败！"];
    }];//保存至相册
}

@end
