//
//  SearchPromptModel.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "SearchPromptModel.h"

@implementation SearchPromptModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"promptId" : @"Id",
             @"promptName" : @"Name",
             @"promptType" : @"Type"};
}
@end
