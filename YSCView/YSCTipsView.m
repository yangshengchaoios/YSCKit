//
//  YSCTipsView.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCTipsView.h"

@interface YSCTipsView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end

@implementation YSCTipsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupDefaultValues];
        [self _setupCustomValues];
    }
    return self;
}
- (void)_setupDefaultValues {
    self.backgroundColor = YSCConfigManagerInstance.defaultViewColor;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.ysc_width, 200)];
    self.containerView.center = CGPointMake(self.ysc_width / 2, self.ysc_height / 2);
    [self addSubview:self.containerView];
    
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.containerView.ysc_width * 0.8, 40)];
    self.messageLabel.numberOfLines = 2;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = RGB_GRAY(102);
    self.messageLabel.ysc_centerX = self.containerView.ysc_width / 2;
    self.messageLabel.ysc_centerY = self.containerView.ysc_height / 2;
    [self.containerView addSubview:self.messageLabel];
    
    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    self.actionButton.backgroundColor = [UIColor redColor];
    [self.actionButton setTitle:@"重新加载" forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.actionButton.ysc_centerX = self.containerView.ysc_width / 2;
    self.actionButton.ysc_top = CGRectGetMaxY(self.messageLabel.frame) + 8;
    [self.actionButton ysc_addCornerWithRadius:4];
    [self.containerView addSubview:self.actionButton];
    
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:YSCConfigManagerInstance.defaultImageName]];
    self.iconImageView.ysc_centerX = self.containerView.ysc_width / 2;
    self.iconImageView.ysc_top = self.messageLabel.ysc_origin.y - self.iconImageView.ysc_height - 8;
    [self.containerView addSubview:self.iconImageView];
}
- (void)_setupCustomValues {
    
}

#pragma mark - 根据内容自动调整控件的位置
- (void)_resetMessageLabel {
    // 根据message内容重新调整位置和大小
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(self.containerView.ysc_width * 0.8, 40)];
    self.messageLabel.frame = CGRectMake(0, 0, size.width, size.height);
    self.messageLabel.ysc_centerX = self.containerView.ysc_width / 2;
    self.messageLabel.ysc_centerY = self.containerView.ysc_height / 2;
    
    // 重新调整button的位置
    self.actionButton.ysc_top = CGRectGetMaxY(self.messageLabel.frame) + 8;
    
    // 重新调整icon的位置
    [self _resetIconImageView];
}
- (void)_resetIconImageView {
    CGSize size2 = CGSizeMake(50, 50);
    if (self.iconImageView.image) {
        CGSize size1 = self.iconImageView.image.size;
        size2 = CGSizeMake(MIN(MAX(50, size1.width), 120), MIN(MAX(50, size1.height), 120));
    }
    self.iconImageView.ysc_width = size2.width;
    self.iconImageView.ysc_height = size2.height;
    self.iconImageView.ysc_top = self.messageLabel.ysc_origin.y - self.iconImageView.ysc_height - 8;
    self.iconImageView.ysc_centerX = self.containerView.ysc_width / 2;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetFrameWithEdgeInsets:self.edgeInsets];
    [self _resetMessageLabel];
}

#pragma mark - create
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView {
    return [self createYSCTipsViewOnView:contentView buttonAction:nil];
}
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                           buttonAction:(YSCBlock)buttonAction {
    return [self createYSCTipsViewOnView:contentView edgeInsets:UIEdgeInsetsZero withMessage:nil imageName:nil buttonTitle:nil buttonAction:buttonAction];
}
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                             edgeInsets:(UIEdgeInsets)edgeInsets
                            withMessage:(NSString *)message
                              imageName:(NSString *)imageName
                            buttonTitle:(NSString *)buttonTitle
                           buttonAction:(YSCBlock)buttonAction {
    if ( ! contentView) {
        return nil;
    }
    YSCTipsView *tipsView = [[YSCTipsView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:tipsView];
    [tipsView resetImageName:imageName];
    [tipsView resetMessage:message];
    [tipsView resetActionWithButtonTitle:buttonTitle buttonAction:buttonAction];
    [tipsView resetFrameWithEdgeInsets:edgeInsets];
    return tipsView;
}

#pragma mark - reset
- (void)resetFrameWithEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    CGRect frame = self.superview.bounds;
    frame.origin.x = edgeInsets.left;
    frame.origin.y = edgeInsets.top;
    frame.size.width = CGRectGetWidth(self.superview.bounds) - (edgeInsets.left + edgeInsets.right);
    frame.size.height = CGRectGetHeight(self.superview.bounds) - (edgeInsets.top + edgeInsets.bottom);
    self.frame = frame;
    
    self.containerView.ysc_width = frame.size.width;
    self.containerView.center = CGPointMake(self.ysc_width / 2, self.ysc_height / 2);
}
- (void)resetImageName:(NSString *)imageName {
    if (OBJECT_IS_EMPTY(TRIM_STRING(imageName))) {
        imageName = YSCConfigManagerInstance.defaultImageName;
    }
    @weakiy(self);
    [self.iconImageView ysc_setImageWithURLString:imageName completed:^(UIImage *image, NSError *error) {
        [weak_self _resetIconImageView];
    }];//兼容网络图片
}
- (void)resetMessage:(NSString *)message {
    self.messageLabel.text = message;
    [self _resetMessageLabel];
}
- (void)resetActionWithButtonTitle:(NSString *)buttonTitle buttonAction:(YSCBlock)buttonAction {
    if (OBJECT_IS_EMPTY(TRIM_STRING(buttonTitle))) {
        buttonTitle = @"重新加载";
    }
    if (buttonAction) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.actionButton ysc_reAddTouchUpInsideEventBlock:^(id sender) {
            if (buttonAction) {
                buttonAction();
            }
        }];
    }
    else {
        self.actionButton.hidden = YES;
    }
}

@end
