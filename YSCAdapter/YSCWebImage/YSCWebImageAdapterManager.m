//
//  YSCWebImageAdapterManager.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCWebImageAdapterManager.h"

@implementation YSCWebImageAdapterManager

+ (id<YSCWebImageAdapterDelegate>)adapter {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        id object = [NSClassFromString(@"YSCSDWebImageAdapter") new];
        if (object && [object conformsToProtocol:@protocol(YSCWebImageAdapterDelegate)]) {
            if ([object respondsToSelector:@selector(cachedImageForKey:)] &&
                [object respondsToSelector:@selector(downloadWebImageWithURL:onImageView:placeholderImage:completed:)] &&
                [object respondsToSelector:@selector(clearCaches)]) {
                return object;
            }
        }
        
        object = nil;
        return object;
    });
}

@end
