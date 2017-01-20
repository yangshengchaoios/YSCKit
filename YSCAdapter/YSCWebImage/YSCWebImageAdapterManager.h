//
//  YSCWebImageAdapterManager.h
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

/** WebImageAdapter必须实现的协议 */
@protocol YSCWebImageAdapterDelegate <NSObject>
@required
- (UIImage *)cachedImageForKey:(NSString *)key;
- (void)downloadWebImageWithURL:(NSURL *)url onImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage completed:(void(^)(UIImage *image, NSError *error))completed;
- (void)clearCaches;
@end


/**
 *
 * @brief 统一返回特定解决方案的适配器
 *
 * 扩展建议：
 *      采用category重写本类的方法 + (id<YSCWebImageAdapterDelegate>)adapter，返回一个实现协议
 *      YSCWebImageAdapterDelegate的对象即可
 *
 */
@interface YSCWebImageAdapterManager : NSObject

+ (id<YSCWebImageAdapterDelegate>)adapter;

@end
