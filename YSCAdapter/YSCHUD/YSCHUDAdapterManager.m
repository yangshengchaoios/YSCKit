//
//  YSCHUDAdapterManager.m
//  YSCKit
//
//  Created by Builder on 16/7/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCHUDAdapterManager.h"

@implementation YSCHUDAdapterManager

+ (id<YSCHUDAdapterDelegate>)adapter {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        id object = [NSClassFromString(@"YSCMBProgressHUDAdapter") new];
        if (object && [object conformsToProtocol:@protocol(YSCHUDAdapterDelegate)]) {
            if ([object respondsToSelector:@selector(showHUDOnView:message:edgeInsets:backgroundColor:)] &&
                [object respondsToSelector:@selector(hideHUDOnView:)] &&
                [object respondsToSelector:@selector(showHUDThenHideOnView:message:afterDelay:)] &&
                [object respondsToSelector:@selector(showHUDOnView:imageName:message:afterDelay:)]) {
                return object;
            }
        }
        
        object = nil;
        return object;
    });
}

@end
