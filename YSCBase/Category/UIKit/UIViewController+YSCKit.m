//
//  UIViewController+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIViewController+YSCKit.h"
#import <objc/runtime.h>

static NSInteger const kTagOfMaskView       = 234688;

//==============================================================================
//
//  基本切换功能
//  @Author: Builder
//
//==============================================================================
@implementation UIViewController (YSCKit)

// 添加params属性
YSC_DYNAMIC_PROPERTY_OBJECT(ysc_params, setPsk_params, RETAIN_NONATOMIC, NSMutableDictionary *)

+ (void)load {
    [super load];
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        SWIZZLING_INSTANCE_METHOD(self.class, @selector(viewDidLoad), @selector(ysc_viewDidLoad))
    });
}

- (void)ysc_hideKeyboard {
    [self.view endEditing:YES];
}

/** push view controller */
- (void)ysc_pushViewController:(NSString *)className {
    [self ysc_pushViewController:className withParams:nil];
}
- (void)ysc_pushViewController:(NSString *)className withParams:(NSDictionary *)params {
    [self ysc_pushViewController:className withParams:params animated:YES];
}
- (void)ysc_pushViewController:(NSString *)className withParams:(NSDictionary *)params animated:(BOOL)animated {
    [self ysc_hideKeyboard];
    RETURN_WHEN_OBJECT_IS_EMPTY(className);
    UIViewController *viewController = [UIViewController ysc_createNewByName:className params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        [self _ysc_showMaskView];
        if ([self isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)self pushViewController:viewController animated:animated];
        }
        else{
            [self.navigationController pushViewController:viewController animated:animated];
        }
    }
    else {
        NSLog(@"view controller [%@] instance failed!", className);
    }
}

/** pop & dismiss view controller */
- (void)ysc_popViewController {
    [self ysc_hideKeyboard];
    if (self.navigationController) {     //如果有navigationBar
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self ysc_dismissOnPresentingViewController];
    }
}
- (void)ysc_popViewControllerWithStep:(NSInteger)step {
    [self ysc_hideKeyboard];
    if (self.navigationController) {
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:MIN([self.navigationController.viewControllers count] - 1, MAX(index - step, 0))];
        [self.navigationController popToViewController:previousViewController animated:YES];
    }
}
- (void)ysc_backViewController {
    [self ysc_hideKeyboard];
    if (self.navigationController) {            //如果有navigationBar
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        if (index > 0) {                        //不是root，就返回上一级
            [self ysc_popViewControllerWithStep:1];
        }
        else {
            [self ysc_dismissOnPresentingViewController];
        }
    }
    else {
        [self ysc_dismissOnPresentingViewController];
    }
}

/** present viewcontroller
 *  [presentingViewController -> self -> presentedViewController] */
- (void)ysc_presentViewController:(NSString *)className {
    [self ysc_presentViewController:className withParams:nil];
}
- (void)ysc_presentViewController:(NSString *)className withParams:(NSDictionary *)params {
    [self ysc_presentViewController:className withParams:params animated:YES];
}
- (void)ysc_presentViewController:(NSString *)className withParams:(NSDictionary *)params animated:(BOOL)animated {
    [self ysc_hideKeyboard];
    RETURN_WHEN_OBJECT_IS_EMPTY(className);
    UINavigationController *navigationController = [UINavigationController ysc_createNewNavigationByRootName:className params:params];
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        [self _ysc_showMaskView];
        [self presentViewController:navigationController animated:animated completion:nil];
    }
    else {
        NSLog(@"view controller [%@] instance failed!", className);
    }
}

/** dismiss viewcontroller */
- (void)ysc_dismissOnPresentingViewController {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)ysc_dismissOnPresentedViewController {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

/** use mask view to prevent creating viewcontroller many times */
- (void)_ysc_showMaskView {
    UIView *maskView = [KEY_WINDOW viewWithTag:kTagOfMaskView];
    if ( ! maskView) {
        maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.tag = kTagOfMaskView;
        maskView.backgroundColor = [UIColor clearColor];
        [KEY_WINDOW addSubview:maskView];
    }
}
- (void)_ysc_hideMaskView {
    UIView *maskView = [KEY_WINDOW viewWithTag:kTagOfMaskView];
    if (maskView) {
        [maskView removeFromSuperview];
        maskView = nil;
    }
}

/** Swizzling Methods
    采用Method Swizzling的方式可以继续回到原来的执行流程，本质是AOP */
- (void)ysc_viewDidLoad {
    [self _ysc_hideMaskView];
    [self ysc_viewDidLoad];
}
@end



//==============================================================================
//
//  实例化viewController
//  @Author: Builder
//
//==============================================================================
@implementation UIViewController (YSCKit_CreateNew)
+ (instancetype)ysc_createNew {
    return [self ysc_createNewByName:NSStringFromClass(self.class)];
}

+ (instancetype)ysc_createNewByName:(NSString *)name {
    return [self ysc_createNewByName:name params:nil];
}
+ (instancetype)ysc_createNewByName:(NSString *)name params:(NSDictionary *)params {
    if ( ! name) {
        return nil;
    }
    UIViewController *viewController = nil;
    if (IS_NIB_EXISTS(name)) {
        viewController = [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
    }
    else {
        viewController = [[NSClassFromString(name) alloc] init];
    }
    // 以下兼容swift
    if ( ! viewController) {
        NSString *bundleName = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
        name = [NSString stringWithFormat:@"%@.%@", bundleName, name];
        viewController = [[NSClassFromString(name) alloc] init];
    }
    viewController.ysc_params = [NSMutableDictionary dictionaryWithDictionary:params];
    return viewController;
}

+ (UINavigationController *)ysc_createNewNavigationByRootName:(NSString *)rootName {
    return [self ysc_createNewNavigationByRootName:rootName params:nil];
}
+ (UINavigationController *)ysc_createNewNavigationByRootName:(NSString *)rootName params:(NSDictionary *)params {
    UIViewController *rootViewController = [self ysc_createNewByName:rootName params:params];
    if (rootViewController) {
        return [[UINavigationController alloc] initWithRootViewController:rootViewController];
    }
    else {
        return nil;
    }
}
@end
