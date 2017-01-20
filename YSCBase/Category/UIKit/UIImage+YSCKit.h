//
//  UIImage+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface UIImage (YSCKit)
/**
 *  创建一张图片
 *  added by yw
 */
+ (UIImage *)ysc_createImageWithColor:(UIColor *)color size:(CGSize)size;
/**
 *  Tint: Color + Rect + level
 *  added by yw
 */
- (UIImage*)ysc_tintedImageWithColor:(UIColor*)color rect:(CGRect)rect level:(CGFloat)level;
/**
 *  添加maskcolor
 *  added by dwk
 */
- (UIImage *)ysc_imageMaskedWithColor:(UIColor *)maskColor;
// 旋转
- (UIImage*)ysc_imageRotatedByDegrees:(CGFloat)degrees;

// 调整大小
- (UIImage*)ysc_resizedImageToSize:(CGSize)dstSize;
- (UIImage*)ysc_resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;

// 截取部分图像
- (UIImage*)ysc_getSubImage:(CGRect)rect;
// 等比例缩放 注意：此方法会导致UIImageView的contentMode不起作用
- (UIImage*)ysc_scaleToSize:(CGSize)size;

// 拉伸图片
- (UIImage *)ysc_stretchImageWithPoint:(CGPoint)point;
- (UIImage *)ysc_stretchImageWithEdgeInset:(UIEdgeInsets)edgeInset;

// 模糊图片 (0.0-1.0)
- (UIImage *)ysc_blurryImageWithBlurLevel:(CGFloat)blur;
- (UIImage *)ysc_blurryImage1WithBlurLevel:(CGFloat)blur;

// APP进入后台时添加模糊效果
+ (void)ysc_addScreenBlurEffect;
// APP从后台恢复运行时移除模糊效果
+ (void)ysc_removeScreenBlurEffect;
@end


//==============================================================================
//
//  生成二维码图片
//  added by dwk
//
//==============================================================================
@interface UIImage (YSCKit_QRCode)
/**
 *  生成二维码图片
 *
 *  @param string 二维码字符串
 *  @param size   二维码图片尺寸
 *
 *  @return 二维码图像
 */
+ (UIImage *)ysc_createQRCodeImageWithString:(NSString *)string size:(CGSize)size;
/**
 *  添加子图像
 *
 *  @param image 子图像
 *  @param size  子图像尺寸
 *
 *  @return 合成后的图像
 */
- (UIImage *)ysc_addSubImage:(UIImage *)image size:(CGSize)size;
@end

