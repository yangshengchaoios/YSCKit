//
//  ReachabilityManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-24.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "ReachabilityManager.h"

@implementation ReachabilityManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (id)init {
    self = [super init];
    if (self) {
        [self initBlock];
    }
    return self;
}

- (void)initBlock {
    WeakSelfType blockSelf = self;
    self.reachability = [Reachability reachabilityForInternetConnection];
    self.reachability.reachableBlock = ^(Reachability *reach) {
        blockSelf.reachable = YES;
    };
    self.reachability.unreachableBlock = ^(Reachability *reach) {
        blockSelf.reachable = NO;
    };
    [self.reachability startNotifier];
    self.reachable = [self.reachability isReachable];
}

@end