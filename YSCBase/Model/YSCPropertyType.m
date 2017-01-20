//
//  YSCPropertyType.m
//  YSCKit
//
//  Created by 杨胜超 on 16/10/31.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCPropertyType.h"

@implementation YSCPropertyType

static NSMutableDictionary *types_;
+ (void)initialize {
    types_ = [NSMutableDictionary dictionary];
}

+ (instancetype)cachedTypeWithCode:(NSString *)code {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(code);
    YSCPropertyType *type = types_[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        types_[code] = type;
    }
    return type;
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code {
    _code = code;
    RETURN_WHEN_OBJECT_IS_EMPTY(code);
    
    if ([code isEqualToString:YSCPropertyTypeId]) {
        _isIdType = YES;
    }
    else if (code.length == 0) {
        _isKVCDisabled = YES;
    }
    else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _isFromFoundation = [YSCGeneral isClassFromFoundation:_typeClass];
        _isNumberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    }
    else if ([code isEqualToString:YSCPropertyTypeSEL] ||
             [code isEqualToString:YSCPropertyTypeIvar] ||
             [code isEqualToString:YSCPropertyTypeMethod]) {
        _isKVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[YSCPropertyTypeInt, YSCPropertyTypeShort, YSCPropertyTypeBOOL1, YSCPropertyTypeBOOL2, YSCPropertyTypeFloat, YSCPropertyTypeDouble, YSCPropertyTypeLong, YSCPropertyTypeLongLong, YSCPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _isNumberType = YES;
        
        if ([lowerCode isEqualToString:YSCPropertyTypeBOOL1]
            || [lowerCode isEqualToString:YSCPropertyTypeBOOL2]) {
            _isBoolType = YES;
        }
    }
}
@end
