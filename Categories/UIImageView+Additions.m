//
//  UIImageView+Additions.m
//  YSCKit
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
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName {
    [self setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:placeholderImageName] withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:placeholderImageName] withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString withFadeIn:(BOOL)fadeIn {
    [self setImageWithURLString:urlString placeholderImage:DefaultPlaceholderImage withFadeIn:fadeIn completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage {
    [self setImageWithURLString:urlString placeholderImage:holderImage withFadeIn:NO completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage completed:(SetImageCompletionBlock)complete {
    [self setImageWithURLString:urlString placeholderImage:holderImage withFadeIn:NO completed:complete];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage withFadeIn:(BOOL)fadeIn {
    [self setImageWithURLString:urlString placeholderImage:holderImage withFadeIn:fadeIn completed:nil];
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
                   withFadeIn:(BOOL)withAnimate
                    completed:(SetImageCompletionBlock)complete {
    WeakSelfType blockSelf = self;
    //设置基本参数
    if (placeholderImage == nil) {
        self.image = DefaultPlaceholderImage;
    }
    else {
        self.image = placeholderImage;
    }
    self.contentMode = UIViewContentModeCenter;
    self.clipsToBounds = YES;
    self.backgroundColor = kDefaultImageBackColor;
    NSString *newUrlString = [NSString trimString:[urlString copy]];
    
    //判断是否本地图片
    if([NSString isNotEmpty:newUrlString]) {
        if ( ! [NSString isContains:@"/" inString:newUrlString]) {//简单判断是不是本地图片
            UIImage *localImage = [UIImage imageNamed:newUrlString];
            if([NSObject isNotEmpty:localImage]) {
                self.contentMode = UIViewContentModeScaleAspectFill;
                self.image = localImage;
                return;
            }
        }
    }
    else {
        return;
    }
    
    //处理相对路径
    if ([NSString isNotUrl:newUrlString]) {
        newUrlString = [[NSString replaceString:kResPathAppResUrl byRegex:@"/+$" to:@""] stringByAppendingFormat:@"/%@",
                        [NSString replaceString:newUrlString byRegex:@"^/+" to:@""]];
    }
    //处理相对路径后仍然不是合法的url，则返回默认图片
    if ([NSString isNotUrl:newUrlString]) {
        return;
    }
    
    //采用SDWebImage的缓存方案
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableDownloadImage"]) {//下载网络图片
        [self sd_setImageWithURL:[NSURL URLWithString:newUrlString]
                placeholderImage:placeholderImage
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)  {
                           if ( ! error) {
                               blockSelf.contentMode = UIViewContentModeScaleAspectFill;
                               blockSelf.image = image;
                               blockSelf.backgroundColor = [UIColor clearColor];
                               
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
    else {//读取缓存图片
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[NSURL URLWithString:newUrlString] absoluteString]];//先从内存中查找
        if (image) {
            self.backgroundColor = [UIColor clearColor];
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.image = image;
        }
        else {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[NSURL URLWithString:newUrlString] absoluteString]];//再从硬盘中查找
            if (image) {
                self.backgroundColor = [UIColor clearColor];
                self.contentMode = UIViewContentModeScaleAspectFill;
                self.image = image;
            }
        }
    }
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
