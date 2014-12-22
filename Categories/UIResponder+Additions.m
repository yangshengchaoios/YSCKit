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
        //针对ios7或iphone5以下的情况需要单独的xib布局文件，因为用autolayout会很卡
        if (IOS_VERSION < 8.0 || [UIDevice currentDeviceType] < DeviceTypeiPhone640x1136) {
            NSString *ios7XibName = [NSString stringWithFormat:@"%@_IOS7", className];
            if([[NSBundle mainBundle] pathForResource:ios7XibName ofType:@"nib"] != nil) {
                pushedViewController = [[NSClassFromString(className) alloc] initWithNibName:ios7XibName bundle:nil];
            }
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
