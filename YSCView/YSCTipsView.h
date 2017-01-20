//
//  YSCTipsView.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCTipsView : UIView
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *actionButton;

#pragma mark - create
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView;
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                           buttonAction:(YSCBlock)buttonAction;
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                             edgeInsets:(UIEdgeInsets)edgeInsets
                            withMessage:(NSString *)message
                              imageName:(NSString *)imageName
                            buttonTitle:(NSString *)buttonTitle
                           buttonAction:(YSCBlock)buttonAction;

#pragma mark - reset
- (void)resetFrameWithEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)resetMessage:(NSString *)message;
- (void)resetImageName:(NSString *)imageName;
- (void)resetActionWithButtonTitle:(NSString *)buttonTitle buttonAction:(YSCBlock)buttonAction;
@end
