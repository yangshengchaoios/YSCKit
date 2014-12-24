//
//  UIImage+Additions.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-28.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

//判断图片是否是透明的
+ (BOOL)hasAlpha:(UIImage *)image;

//调整图片质量
+ (UIImage *)adjustImage:(UIImage *)image;
+ (UIImage *)adjustImage:(UIImage *)image withQuality:(ImageQuality)quality;

//调整图片大小
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size scale:(BOOL)scale;

//拉伸图片(被ImageUtils中的stretch代替了)
+ (UIImage *)stretchImage:(UIImage *)image withEdgeInset:(UIEdgeInsets)edgeInset;
@end
