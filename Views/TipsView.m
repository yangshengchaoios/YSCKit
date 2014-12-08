//
//  TipsView.m
//  KQ
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "TipsView.h"

#define MariginOfTipsLabel       15.0f
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
        
    }
    return self;
}

/**
 *  可以根据设置的tipstring动态调整大小和位置
 *
 *  @param tips 自定义提醒内容
 */
- (void)setTipsLabelText:(NSString *)tips {
    self.tipsLabel.text = tips;
    self.tipsLabel.width = self.width * 6 / 8;
    [self.tipsLabel sizeToFit];                 //计算出label的大小，目的是为了给image和button位置参照
    self.tipsLabel.centerX = self.centerX;
    self.tipsLabel.centerY = self.centerY;
    
    if (self.tipsImageView) {
        self.tipsImageView.centerY = self.centerY - (self.tipsImageView.height + self.tipsLabel.height) / 2.0f - MariginOfTipsLabel;
    }
    if (self.tipsButton) {
        self.tipsButton.centerY = self.centerY + (self.tipsButton.height + self.tipsLabel.height) / 2.0f + MariginOfTipsLabel;
    }
}

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view {
    
    TipsView *tipsView = nil;
    if ([view viewWithTag:TagOfTipsView]) {
        tipsView = (TipsView *)[view viewWithTag:TagOfTipsView];
    }
    else {
        tipsView = [[TipsView alloc] init];
    }
    
    tipsView.tag = TagOfTipsView;
    tipsView.backgroundColor = [UIColor clearColor];
    tipsView.top = 0;
    tipsView.left = 0;
    tipsView.width = view.width;
    tipsView.height = view.height;
    
    tipsView.tipsLabel = [[UILabel alloc] init];
    tipsView.tipsLabel.backgroundColor = [UIColor clearColor];
    tipsView.tipsLabel.textColor = kDefaultEmptyTextColor;
    tipsView.tipsLabel.font = AUTOLAYOUT_FONT(16);
    tipsView.tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsView.tipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
    tipsView.tipsLabel.numberOfLines = 0;
    [tipsView setTipsLabelText:tips];
    
    [tipsView addSubview:tipsView.tipsLabel];
    
    [view addSubview:tipsView];//这句代码会遮挡view上的其他控件
    //    [view insertSubview:tipsView atIndex:0];//保证tipsView只在view上面一层  TODO:需要测试
    
    return tipsView;
    
}

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
           andPressHandle:(TipsTapHandle)pressHandle {
    
    TipsView *tipsView = [TipsView showTips:tips inView:view];
    
    if (image) {
        tipsView.tipsImageView = [[UIImageView alloc] initWithImage:image];
        tipsView.tipsImageView.centerX = tipsView.centerX;
        tipsView.tipsImageView.centerY = tipsView.centerY - (tipsView.tipsImageView.height + tipsView.tipsLabel.height) / 2.0f - MariginOfTipsLabel;
        tipsView.tipsImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [tipsView addSubview:tipsView.tipsImageView];
    }
    
    if (pressHandle) {
        tipsView.userInteractionEnabled = YES;
        [tipsView bk_whenTapped:^{
            pressHandle();
        }];
    }
    
    return tipsView;
}

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
           andButtonTitle:(NSString *)buttonTitle
          andButtonHandle:(TipsTapHandle)handle {
    return [TipsView showTips:tips
                          inView:view
                       withImage:image
            andButtonNormalImage:[UIImage imageNamed:@"button_orange"]
         andButtonHighLightImage:[UIImage imageNamed:@"button_orange"]
                  andButtonTitle:buttonTitle
                 andButtonHandle:handle];
}

+ (instancetype)showTips:(NSString *)tips
                   inView:(UIView *)view
                withImage:(UIImage *)image
     andButtonNormalImage:(UIImage *)normalImage
  andButtonHighLightImage:(UIImage *)highLightImage
           andButtonTitle:(NSString *)buttonTitle
          andButtonHandle:(TipsTapHandle)handle {
    
    TipsView *tipsView = [TipsView showTips:tips
                                     inView:view
                                  withImage:image
                             andPressHandle:nil];
    
    tipsView.tipsButton = [[UIButton alloc]init];
    tipsView.tipsButton.backgroundColor = [UIColor clearColor];
    if (normalImage) {
        [tipsView.tipsButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    }
    else {
        
    }
    if (highLightImage) {
        [tipsView.tipsButton setBackgroundImage:highLightImage forState:UIControlStateHighlighted];
    }
    else {
        
    }
    [tipsView.tipsButton setTitle:buttonTitle forState:UIControlStateNormal];
    tipsView.tipsButton.titleLabel.font = AUTOLAYOUT_FONT(16);
    tipsView.tipsButton.titleLabel.textColor = [UIColor whiteColor];
    tipsView.tipsButton.width = 100.0f;
    tipsView.tipsButton.height = 32.0f;
    tipsView.tipsButton.centerX = tipsView.centerX;
    tipsView.tipsButton.centerY = tipsView.centerY + (tipsView.tipsButton.height + tipsView.tipsLabel.height) / 2.0f + MariginOfTipsLabel;
    [tipsView addSubview:tipsView.tipsButton];
    
    if (handle) {
        [tipsView.tipsButton bk_addEventHandler:^(id sender) {
            handle();
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return tipsView;
}

@end
