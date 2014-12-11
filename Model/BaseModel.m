
//  BaseModel.m
//  YSCKit
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+(JSONKeyMapper*)keyMapper { //将大写首字母转换为小写
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString* keyName) {
        if ([keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter uppercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter lowercaseString] isEqualToString:firstLetter])) {//假如第一个字母大写
                return [[firstLetter lowercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        if ([keyName length] > 0) {
            NSString *firstLetter = [keyName substringToIndex:1];
            if ([[firstLetter lowercaseString] isEqualToString:firstLetter] &&
                ( ! [[firstLetter uppercaseString] isEqualToString:firstLetter])) {//假如第一个字母小写
                return [[firstLetter uppercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
            }
        }
        return keyName;
    };
    
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:toModel modelToJSONBlock:toJSON];
}

@end

@implementation BaseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+(JSONKeyMapper*)keyMapper { //将大写首字母转换为小写
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString* keyName) {
        if ([keyName length] > 0) {
            return [[[keyName substringToIndex:1] lowercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
        }
        else {
            return keyName;
        }
    };
    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        if ([keyName length] > 0) {
            return [[[keyName substringToIndex:1] uppercaseString] stringByAppendingString:[keyName substringFromIndex:1]];
        }
        else {
            return keyName;
        }
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