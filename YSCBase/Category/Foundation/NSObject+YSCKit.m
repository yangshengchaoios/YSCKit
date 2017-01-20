//
//  NSObject+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSObject+YSCKit.h"
#import <objc/runtime.h>

@implementation NSObject (YSCKit)

YSC_DYNAMIC_PROPERTY_OBJECT(sectionKey, setSectionKey, RETAIN_NONATOMIC, NSString *)

@end
