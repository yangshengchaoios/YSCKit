//
//  TipsView.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>

typedef void(^TipsTapHandle)(void);

@interface TipsView : UIView

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view;
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
             withEdgeInsets:(UIEdgeInsets)edgeInsets;

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage;
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
             withEdgeInsets:(UIEdgeInsets)edgeInsets;

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
               buttonHandle:(TipsTapHandle)handle;
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
               buttonHandle:(TipsTapHandle)handle
             withEdgeInsets:(UIEdgeInsets)edgeInsets;

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
             withEdgeInsets:(UIEdgeInsets)edgeInsets
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
            buttonTextColor:(UIColor *)textColor
      buttonBackgroundColor:(UIColor *)backgroundColor
               buttonHandle:(TipsTapHandle)handle;

@end
