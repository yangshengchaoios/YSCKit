//
//  YSCTipsView.h
//  YSCKit
//
//  Created by YangShengchao on 15/4/12.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#ifndef kDefaultEmptyImageName
    #define kDefaultEmptyImageName          @"image_default_empty"
#endif

#ifndef kDefaultErrorImageName
    #define kDefaultErrorImageName          @"image_default_error"
#endif

#ifndef kDefaultEmptyMessage
    #define kDefaultEmptyMessage            @"暂无数据"
#endif

@interface YSCTipsView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

#pragma mark - create
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView;
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                           buttonAction:(YSCBlock)buttonAction;
+ (instancetype)createYSCTipsViewOnView:(UIView *)contentView
                            withMessage:(NSString *)message
                              imageName:(NSString *)imageName
                            buttonTitle:(NSString *)buttonTitle
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
- (void)resetActionWithButtonTitle:(NSString *)buttonTitle
                      buttonAction:(YSCBlock)buttonAction;
@end
