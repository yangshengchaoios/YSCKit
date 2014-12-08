//
//  TipsView.h
//  KQ
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>

typedef void(^TipsTapHandle)(void);

@interface TipsView : UIView

- (void)setTipsLabelText:(NSString *)tips;

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view;

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
           andPressHandle:(TipsTapHandle)pressHandle;

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
           andButtonTitle:(NSString *)buttonTitle
          andButtonHandle:(TipsTapHandle)handle;

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
     andButtonNormalImage:(UIImage *)normalImage
  andButtonHighLightImage:(UIImage *)highLightImage
           andButtonTitle:(NSString *)buttonTitle
          andButtonHandle:(TipsTapHandle)handle;

@end
