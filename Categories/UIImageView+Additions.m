//
//  UIImageView+Additions.m
//  KQ
//
//  Created by  YangShengchao on 14-7-28.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "UIImageView+Additions.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define DefaultBackgroundColor          [UIColor colorWithWhite:0.97f alpha:1.0f]       //UIImageView默认背景颜色
#define DefaultPlaceholderImageName     @"default_image"
#define DefaultPlaceholderImage         [UIImage imageNamed:DefaultPlaceholderImageName]       //本项目的默认图片


@implementation UIImageView (Additions)

@end


/**
 *  网络图片缓存处理
 */
@implementation UIImageView (Cache)

- (void)setImageWithURLString:(NSString *)urlString {
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage autoThumbnail:NO withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage autoThumbnail:NO withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName {
    [self setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:placeholderImageName] autoThumbnail:NO withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:placeholderImageName] autoThumbnail:NO withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString withFadeIn:(BOOL)fadeIn {
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage autoThumbnail:NO withFadeIn:fadeIn completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage {
    [self setImageWithURLString:urlString placeholderImage:holderImage autoThumbnail:NO withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:holderImage autoThumbnail:NO withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage withFadeIn:(BOOL)fadeIn {
    [self setImageWithURLString:urlString placeholderImage:holderImage autoThumbnail:NO withFadeIn:fadeIn completed:nil];
}

/**
 *
 *
 *  @param urlString            网络图片完整url地址
 *  @param placeholderImage     用于默认替代的图片对象
 *  @param thumbnail            是否采用缩略图
 *  @param withAnimate          是否动画显示
 */
- (void)setImageWithURLString:(NSString *)urlString
             placeholderImage:(UIImage *)placeholderImage
                autoThumbnail:(BOOL)thumbnail
                   withFadeIn:(BOOL)withAnimate
                    completed:(SetImageCompletionBlock)complete {
    //设置基本参数
    self.image = nil;
    self.clipsToBounds = YES;
    self.backgroundColor = DefaultBackgroundColor;
    NSString *newUrlString = [urlString copy];
    
    //处理相对路径
    if ([NSString isNotUrl:urlString]) {
        newUrlString = [kResPathAppResUrl stringByAppendingFormat:@"%@%@",
                        ([kResPathAppResUrl hasSuffix:@"/"] ? @"" : @"/"),//确保kResPathAppResUrl后面有1个字符'/'
                        ([urlString hasPrefix:@"/"] ? [urlString substringFromIndex:1] : urlString)];//确保urlString前面没有字符'/'
    }
    
    if ([NSString isNotUrl:newUrlString]) {//处理相对路径后仍然不是合法的url，则返回默认图片
        self.image = DefaultPlaceholderImage;
        return;
    }
    
    NSURL *imageUrl = [NSURL URLWithString:newUrlString];
    if ([NSObject isEmpty:placeholderImage]) {
        placeholderImage = DefaultPlaceholderImage;
    }
    WeakSelfType blockSelf = self;
    
    //采用SDWebImage的缓存方案
    [self sd_setImageWithURL:imageUrl
            placeholderImage:placeholderImage
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)  {
                       if ( ! error) {
                           blockSelf.contentMode = UIViewContentModeScaleAspectFill;
                           blockSelf.image = image;
                           blockSelf.backgroundColor = [UIColor clearColor];
                           
                           if (thumbnail) {
                               //TODO:处理缩略图
                           }
                           
                           if (withAnimate) {
                               blockSelf.alpha = 0.1f;
                               [UIView animateWithDuration:0.5f
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^{
                                                    blockSelf.alpha = 1.0f;
                                                }
                                                completion:^(BOOL finished) {
                                                    
                                                }];
                           }
                       }
                       //设置回调
                       if (complete) {
                           complete(image, error);
                       }
                   }];
}

@end



@implementation UIImage (Scale)

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//等比例缩放 //注意：此方法会导致UIImageView的contentMode不起作用
-(UIImage*)scaleToSize:(CGSize)size {
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1) {
        radio = MIN(verticalRadio, horizontalRadio);
    }
    else {
        radio = MAX(verticalRadio, horizontalRadio);
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
