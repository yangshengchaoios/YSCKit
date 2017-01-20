//
//  YSCModelAdapterManager.h
//  YSCKitDemo
//
//  Created by 杨胜超 on 16/10/20.
//  Copyright © 2016年 Builder. All rights reserved.
//

@protocol YSCModelAdapterDelegate <NSObject>

- (NSObject *)mappingWithClass:(Class)clazz keyValues:(id)keyValues;
- (void)decodingWithObject:(NSObject *)object coder:(NSCoder *)decoder;
- (void)encodingWithObject:(NSObject *)object coder:(NSCoder *)encoder;
- (NSString *)jsonStringOfObject:(NSObject *)object;
- (NSString *)descriptionOfObject:(NSObject *)object;
@end


@interface YSCModelAdapterManager : NSObject

+ (id<YSCModelAdapterDelegate>)adapter;

@end
