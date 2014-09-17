//
//  ImageUtils.m
//  TGO2
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "ImageUtils.h"
#import <UIImage-Resize/UIImage+Resize.h>
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"

@implementation ImageUtils

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

@end