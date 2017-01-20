//
//  YSCPropertyType.h
//  YSCKit
//
//  Created by 杨胜超 on 16/10/31.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
static NSString * const YSCPropertyTypeInt = @"i";
static NSString * const YSCPropertyTypeShort = @"s";
static NSString * const YSCPropertyTypeFloat = @"f";
static NSString * const YSCPropertyTypeDouble = @"d";
static NSString * const YSCPropertyTypeLong = @"l";
static NSString * const YSCPropertyTypeLongLong = @"q";
static NSString * const YSCPropertyTypeChar = @"c";
static NSString * const YSCPropertyTypeBOOL1 = @"c";
static NSString * const YSCPropertyTypeBOOL2 = @"b";
static NSString * const YSCPropertyTypePointer = @"*";

static NSString * const YSCPropertyTypeIvar = @"^{objc_ivar=}";
static NSString * const YSCPropertyTypeMethod = @"^{objc_method=}";
static NSString * const YSCPropertyTypeBlock = @"@?";
static NSString * const YSCPropertyTypeClass = @"#";
static NSString * const YSCPropertyTypeSEL = @":";
static NSString * const YSCPropertyTypeId = @"@";

/**
 *  包装一种类型
 */
@interface YSCPropertyType : NSObject
/** 类型标识符 */
@property (nonatomic, copy) NSString *code;

/** 是否为id类型 */
@property (nonatomic, assign, readonly) BOOL isIdType;

/** 是否为基本数字类型：int、float等 */
@property (nonatomic, assign, readonly) BOOL isNumberType;

/** 是否为BOOL类型 */
@property (nonatomic, assign, readonly) BOOL isBoolType;

/** 对象类型（如果是基本数据类型，此值为nil） */
@property (nonatomic, assign, readonly) Class typeClass;

/** 类型是否来自于Foundation框架，比如NSString、NSArray */
@property (nonatomic, assign, readonly) BOOL isFromFoundation;
/** 类型是否不支持KVC */
@property (nonatomic, assign, readonly) BOOL isKVCDisabled;

/**
 *  获得缓存的类型对象
 */
+ (instancetype)cachedTypeWithCode:(NSString *)code;
@end
