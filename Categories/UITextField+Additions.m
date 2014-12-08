//
//  UITextField+Additions.m
//  YSCKit
//
//  Created by  YangShengchao on 14-4-11.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "UITextField+Additions.h"
#import <objc/runtime.h>

const char *ObjectTagKey;

@implementation UITextField (Additions)

- (void)setMaxLength:(NSInteger)maxLength {
    objc_setAssociatedObject(self, ObjectTagKey, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, ObjectTagKey) integerValue];
}

@end
