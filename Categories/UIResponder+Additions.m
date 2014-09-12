//
//  UIResponder+Additions.m
//  TGO
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "UIResponder+Additions.h"

static __weak id currentFirstResponder;

@implementation UIResponder (Additions)

+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}


@end
