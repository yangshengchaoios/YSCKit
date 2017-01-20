//
//  YSCNetworkingAdapterManager.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCNetworkingAdapterManager.h"

@implementation YSCNetworkingAdapterManager

+ (id<YSCNetworkingAdapterDelegate>)adapter {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        id object = [NSClassFromString(@"YSCAFNetworkingAdapter") new];
        if (object && [object conformsToProtocol:@protocol(YSCNetworkingAdapterDelegate)]) {
            if ([object respondsToSelector:@selector(dataTaskWithUrl:normalParams:httpHeaderParams:imageData:requestType:completionHandler:)]) {
                return object;
            }
        }
        
        object = nil;
        return object;
    });
}

@end
