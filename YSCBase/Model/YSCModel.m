//
//  YSCModel.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCModel.h"
#import "YSCModelAdapterManager.h"

@implementation YSCModel

+ (NSDictionary *)propertyNameToJsonKey {
    return @{};
}
+ (id)objectWithKeyValues:(id)keyValues {
    return [[YSCModelAdapterManager adapter] mappingWithClass:[self class] keyValues:keyValues];
}
- (BOOL)checkRequestIsSuccess {
    return 1 == self.state;
}
- (NSString *)description {
    return [[YSCModelAdapterManager adapter] descriptionOfObject:self];
}

@end
