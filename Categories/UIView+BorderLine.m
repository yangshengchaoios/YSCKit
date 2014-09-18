//
//  UIView+BorderLine.m
//  SubLayer
//
//  Created by 肖川 on 14-5-16.
//  Copyright (c) 2014年 肖川. All rights reserved.
//

#import "UIView+BorderLine.h"

#define LineBorderWidth 0.5

@implementation UIView (BorderLine)

- (void)setBorderLineColor:(UIColor *)aColor {
    
    [self setBorderLineColor:aColor edgeOrientation:CHEdgeOrientationBottom];
    [self setBorderLineColor:aColor edgeOrientation:CHEdgeOrientationTop];
    [self setBorderLineColor:aColor edgeOrientation:CHEdgeOrientationLeft];
    [self setBorderLineColor:aColor edgeOrientation:CHEdgeOrientationRight];
}

- (void)setBorderLineColor:(UIColor *)aColor
           edgeOrientation:(CHEdgeOrientation)orientation {
    [self setBorderLineColor:aColor edgeOrientation:orientation frame:self.bounds];
}

- (void)setBorderLineColor:(UIColor *)aColor edgeOrientation:(CHEdgeOrientation)orientation frame:(CGRect)aFrame
{
    CALayer *line = [[CALayer alloc] init];
    line.backgroundColor = aColor.CGColor;
    
    CGRect lineFrame = CGRectZero;
    if (CHEdgeOrientationTop == orientation) {
        // 上边加线
        lineFrame = CGRectMake(CGRectGetMinX(self.bounds),
                               CGRectGetMinY(self.bounds),
                               CGRectGetWidth(self.bounds),
                               LineBorderWidth);
    } else if (CHEdgeOrientationLeft == orientation) {
        // 左边加线
        lineFrame = CGRectMake(CGRectGetMinX(self.bounds),
                               CGRectGetMinY(self.bounds),
                               LineBorderWidth,
                               CGRectGetHeight(self.bounds));
    } else if (CHEdgeOrientationBottom == orientation) {
        // 底边加线
        lineFrame = CGRectMake(CGRectGetMinX(self.bounds),
                               CGRectGetMaxY(self.bounds) + LineBorderWidth,
                               CGRectGetWidth(self.bounds),
                               LineBorderWidth);
    } else {
        // 右边加线
        lineFrame = CGRectMake(CGRectGetMaxX(self.bounds) - LineBorderWidth,
                               CGRectGetMinY(self.bounds),
                               LineBorderWidth,
                               CGRectGetHeight(self.bounds));
    }
    line.frame = lineFrame;
    [self.layer addSublayer:line];
}
@end
