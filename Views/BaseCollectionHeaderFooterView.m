//
//  BaseCollectionHeaderFooterView.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseCollectionHeaderFooterView.h"

@implementation BaseCollectionHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    [UIView clearBackgroundColorOfView:self];       //递归设置tag>=1000的背景颜色为空
    [UIView resetFontSizeOfView:self];              //递归缩放label和button的字体大小
}

+ (CGSize)SizeOfView {
    return AUTOLAYOUT_SIZE(CGSizeMake(640, 200));
}

+ (UINib *)NibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

@end
