//
//  UIResponder+Additions.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "UIResponder+Additions.h"

static __weak id currentFirstResponder;

@implementation UIResponder (Additions)

+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

+ (UIViewController *)createBaseViewController:(NSString *)className {
    UIViewController *pushedViewController = nil;
    //检测是否有class文件 同时兼容xib布局的情况
    if (nil == pushedViewController) {
        if (8.0f > IOS_VERSION) {
            NSString *ios7XibName = [NSString stringWithFormat:@"%@_IOS7", className];
            pushedViewController = [[NSClassFromString(className) alloc] initWithNibName:ios7XibName bundle:nil];
        }
        
        if (nil == pushedViewController) {//ios8或者没有单独xib的vc
            pushedViewController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
        }
    }
    NSAssert(pushedViewController, @"class[%@] is not exists in this project!", className);
    pushedViewController.hidesBottomBarWhenPushed = YES;
    NSLog(@"进入页面:%@", className);
    return pushedViewController;
}

@end
