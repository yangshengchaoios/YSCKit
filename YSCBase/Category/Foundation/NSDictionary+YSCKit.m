//
//  NSDictionary+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSDictionary+YSCKit.h"


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation NSDictionary (YSCKit)

- (NSString *)ysc_sortedKeyAndJoinedString {
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *joinedArray = [NSMutableArray array];
    for (NSString *key in keys) {
        NSString *joinedString = [NSString stringWithFormat:@"%@=%@", key, self[key]];
        [joinedArray addObject:joinedString];
    }
    return [joinedArray componentsJoinedByString:@"&"];
}

+ (NSString *)ysc_sortedKeyAndJoinedStringByDictionary:(NSDictionary *)dictionary {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(dictionary);
    return [dictionary ysc_sortedKeyAndJoinedString];
}

@end
