
//  BaseModel.m
//  YSCKit
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseModel.h"
#import <objc/runtime.h>

@implementation YSCBaseModel

- (void)formatProperties {
    if (self.stateModel) {
        if (0 == self.stateModel.code) {
            self.stateInteger = 1;
        }
        else if (1 == self.stateModel.code) {
            self.stateInteger = 0;
        }
        else {
            self.stateInteger = self.stateModel.code;
        }
        self.message = self.stateModel.msg;
    }
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

/**
 *  下面两个方法用于子类字段名称映射
 *
 *  @return
 */
+ (NSDictionary *)jsonToModelMapping {
    return @{@"state" : @"stateInteger"};
}
+(JSONKeyMapper*)keyMapper { //将大写首字母转换为小写
    NSDictionary* userToModelMap = [self jsonToModelMapping];
    NSDictionary* userToJSONMap  = [NSMutableDictionary dictionaryWithObjects:userToModelMap.allKeys
                                                                      forKeys:userToModelMap.allValues];
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString *keyName) {
        //1. 先映射字段名称
        NSString *result = [userToModelMap valueForKeyPath:keyName];
        if ([NSString isNotEmpty:result]) {
            keyName = result;
        }
        
        //2. 将json字段第一个字母变小写(如果已经有字段映射的话就不改变)
        if (IsJsonKeyFirstLetterUpper && [NSString isEmpty:result] && [keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter uppercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter lowercaseString] isEqualToString:firstLetter])) {//假如第一个字母大写
                return [[firstLetter lowercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        //1. 先映射字段名称
        NSString *result = [userToJSONMap valueForKeyPath:keyName];
        if ([NSString isNotEmpty:result]) {
            keyName = result;
        }
        
        //2. 将model字段第一个字母变大写(如果已经有字段映射的话就不改变)
        if (IsJsonKeyFirstLetterUpper && [NSString isEmpty:result] && [keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter lowercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter uppercaseString] isEqualToString:firstLetter])) {//假如第一个字母小写
                return [[firstLetter uppercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:toModel
                                          modelToJSONBlock:toJSON];
}

@end

@implementation BaseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

/**
 *  下面两个方法用于子类字段名称映射
 *
 *  @return
 */
+ (NSDictionary *)jsonToModelMapping {
    return nil;
}
+(JSONKeyMapper*)keyMapper { //将大写首字母转换为小写
    NSDictionary* userToModelMap = [self jsonToModelMapping];
    NSDictionary* userToJSONMap  = [NSMutableDictionary dictionaryWithObjects:userToModelMap.allKeys
                                                                      forKeys:userToModelMap.allValues];
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString *keyName) {
        //1. 先映射字段名称
        NSString *result = [userToModelMap valueForKeyPath:keyName];
        if ([NSString isNotEmpty:result]) {
            keyName = result;
        }
        
        //2. 将json字段第一个字母变小写(如果已经有字段映射的话就不改变)
        if (IsJsonKeyFirstLetterUpper && [NSString isEmpty:result] && [keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter uppercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter lowercaseString] isEqualToString:firstLetter])) {//假如第一个字母大写
                return [[firstLetter lowercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        //1. 先映射字段名称
        NSString *result = [userToJSONMap valueForKeyPath:keyName];
        if ([NSString isNotEmpty:result]) {
            keyName = result;
        }
        
        //2. 将model字段第一个字母变大写(如果已经有字段映射的话就不改变)
        if (IsJsonKeyFirstLetterUpper && [NSString isEmpty:result] && [keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter lowercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter uppercaseString] isEqualToString:firstLetter])) {//假如第一个字母小写
                return [[firstLetter uppercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:toModel
                                          modelToJSONBlock:toJSON];
}

/**
 *  添加反序列化方法
 *
 *  @param aDecoder
 *
 *  @return
 */
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        
        @try {
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                                       encoding:NSUTF8StringEncoding];
                id value = [aDecoder decodeObjectForKey:key];
                if (value) {
                    [self setValue:value forKey:key];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
            return nil;
        }
        @finally {
            
        }
        
        free(properties);
    }
    return self;
}

/**
 *  添加序列化方法
 *
 *  @param aCoder
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                               encoding:NSUTF8StringEncoding];
        
        id value=[self valueForKey:key];
        if (value && key) {
            if ([value isKindOfClass:[NSObject class]]) {
                [aCoder encodeObject:value forKey:key];
            } else {
                NSNumber * v = [NSNumber numberWithInt:(int)value];
                [aCoder encodeObject:v forKey:key];
            }
        }
    }
    free(properties);
    properties = NULL;
}

@end

@implementation StateModel

+ (NSDictionary *)jsonToModelMapping {
    return @{@"Msg" : @"msg"};
}

@end





