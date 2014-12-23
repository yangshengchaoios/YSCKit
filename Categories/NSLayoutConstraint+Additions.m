//
//  NSLayoutConstraint+Additions.m
//  AudioBook
//
//  Created by yangshengchao on 14/12/23.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "NSLayoutConstraint+Additions.h"

@implementation NSLayoutConstraint (Additions)

- (NSString *)description
{
    NSString *description = super.description;
//    NSString *asciiArtDescription = self.asciiArtDescription;
    UIView *firstItem = (UIView *)self.firstItem;
    UIView *secondItem = (UIView *)self.secondItem;
    
    return [NSString stringWithFormat:@"constaints = %f,mutilper=%f,(first=%@, second=%@)",
            self.constant,
            self.multiplier,
            NSStringFromCGRect(firstItem.frame),
            NSStringFromCGRect(secondItem.frame)];
}

@end
