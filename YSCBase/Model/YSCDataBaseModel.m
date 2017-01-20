//
//  YSCDataBaseModel.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCDataBaseModel.h"
#import "YSCModelAdapterManager.h"

@implementation YSCDataBaseModel

#pragma mark - coder & copy
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        [[YSCModelAdapterManager adapter] decodingWithObject:self coder:decoder];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [[YSCModelAdapterManager adapter] encodingWithObject:self coder:encoder];
}
- (NSString *)description {
    return [[YSCModelAdapterManager adapter] descriptionOfObject:self];
}
- (instancetype)copyWithZone:(NSZone *)zone {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

#pragma mark - model <-> json
/** 单独转换属性名称(一般用于改变头字母大小写) */
+ (NSString *)jsonKeyFromPropertyName:(NSString *)propertyName {
    return propertyName;
}
/** 属性名称对应json中的key名称 */
+ (NSDictionary *)propertyNameToJsonKey {
    return @{};
}
/** 属性名称对应的class名称 */
+ (NSDictionary *)propertyNameToClassName {
    return @{};
}
/** json -> model */
+ (id)objectWithKeyValues:(id)keyValues {
    return [[YSCModelAdapterManager adapter] mappingWithClass:[self class] keyValues:keyValues];
}
/** model -> json */
- (NSString *)toJSONString {
    return [[YSCModelAdapterManager adapter] jsonStringOfObject:self];
}

#pragma mark - private method
/**
 *  这三个方法存在的原因是由于 'YSCDataBaseModel' 的子类无法被swizzling从而导致模型映射失败
 */
+ (NSString *)_jsonKeyFromPropertyName:(NSString *)propertyName {
    return [self jsonKeyFromPropertyName:propertyName];
}
+ (NSDictionary *)_propertyNameToJsonKey {
    return [self propertyNameToJsonKey];
}
+ (NSDictionary *)_propertyNameToClassName {
    return [self propertyNameToClassName];
}

#pragma mark - convenient networking methods
+ (NSString *)getByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block {
    return [self _requestByApi:apiName params:params requestType:YSCRequestTypeGET block:block];
}
+ (NSString *)postByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block {
    return [self _requestByApi:apiName params:params requestType:YSCRequestTypePOST block:block];
}
+ (NSString *)requestByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block {
    return [self _requestByApi:apiName params:params requestType:YSCRequestTypePostBodyData block:block];
}
+ (NSString *)_requestByApi:(NSString *)apiName
                     params:(NSDictionary *)params
                requestType:(YSCRequestType)requestType
                      block:(YSCObjectErrorMessageBlock)block {
    return [YSCRequestManagerInstance requestWithApi:apiName params:params dataModel:[self class] type:requestType success:^(id responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failed:^(NSString *YSCErrorType, NSError *error) {
        NSString *errMsg = [YSCRequestManagerInstance resolveYSCErrorType:YSCErrorType andError:error];
        if (block) {
            block(nil, errMsg);
        }
    }];
}
@end

