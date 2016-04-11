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
    self.backgroundColor = kDefaultViewColor;
    self.actionButton.backgroundColor = [UIColor redColor];//默认按钮背景色
    [self resetSize];
    [self.actionButton addCornerWithRadius:AUTOLAYOUT_LENGTH(5)];
}

#pragma mark - create
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
    [tipsView.actionButton addTouchUpInsideEventBlock:^(id sender) {
        if (buttonAction) {
            buttonAction();
        }
    }];
    
    // 2. 设置tipsview的位置和大小
    [contentView addSubview:tipsView];
    [tipsView resetFrameWithEdgeInsets:edgeInsets];
    return tipsView;
}

#pragma mark - reset
- (void)resetFrameWithEdgeInsets:(UIEdgeInsets)edgeInsets {
    if (self.superview) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(edgeInsets);
        }];
    }
}
- (void)resetActionWithButtonTitle:(NSString *)buttonTitle
                      buttonAction:(YSCBlock)buttonAction {
    self.actionButton.hidden = NO;
    [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.actionButton reAddTouchUpInsideEventBlock:^(id sender) {
        if (buttonAction) {
            buttonAction();
        }
    }];
}
- (void)resetIconImage:(NSString *)imageName {
    self.iconImageView.image = [UIImage imageNamed:imageName];
}
@end
