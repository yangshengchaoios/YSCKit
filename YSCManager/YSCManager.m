//
//  YSCManager.m
//  YSCKit
//
//  Created by Builder on 16/6/29.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCManager.h"

@implementation YSCManager

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[YSCManager alloc] init];
    });
    return _sharedObject;
}
- (id)init {
    self = [super init];
    if (self) {
        ADD_OBSERVER(@selector(_didAppBecomeActive), UIApplicationDidBecomeActiveNotification);
        ADD_OBSERVER(@selector(_didAppEnterBackground), UIApplicationDidEnterBackgroundNotification);
        self.reachabilityStatus = YSCReachabilityStatusViaWiFi;
        [self _setupCustomValues];
        [self _checkAppApproved];
    }
    return self;
}
- (void)_setupCustomValues {
    // 在category中重写该方法可以修改默认值
}
- (void)_didAppBecomeActive {
    [self _checkAppApproved];
}
- (void)_didAppEnterBackground {
    
}
- (void)_checkAppApproved {
    if ( ! self.isAppApproved) {
        [YSCGeneral checkOnAppStoreStatus:nil block:^(NSDictionary *releaseItem) {
            NSString *onlineVersion = releaseItem[@"version"];
            if (OBJECT_ISNOT_EMPTY(onlineVersion) &&
                NSOrderedDescending != COMPARE_CURRENT_VERSION(onlineVersion)) {
                YSCSaveObject(@(YES), @"YSCManager_isAppApproved");// 一旦通过了审核就不再检测
                POST_NOTIFICATION(kNotifyAppIsReadyForSale);
            }
        }];
    }
}

#pragma mark - getter
- (BOOL)isAppApproved {
    if ( ! _isAppApproved) {
        _isAppApproved = [YSCGetObject(@"YSCManager_isAppApproved") boolValue];
    }
    return _isAppApproved;
}
- (BOOL)isReachable {
    return YSCReachabilityStatusNotReachable != self.reachabilityStatus;
}
- (NSString *)udid {
    if ( ! _udid) {
        NSString *tempUdid = YSCGetObject(@"OpenUDID");
        if (OBJECT_IS_EMPTY(tempUdid)) {
            tempUdid = [UIDevice ysc_openUdid];//保证只获取一次udid就保存在内存中！
            if (OBJECT_ISNOT_EMPTY(tempUdid)) {
                YSCSaveObject(tempUdid, @"OpenUDID");
            }
        }
        _udid = tempUdid;
    }
    return _udid == nil ? @"" : _udid;
}

@end
