//
//  ImageUtils.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "YSCImageUtils.h"
#import <UIImage-Resize/UIImage+Resize.h>
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#define TagOfBlurView 19999

@implementation YSCImageUtils

//判断图片是否是透明的
+ (BOOL)hasAlpha:(UIImage *)image {
    ReturnNOWhenObjectIsEmpty(image)
    return [image hasAlpha];
}

//调整图片质量
+ (UIImage *)adjustImage:(UIImage *)image {
    return [self adjustImage:image withQuality:ImageQualityAuto];
}
+ (UIImage *)adjustImage:(UIImage *)image withQuality:(ImageQuality)quality {
    ReturnNilWhenObjectIsEmpty(image)
    
    ImageQuality imageQuality = quality;
    if (imageQuality == ImageQualityLow || imageQuality == ImageQualityNormal) {
        /**
         * 1、先判断宽度是否在区间内。
         * 2、如果宽度小于最小值，使用原图
         * 3、按比例计算需要的宽度。
         * 4、如果需要宽度大于最大值，使用最大值缩放
         * 4、否则，按计算得到的比例来
         */
        CGFloat minWidth = (imageQuality == ImageQualityLow ? 320 : 480);
        CGFloat maxWidth = (imageQuality == ImageQualityLow ? 480 : 720);
        CGFloat originWidth = image.size.width;
        CGFloat originHeight = image.size.height;
        
        if (originWidth < minWidth) {
            return image;
        }
        CGFloat wantedRatio = (imageQuality == ImageQualityLow ? 0.5f : 0.7f);
        CGFloat wantedWidth = originWidth * wantedRatio;
        if (wantedWidth > maxWidth) {
            wantedWidth = maxWidth;
        }
        return [self resizeImage:image toSize:CGSizeMake(wantedWidth, wantedWidth * (originHeight / originWidth))];
    }
    
    return image;
}

//调整图片大小
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    return [self resizeImage:image toSize:size scale:NO];
}
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size scale:(BOOL)scale {
    ReturnNilWhenObjectIsEmpty(image)
    return [image resizedImageToFitInSize:size scaleIfSmaller:scale];
}

//拉伸图片
+ (UIImage *)stretchImage:(UIImage *)image withPoint:(CGPoint)point {
    return [self stretchImage:image withEdgeInset:UIEdgeInsetsMake(point.y, point.x, point.y, point.x)];
}
+ (UIImage *)stretchImage:(UIImage *)image withEdgeInset:(UIEdgeInsets)edgeInset {
    ReturnNilWhenObjectIsEmpty(image)
    return [image resizableImageWithCapInsets:edgeInset resizingMode:UIImageResizingModeStretch];
}

//模糊图片1
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

//模糊图片2 0.0 to 1.0
+ (UIImage*)blurryImage1:(UIImage *)image withBlurLevel:(CGFloat)blurAmount {    
    if (blurAmount < 0.0 || blurAmount > 1.0) {
        blurAmount = 0.5;
    }
    
    int boxSize = (int)(blurAmount * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (!error) {
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        if (!error) {
            error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;


}

//后台模糊效果
+ (void)addBlurEffect {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.tag = TagOfBlurView;
    imageView.image = [YSCImageUtils blurryImage:[KeyWindow screenshotOfView] withBlurLevel:0.1];
    [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
}
//移除后台模糊
+ (void)removeBlurEffect {
    NSArray *subViews = [[UIApplication sharedApplication] keyWindow].subviews;
    for (id object in subViews) {
        if ([[object class] isSubclassOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)object;
            if(TagOfBlurView == imageView.tag) {
                [UIView animateWithDuration:0.2 animations:^{
                    imageView.alpha = 0;
                    [imageView removeFromSuperview];
                }];
                break;
            }
        }
    }
}
@end