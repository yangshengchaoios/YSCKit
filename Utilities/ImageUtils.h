//
//  ImageUtils.h
//  TGO2
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

/*  图片质量
    * 高质量：原图
    * 中等质量：原图大小的70%。最小宽度：480 最大宽度：720
    * 低质量：原图大小的50%。最小宽度：320 最大宽度：480
 */
typedef NS_ENUM(NSUInteger, ImageQuality) {
    ImageQualityLow = 0,        //低质量图片
    ImageQualityNormal = 1,     //中等质量图片
    ImageQualityHigh = 2,       //高质量图片
    ImageQualityAuto = 10       //根据网络自动选择图片质量
};

@interface ImageUtils : NSObject

+ (UIImage *)ninePathWithImage:(UIImage *)originImage insertTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
+ (UIImage *)ninePathWithImage:(UIImage *)originImage insert:(CGFloat)insert;
+ (UIImage *)cropCenterSquare:(UIImage *)originImage;

+ (BOOL)hasAlpha:(UIImage *)image;

/**
 *	根据网络状况自动调整上传图片的质量
 *
 *	@param	originImage	原图
 *
 *	@return	调整后的图片
 */
+ (UIImage *)adjustImageQualityAutomatically:(UIImage *)originImage;

/**
 *	调整上传图片的质量
 *
 *	@param	originImage	原图
 *	@param	quality	调整的质量等级
 *
 *	@return	调整后的图片
 */
+ (UIImage *)adjustImage:(UIImage *)originImage toQuality:(ImageQuality)quality;

+ (NSInteger)fitThumbnailWidthForImageBounds:(CGRect)imageViewRect;

@end


@interface UIImage (ImageUtils)

- (UIImage *)upOrientation;

@end