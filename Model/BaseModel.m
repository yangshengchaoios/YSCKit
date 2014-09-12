
//  BaseModel.m
//  SCSDTGO
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation BaseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
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