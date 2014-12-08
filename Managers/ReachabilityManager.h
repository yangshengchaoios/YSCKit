//
//  ReachabilityManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-24.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ReachabilityManager : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, assign) BOOL reachable;

@end