//
//  NSDictionary+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface NSDictionary (YSCKit)

/**
 *  返回格式：key1=value1&key2=value2...
 *  局限：只能处理key是字符串类型，且不能重复。
 */
- (NSString *)ysc_sortedKeyAndJoinedString;
+ (NSString *)ysc_sortedKeyAndJoinedStringByDictionary:(NSDictionary *)dictionary;

@end
