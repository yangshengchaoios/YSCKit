//
//  ServerTimeSynchronizer.m
//  YSCKit
//
//  Created by  YangShengchao on 14-9-19.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "ServerTimeSynchronizer.h"

#define CachedKeyOfInterval     @"CachedKeyOfInterval"

@interface ServerTimeSynchronizer ()

@property (assign, nonatomic) BOOL isSyncSuccessed; //是否同步成功
@property (assign, nonatomic) double interval;      //服务器时间 - 本地时间  (服务器时间比本地时间快多少)
@property (nonatomic, strong) NSLock *theLock;

@end

@implementation ServerTimeSynchronizer

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
	self = [super init];
	if (self) {
        self.interval = [[self loadCachedInterval] doubleValue];   //从缓存中读取默认值
        self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:self.interval / ScaleOfResponseTime] timeStamp];
        self.theLock = [[NSLock alloc] init];
        
		[NSTimer scheduledTimerWithTimeInterval:1
                                         target:self
                                       selector:@selector(timerFired:)
                                       userInfo:nil
                                        repeats:YES];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshServerTime)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearActions)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
	}
	return self;
}

//心跳方法
- (void)timerFired:(NSTimer *)theTimer {
	[self.theLock lock];
    self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:(self.interval / ScaleOfResponseTime)] timeStamp];
    [self.theLock unlock];
}

//刷新服务器时间
- (void)refreshServerTime {
    self.interval = [[self loadCachedInterval] doubleValue];   //从缓存中读取默认值
    
	WeakSelfType blockSelf = self;
    NSDate *date = [NSDate date];
    [AFNManager getDataWithAPI:kResPathAppGetServerTime
                  andDictParam:nil
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  NSDate *nowDate = [NSDate date];
                  NSTimeInterval httpWaste = [nowDate timeIntervalSinceDate:date];//计算接口调用的执行时间(秒)
                  NSLog(@"waste:%lf", httpWaste);
                  
                  if (httpWaste >= 2) {//如果接口执行时间大于2秒就得重新请求
                      [blockSelf refreshFaild];
                  }
                  else {
                      [NSObject cancelPreviousPerformRequestsWithTarget:blockSelf
                                                               selector:@selector(refreshServerTime)
                                                                 object:nil];
                      blockSelf.isSyncSuccessed = YES;
                      NSString *oldServerTime = [NSString stringWithFormat:@"%@", responseObject];
                      NSTimeInterval serverTime = [oldServerTime doubleValue] + httpWaste * ScaleOfResponseTime / 2.0f;
                      NSTimeInterval localTime = [nowDate timeIntervalSince1970] * ScaleOfResponseTime;
                      blockSelf.interval = serverTime - localTime;
                      [[StorageManager sharedInstance] archiveDictionary:@{ CachedKeyOfInterval : [NSString stringWithFormat:@"%lf", blockSelf.interval] }
                                                              toFilePath:[blockSelf cacheFilePath:nil]
                                                               overwrite:YES];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    
                    [blockSelf refreshFaild];
                }];
}
- (void)refreshFaild {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(refreshServerTime)
                                               object:nil];
	if (NO == self.isSyncSuccessed) {
		[self performSelector:@selector(refreshServerTime) withObject:nil afterDelay:30];
	}
}

- (void)clearActions {
	self.isSyncSuccessed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(refreshServerTime)
                                               object:nil];
}

#pragma mark - 缓存相关

- (NSString *)loadCachedInterval {
    NSDictionary *cacheInfo = [[StorageManager sharedInstance] unarchiveDictionaryFromFilePath:[self cacheFilePath:nil]];
    if ([cacheInfo objectForKey:CachedKeyOfInterval]) {
        return [NSString stringWithFormat:@"%@", cacheInfo[CachedKeyOfInterval]];
    }
    else {
        return @"-0.5";
    }
}
- (NSString *)cacheFilePath:(NSString *)suffix {
	NSString *fileName = [NSString stringWithFormat:@"%@%@.dat",
                          NSStringFromClass(self.class),
                          [NSString isEmpty:suffix] ? @"" :[NSString stringWithFormat:@"_%@",suffix]]; //缓存文件名称
	return [[[StorageManager sharedInstance] directoryPathOfLibraryCachesCommon] stringByAppendingPathComponent:fileName];
}

@end
