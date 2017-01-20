//
//  UIImageView+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//==============================================================================
//
//  显示网络图片
//  @Author: Builder
//
//==============================================================================
@interface UIImageView (YSCKit)
- (void)ysc_setImageWithURLString:(NSString *)urlString;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                        completed:(void(^)(UIImage *image, NSError *error))complete;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                        animation:(BOOL)animation;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                        animation:(BOOL)animation
                        completed:(void(^)(UIImage *image, NSError *error))complete;

- (void)ysc_setImageWithURLString:(NSString *)urlString
                 placeholderImage:(UIImage *)holderImage;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                 placeholderImage:(UIImage *)holderImage
                        completed:(void(^)(UIImage *image, NSError *error))complete;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                 placeholderImage:(UIImage *)holderImage
                        animation:(BOOL)animation;
- (void)ysc_setImageWithURLString:(NSString *)urlString
                 placeholderImage:(UIImage *)holderImage
                        animation:(BOOL)animation
                        completed:(void(^)(UIImage *image, NSError *error))complete;
@end
