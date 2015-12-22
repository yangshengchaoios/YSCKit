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
//统一创建UIViewController
+ (UIViewController *)createBaseViewController:(NSString *)className {
    UIViewController *pushedViewController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
    NSAssert(pushedViewController, @"class[%@] is not exists in this project!", className);
    pushedViewController.hidesBottomBarWhenPushed = YES;
    NSLog(@"进入页面:%@", className);
    return pushedViewController;
}
//统一创建UINavigationController
+ (UINavigationController *)createNavigationControllerWithRootViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //这里统一设置controller的各种属性
    //之所以把这些设置放在单独的controller中进行，是因为在ios7环境下，MFMessageComposeViewController.navibar的相关设置
    //只会取[UINavigationBar appearance]中设置的，是个bug？
    if (DefaultNaviBarBackImage) {
        [navigationController.navigationBar setBackgroundImage:DefaultNaviBarBackImage forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [navigationController.navigationBar setBarTintColor:kDefaultNaviTintColor];
    }
    //统一设置导航栏是否透明，这会影响self.view的高度(如果透明则view.height=screen.height，否则view.height=screen.height-64)
    if ([navigationController.navigationBar respondsToSelector:@selector(setTranslucent:)]) {
        [navigationController.navigationBar setTranslucent:YES];
    }
    //影响范围：icon颜色、left、right文字颜色
    [navigationController.navigationBar setTintColor:kDefaultNaviBarTintColor];
    //默认样式，带下横线的
    [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    //设置Title字体大小和颜色(如果不设置将按默认显示whiteColor)
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : kDefaultNaviBarTitleColor,
                                                           NSFontAttributeName : kDefaultNaviBarTitleFont}];
    return navigationController;
}
@end
