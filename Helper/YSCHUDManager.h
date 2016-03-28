//
//  YSCHUDManager.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSCHUDManager : NSObject

// 显示HUD
+ (void)showHUDLoading:(NSString *)hintString onView:(UIView *)view;
+ (void)showHUDLoadingOnKeyWindow:(NSString *)hintString;

// 关闭HUD
+ (void)hideHUDLoadingOnView:(UIView *)view;
+ (void)hideHUDLoadingOnWindow;

// 显示N秒后自动关闭HUD
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view afterDelay:(NSTimeInterval)delay;
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view;
+ (void)showHUDThenHideOnKeyWindow:(NSString *)text;

@end
