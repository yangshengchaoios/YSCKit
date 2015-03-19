//
//  TipsView.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "TipsView.h"

#define MariginOfTipsLabel       10.0f
#define TagOfTipsView            12345

@interface TipsView ()

@property (nonatomic, strong) UIImageView *tipsImageView;
@property (nonatomic, strong) UILabel     *tipsLabel;
@property (nonatomic, strong) UIButton    *tipsButton;

@end

@implementation TipsView

- (id)init {
    self = [super init];
    if (self) {
        self.tipsLabel = [[UILabel alloc] init];
        self.tipsLabel.backgroundColor = [UIColor clearColor];
        self.tipsLabel.textColor = kDefaultEmptyTextColor;
        self.tipsLabel.font = AUTOLAYOUT_FONT(28);
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.tipsLabel.numberOfLines = 0;
        [self addSubview:self.tipsLabel];
        
        
    }
    return self;
}

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view {
    return [self showTipText:tipText onView:view withEdgeInsets:UIEdgeInsetsZero hintImage:nil buttonTitle:nil buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:nil];
}
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
             withEdgeInsets:(UIEdgeInsets)edgeInsets {
    return [self showTipText:tipText onView:view withEdgeInsets:edgeInsets hintImage:nil buttonTitle:nil buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:nil];
}

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage {
    return [self showTipText:tipText onView:view withEdgeInsets:UIEdgeInsetsZero hintImage:hintImage buttonTitle:nil buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:nil];
}
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
             withEdgeInsets:(UIEdgeInsets)edgeInsets {
    return [self showTipText:tipText onView:view withEdgeInsets:edgeInsets hintImage:hintImage buttonTitle:nil buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:nil];
}

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
               buttonHandle:(TipsTapHandle)handle {
    return [self showTipText:tipText onView:view withEdgeInsets:UIEdgeInsetsZero hintImage:hintImage buttonTitle:buttonTitle buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:handle];
}
+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
               buttonHandle:(TipsTapHandle)handle
             withEdgeInsets:(UIEdgeInsets)edgeInsets {
    return [self showTipText:tipText onView:view withEdgeInsets:edgeInsets hintImage:hintImage buttonTitle:buttonTitle buttonTextColor:nil buttonBackgroundColor:nil buttonHandle:handle];
}

+ (instancetype)showTipText:(NSString *)tipText
                     onView:(UIView *)view
             withEdgeInsets:(UIEdgeInsets)edgeInsets
                  hintImage:(UIImage *)hintImage
                buttonTitle:(NSString *)buttonTitle
            buttonTextColor:(UIColor *)textColor
      buttonBackgroundColor:(UIColor *)backgroundColor
               buttonHandle:(TipsTapHandle)handle {
    TipsView *tipsView = nil;
    if ([view viewWithTag:TagOfTipsView]) {
        tipsView = (TipsView *)[view viewWithTag:TagOfTipsView];
    }
    else {
        tipsView = [[TipsView alloc] init];
    }
    tipsView.left = edgeInsets.left;
    tipsView.top = edgeInsets.top;
    tipsView.width = view.width - edgeInsets.left - edgeInsets.right;
    tipsView.height = view.height - edgeInsets.top - edgeInsets.bottom;
    tipsView.tag = TagOfTipsView;
    tipsView.backgroundColor = [UIColor clearColor];
    [view addSubview:tipsView];//这句代码会遮挡view上的其他控件
    //    [view insertSubview:tipsView atIndex:0];//保证tipsView只在view上面一层  TODO:需要测试
    
    //1. 显示提示文本
    if ([NSString isNotEmpty:tipText]) {
        tipsView.tipsLabel.text = tipText;
        tipsView.tipsLabel.width = tipsView.width * 6 / 8;
        [tipsView.tipsLabel sizeToFit];                 //计算出label的大小，目的是为了给image和button位置参照
        tipsView.tipsLabel.centerX = tipsView.centerX;
        tipsView.tipsLabel.centerY = tipsView.centerY - 20;
    }
    
    //2. 显示提示图片
    if (hintImage) {
        //创建imageview
        if (nil == tipsView.tipsImageView) {
            tipsView.tipsImageView = [[UIImageView alloc] initWithImage:hintImage];
            [tipsView addSubview:tipsView.tipsImageView];
        }
        
        //调整位置
        tipsView.tipsImageView.centerX = tipsView.tipsLabel.centerX;
        tipsView.tipsImageView.centerY = tipsView.tipsLabel.centerY - (tipsView.tipsImageView.height + tipsView.tipsLabel.height) / 2.0f - MariginOfTipsLabel;
    }
    
    //3. 显示按钮
    if ([NSString isNotEmpty:buttonTitle]) {
        //创建button
        if (nil == tipsView.tipsButton) {
            tipsView.tipsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 135, 40)];
            tipsView.tipsButton.titleLabel.font = AUTOLAYOUT_FONT(32);
            [tipsView.tipsButton setTitle:buttonTitle forState:UIControlStateNormal];
            [tipsView.tipsButton setTitleColor:((nil == textColor) ? [UIColor whiteColor] : textColor)
                                      forState:UIControlStateNormal];
            [tipsView.tipsButton setBackgroundColor:((nil == backgroundColor) ? RGB(193, 4, 8) : backgroundColor)];
            [UIView makeRoundForView:tipsView.tipsButton withRadius:5];
            [tipsView addSubview:tipsView.tipsButton];
            if (handle) {
                [tipsView.tipsButton bk_addEventHandler:^(id sender) {
                    handle();
                } forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        //调整位置
        tipsView.tipsButton.centerX = tipsView.tipsLabel.centerX;
        tipsView.tipsButton.centerY = tipsView.tipsLabel.centerY + (tipsView.tipsButton.height + tipsView.tipsLabel.height) / 2.0f + MariginOfTipsLabel;
    }
    
    return tipsView;
}

@end
