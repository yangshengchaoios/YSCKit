//
//  ImageUtils.m
//  TGO2
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "ImageUtils.h"
#import <UIImage-Resize/UIImage+Resize.h>

@implementation ImageUtils

+ (UIImage *)ninePathWithImage:(UIImage *)originImage insertTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right {
    UIImage *resizedImage = nil;
    CGFloat sysVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVersion < 6.0) {
        resizedImage = [originImage stretchableImageWithLeftCapWidth:left topCapHeight:top];
    }
    else {
        resizedImage = [originImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    return resizedImage;
}

+ (UIImage *)ninePathWithImage:(UIImage *)originImage insert:(CGFloat)insert {
    return [self ninePathWithImage:originImage insertTop:insert left:insert bottom:insert right:insert];
}

+ (UIImage *)cropCenterSquare:(UIImage *)originImage {
    
    float originalWidth  = originImage.size.width;
    float originalHeight = originImage.size.height;
    if (originalHeight == originalWidth) {
        return originImage;
    }
    
    UIImage *ret = nil;
    float edge = fminf(originalWidth, originalHeight);
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
    
    CGRect cropSquare = CGRectMake(posX, posY, edge, edge);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], cropSquare);
    
    ret = [UIImage imageWithCGImage:imageRef
                              scale:originImage.scale
                        orientation:originImage.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return ret;
}

+ (BOOL)hasAlpha:(UIImage *)image {
    if ( ! image) {
        return NO;
    }
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

+ (UIImage *)adjustImageQualityAutomatically:(UIImage *)originImage {
    return [self adjustImage:originImage toQuality:ImageQualityAuto];
}

+ (UIImage *)adjustImage:(UIImage *)originImage toQuality:(ImageQuality)quality {
    if ( ! originImage) {
        return nil;
    }
    ImageQuality imageQuality = quality;
    if (imageQuality == ImageQualityLow || imageQuality == ImageQualityNormal) {
        UIImage *scaledImage = originImage;
        
        /**
         * 1、先判断宽度是否在区间内。
         * 2、如果宽度小于最小值，使用原图
         * 3、按比例计算需要的宽度。
         * 4、如果需要宽度大于最大值，使用最大值缩放
         * 4、否则，按计算得到的比例来
         */
        CGFloat minWidth = (imageQuality == ImageQualityLow ? 320 : 480);
        CGFloat maxWidth = (imageQuality == ImageQualityLow ? 480 : 720);
        
        CGFloat originWidth = originImage.size.width;
        CGFloat originHeight = originImage.size.height;
        
        if (originWidth < minWidth) {
            return originImage;
        }
        
        CGFloat wantedRatio = (imageQuality == ImageQualityLow ? 0.5f : 0.7f);
        
        CGFloat wantedWidth = originWidth * wantedRatio;
        
        if (wantedWidth > maxWidth) {
            wantedWidth = maxWidth;
        }
                
        scaledImage = [originImage resizedImageToFitInSize:CGSizeMake(wantedWidth, wantedWidth * (originHeight / originWidth)) scaleIfSmaller:NO];
        
        return scaledImage;
    }
    
    return originImage;
}

+ (NSInteger)fitThumbnailWidthForImageBounds:(CGRect)imageViewRect {
    NSInteger screenScale = (NSInteger)[[UIScreen mainScreen] scale];
    
    CGFloat maxImageViewWidth = MAX(imageViewRect.size.width, imageViewRect.size.height);
    NSInteger fitThumbnailWidth;
    if (maxImageViewWidth > 321) {
        return NSIntegerMax;
    }
    else if (maxImageViewWidth > 201) {
        fitThumbnailWidth = 300;
    }
    else if (maxImageViewWidth > 101) {
        fitThumbnailWidth = 200;
    }
    else if (maxImageViewWidth > 51) {
        fitThumbnailWidth = 100;
    }
    else {
        fitThumbnailWidth = 50;
    }
    return fitThumbnailWidth * screenScale;
}

@end


@implementation UIImage (ImageUtils)

- (UIImage *)upOrientation {
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    else {
        return [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:UIImageOrientationUp];
    }
}

@end