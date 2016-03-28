//
//  YSCTipsView.m
//  YSCKit
//
//  Created by YangShengchao on 15/4/12.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "YSCTipsView.h"
#import "UIControl+BlocksKit.h"
@interface YSCTipsView ()

@end

@implementation YSCTipsView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.actionButton.backgroundColor = [UIColor redColor];//默认按钮背景色
    [self resetConstraintOfView];
    [self resetFontSizeOfView];
    
    [UIView makeRoundForView:self.actionButton withRadius:5];
}

+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView {
    return [self createYSCTipsViewOnView:contentView buttonAction:nil];
}
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                           buttonAction:(YSCBlock)buttonAction {
    return [self createYSCTipsViewOnView:contentView withMessage:nil iconImage:nil buttonTitle:nil buttonAction:buttonAction];
}
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                            withMessage:(NSString *)message
                              iconImage:(UIImage *)image
                            buttonTitle:(NSString *)buttonTitle
                           buttonAction:(YSCBlock)buttonAction {
    return [self createYSCTipsViewOnView:contentView edgeInsets:UIEdgeInsetsZero withMessage:nil iconImage:nil buttonTitle:nil buttonAction:buttonAction];
}
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                             edgeInsets:(UIEdgeInsets)edgeInsets
                            withMessage:(NSString *)message
                              iconImage:(UIImage *)image
                            buttonTitle:(NSString *)buttonTitle
                           buttonAction:(YSCBlock)buttonAction {
    // 0. 设置默认提示信息
    if (nil == contentView) {
        return nil;
    }
    if (OBJECT_IS_EMPTY(TRIM_STRING(message))) {
        message = @"暂无数据";
    }
    if (OBJECT_IS_EMPTY(image)) {
        image = [UIImage imageNamed:@"icon_empty"];
    }
    if (OBJECT_IS_EMPTY(TRIM_STRING(buttonTitle))) {
        buttonTitle = @"重新加载";
    }
    
    // 1. 创建tipsview
    YSCTipsView *tipsView = FIRST_VIEW_IN_XIB(@"YSCTipsView");
    tipsView.iconImageView.image = image;
    tipsView.messageLabel.text = message;
    [tipsView.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
    if (buttonAction) {
        [tipsView.actionButton bk_addEventHandler:^(id sender) {
            buttonAction();
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 2. 设置tipsview的位置和大小
    tipsView.left = edgeInsets.left;
    tipsView.top = edgeInsets.top;
    tipsView.width = contentView.width - edgeInsets.left - edgeInsets.right;
    tipsView.height = contentView.height - edgeInsets.top - edgeInsets.bottom;
    [contentView addSubview:tipsView];
    return tipsView;
}

- (void)resetFrameWithEdgeInsets:(UIEdgeInsets)edgeInsets {
    UIView *contentView = self.superview;
    self.left = edgeInsets.left;
    self.top = edgeInsets.top;
    self.width = contentView.width - edgeInsets.left - edgeInsets.right;
    self.height = contentView.height - edgeInsets.top - edgeInsets.bottom;
}
- (void)resetActionWithButtonTitle:(NSString *)buttonTitle
                      buttonAction:(YSCBlock)buttonAction {
    if (OBJECT_ISNOT_EMPTY(TRIM_STRING(buttonTitle))) {
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
    if (buttonAction) {
        [self.actionButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
        [self.actionButton bk_addEventHandler:^(id sender) {
            buttonAction();
        } forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)resetIconImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (imageName) {
        self.iconImageView.image = image;
    }
}
@end
