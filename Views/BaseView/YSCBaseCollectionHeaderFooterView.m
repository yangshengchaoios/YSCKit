//
//  BaseCollectionHeaderFooterView.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseCollectionHeaderFooterView.h"

@implementation YSCBaseCollectionHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self resetFontSizeOfView];         //递归缩放label和button的字体大小
    [self resetConstraintOfView];
}

+ (CGSize)SizeOfView {
    return AUTOLAYOUT_SIZE_WH(XIB_WIDTH, 200);
}

+ (UINib *)NibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

@end
