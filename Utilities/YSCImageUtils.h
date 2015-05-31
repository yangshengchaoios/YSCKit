//
//  ImageUtils.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

@interface YSCImageUtils : NSObject

//判断图片是否是透明的
+ (BOOL)hasAlpha:(UIImage *)image;

//调整图片质量
+ (UIImage *)adjustImage:(UIImage *)image;
+ (UIImage *)adjustImage:(UIImage *)image withQuality:(ImageQuality)quality;

//调整图片大小
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size scale:(BOOL)scale;

//拉伸图片
+ (UIImage *)stretchImage:(UIImage *)image withPoint:(CGPoint)point;
+ (UIImage *)stretchImage:(UIImage *)image withEdgeInset:(UIEdgeInsets)edgeInset;

//模糊图片1
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

//模糊图片2 0.0 to 1.0
+ (UIImage*)blurryImage1:(UIImage *)image withBlurLevel:(CGFloat)blurAmount;

//后台模糊效果
+ (void)addBlurEffect;
//移除后台模糊
+ (void)removeBlurEffect;

@end