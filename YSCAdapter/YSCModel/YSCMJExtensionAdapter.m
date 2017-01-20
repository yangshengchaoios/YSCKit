//
//  YSCMJExtensionAdapter.m
//  YSCKitDemo
//
//  Created by 杨胜超 on 16/10/20.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCMJExtensionAdapter.h"
#import "MJExtension.h"

@implementation YSCModel (MJExtension)
+ (void)load {
    [super load];
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        /**
         * @brief   替换在MJExtension中定义的NSObject扩展方法
         *
         */
        SWIZZLING_CLASS_METHOD(object_getClass((id)self),
                               @selector(mj_replacedKeyFromPropertyName),
                               @selector(propertyNameToJsonKey));
    });
}
@end

@implementation YSCDataBaseModel (MJExtension)
+ (void)load {
    [super load];
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        /**
         * @brief   替换在MJExtension中定义的NSObject扩展方法
         *
         */
        SWIZZLING_CLASS_METHOD(object_getClass((id)self),
                               @selector(mj_replacedKeyFromPropertyName121:),
                               @selector(_jsonKeyFromPropertyName:));
        SWIZZLING_CLASS_METHOD(object_getClass((id)self),
                               @selector(mj_replacedKeyFromPropertyName),
                               @selector(_propertyNameToJsonKey));
        SWIZZLING_CLASS_METHOD(object_getClass((id)self),
                               @selector(mj_objectClassInArray),
                               @selector(_propertyNameToClassName));
    });
}
@end

@implementation YSCMJExtensionAdapter

- (NSObject *)mappingWithClass:(Class)clazz keyValues:(id)keyValues {
    if ([keyValues isKindOfClass:[NSArray class]]) {
        return [clazz mj_objectArrayWithKeyValuesArray:keyValues];
    }
    else {
        return [clazz mj_objectWithKeyValues:keyValues];
    }
}

- (void)decodingWithObject:(NSObject *)object coder:(NSCoder *)decoder {
    [object mj_decode:decoder];
}
- (void)encodingWithObject:(NSObject *)object coder:(NSCoder *)encoder {
    [object mj_encode:encoder];
}

- (NSString *)jsonStringOfObject:(NSObject *)object {
    return [object mj_JSONString];
}
- (NSString *)descriptionOfObject:(NSObject *)object {
    return [object mj_keyValues].description;
}

@end
