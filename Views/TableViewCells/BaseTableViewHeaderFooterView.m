//
//  BaseTableViewHeaderFooterView.m
//  KQ
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseTableViewHeaderFooterView.h"

@implementation BaseTableViewHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    [UIView clearBackgroundColorOfView:self];       //递归设置tag>=1000的背景颜色为空
    [UIView resetFontSizeOfView:self];              //递归缩放label和button的字体大小
}

+ (CGFloat)HeightOfView {
    return AUTOLAYOUT_LENGTH(100);
}

@end
