//
//  EZGMessageImageCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageImageCell.h"

#define kDefaultMessageImage        [UIImage imageNamed:@"default_image"]//TODO:替换默认图片

@implementation EZGMessageImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubblePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubblePhotoImageView];
        
        [self.bubblePhotoImageView makeRoundWithRadius:3];
    }
    return self;
}

#pragma mark - 计算大小
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(AVIMImageMessage *)message {
    UIImage *image = kDefaultMessageImage;
    if (message.file.isDataAvailable) {
        NSData *data = [message.file getData:nil];
        if (data) {
            message.text = @"1";
            image = [UIImage imageWithData:data];
        }
        else {
            message.text = @"0";//NOTE:需要做好标记，等下次成功获取后重新计算高度
        }
    }
    else {
        message.text = @"0";//NOTE:需要做好标记，等下载完成后重新计算高度
    }
    return [self SizeForPhoto:image];
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMImageMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    
    WEAKSELF
    if (message.file.isDataAvailable) {
        UIImage *image = kDefaultMessageImage;
        NSData *data = [message.file getData:nil];
        if (data) {
            image = [UIImage imageWithData:data];
            //NOTE:这里要刷新cell，重新计算cell高度
            if ([@"0" isEqualToString:Trim(message.text)]) {
                if (self.block) {
                    self.block();
                }
            }
            message.text = @"1";//关闭重新刷新cell的开关
        }
        self.bubblePhotoImageView.image = image;
    }
    else {
        //异步下载图片
        self.bubblePhotoImageView.image = kDefaultMessageImage;
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                message.text = @"1";//关闭重新刷新cell的开关
                weakSelf.bubblePhotoImageView.image = [UIImage imageWithData:data];
                if (weakSelf.block) {//NOTE:下载完成后刷新cell，重新计算cell高度
                    weakSelf.block();
                }
            }
        }];
    }
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentFrame = [self calculateContentFrame];
    self.bubblePhotoImageView.frame = CGRectInset(contentFrame, -kXHBubbleMarginHor, -kXHBubbleMarginVer);
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
