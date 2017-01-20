//
//  YSCModelAdapterManager.m
//  YSCKitDemo
//
//  Created by 杨胜超 on 16/10/20.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCModelAdapterManager.h"

@implementation YSCModelAdapterManager

+ (id<YSCModelAdapterDelegate>)adapter {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        id object = [NSClassFromString(@"YSCMJExtensionAdapter") new];
        if (object && [object conformsToProtocol:@protocol(YSCModelAdapterDelegate)]) {
            if ([object respondsToSelector:@selector(mappingWithClass:keyValues:)] &&
                [object respondsToSelector:@selector(decodingWithObject:coder:)] &&
                [object respondsToSelector:@selector(encodingWithObject:coder:)] &&
                [object respondsToSelector:@selector(jsonStringOfObject:)] &&
                [object respondsToSelector:@selector(descriptionOfObject:)]) {
                return object;
            }
        }
        
        object = nil;
        return object;
    });
}

@end
