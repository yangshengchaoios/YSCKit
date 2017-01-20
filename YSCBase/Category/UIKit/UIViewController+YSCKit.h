//
//  UIViewController+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//==============================================================================
//
//  基本切换功能
//  @Author: Builder
//
//==============================================================================
@interface UIViewController (YSCKit)
@property (nonatomic, strong) NSMutableDictionary *ysc_params;

- (void)ysc_hideKeyboard;

/** push view controller */
- (void)ysc_pushViewController:(NSString *)className;
- (void)ysc_pushViewController:(NSString *)className withParams:(NSDictionary *)params;
- (void)ysc_pushViewController:(NSString *)className withParams:(NSDictionary *)params animated:(BOOL)animated;

/** pop & dismiss view controller */
- (void)ysc_popViewController;          //返回上一级，最多到根
- (void)ysc_popViewControllerWithStep:(NSInteger)step;  //向后回退的步数
- (void)ysc_backViewController;         //返回上一级，直到dismiss

/** present viewcontroller
 *  [presentingViewController -> self -> presentedViewController] */
- (void)ysc_presentViewController:(NSString *)className;
- (void)ysc_presentViewController:(NSString *)className withParams:(NSDictionary *)params;
- (void)ysc_presentViewController:(NSString *)className withParams:(NSDictionary *)params animated:(BOOL)animated;

/** dismiss viewcontroller */
- (void)ysc_dismissOnPresentingViewController;  //在self上一级viewController调用dismiss（通常情况下使用该方法）
- (void)ysc_dismissOnPresentedViewController;   //在self下一级viewController调用dismiss
@end


//==============================================================================
//
//  实例化viewController
//  @Author: Builder
//
//==============================================================================
@interface UIViewController (YSCKit_CreateNew)
/**
 *  TODO: 未考虑storyboard的情况
 */
+ (instancetype)ysc_createNew;

+ (instancetype)ysc_createNewByName:(NSString *)name;
+ (instancetype)ysc_createNewByName:(NSString *)name params:(NSDictionary *)params;

+ (UINavigationController *)ysc_createNewNavigationByRootName:(NSString *)rootName;
+ (UINavigationController *)ysc_createNewNavigationByRootName:(NSString *)rootName params:(NSDictionary *)params;
@end
