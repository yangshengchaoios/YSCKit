//
//  UIViewController+Additions.m
//  KQ
//
//  Created by yangshengchao on 15/4/23.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "UIViewController+Additions.h"
#import <objc/runtime.h>

const char *DelegateKey;

@implementation UIViewController (Additions)

- (void)setCustomTransitioningDelegate:(ADTransitioningDelegate *)transitioningDelegate {
    self.transitioningDelegate = transitioningDelegate;
    objc_setAssociatedObject(self, DelegateKey, transitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (ADTransitioningDelegate *)customTransitioningDelegate {
    return objc_getAssociatedObject(self, DelegateKey);
}

@end
