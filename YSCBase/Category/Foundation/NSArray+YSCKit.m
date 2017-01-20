//
//  NSArray+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSArray+YSCKit.h"


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation NSArray (YSCKit)
+ (BOOL)ysc_isEquals:(NSArray *)array1 with:(NSArray *)array2 {
    //0. 当全为nil
    if ( ! array1 && ! array2) {
        return YES;
    }
    //1. 其中一个为nil
    if ( ! array1 || ! array2) {
        return NO;
    }
    //2. 当数组元素个数不等
    if ([array1 count] != [array2 count]) {
        return NO;
    }
    //3. 判断array1的元素是否都同样存在于array2
    NSSet *set1 = [NSSet setWithArray:array1];
    NSSet *set2 = [NSSet setWithArray:array2];
    return [set1 isEqualToSet:set2];
}
+ (NSArray *)ysc_intersectionArrayBetween:(NSArray *)array1 and:(NSArray *)array2 {
    //0. 其中一个为nil
    if ( ! array1 || ! array2) {
        return nil;
    }
    //1. 其中一个为空
    if (0 == [array1 count] || 0 == [array2 count]) {
        return @[];
    }
    //2. 过滤出相同的元素
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSObject *obj1 in array1) {
        if ([array2 containsObject:obj1] && ! [resultArray containsObject:obj1]) {
            [resultArray addObject:obj1];
        }
    }
    return resultArray;
}
+ (NSArray *)ysc_reverseArray:(NSArray *)array {
    //0. 判空
    if ( ! array) {
        return nil;
    }
    if (0 == [array count]) {
        return @[];
    }
    //1. 反转元素
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsWithOptions:NSEnumerationReverse
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [resultArray addObject:obj];
                            }];
    return resultArray;
}
@end
