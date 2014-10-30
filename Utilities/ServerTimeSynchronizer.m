//
//  ServerTimeSynchronizer.m
//  TGO8
//
//  Created by  YangShengchao on 14-9-19.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "ServerTimeSynchronizer.h"

#define CachedKeyOfInterval     @"CachedKeyOfInterval"

@interface ServerTimeSynchronizer ()

@property (assign, nonatomic) BOOL isSyncSuccessed;         //是否同步成功
@property (assign, nonatomic) NSTimeInterval interval;      //(服务器时间 - 本地时间)s
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
		self.interval = 0;
        [self refreshServerTime];
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
    self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:self.interval] timeStamp];
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
                  NSTimeInterval httpWaste = [[NSDate date] timeIntervalSinceDate:date];//计算接口调用的执行时间
                  NSString *oldServerTime = [NSString stringWithFormat:@"%@", responseObject];
                  
                  if (httpWaste < 2) {
                      [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                               selector:@selector(refreshServerTime)
                                                                 object:nil];
                      blockSelf.isSyncSuccessed = YES;
                      NSTimeInterval serverTime = [oldServerTime doubleValue] + httpWaste / 2.0f;
                      NSTimeInterval localTime = [[NSDate date] timeIntervalSince1970];
                      blockSelf.interval =  serverTime - localTime;
                      
                      [[StorageManager sharedInstance] archiveDictionary:@{ CachedKeyOfInterval : [NSString stringWithFormat:@"%f", blockSelf.interval] }
                                                              toFilePath:[self cacheFilePath:nil]
                                                               overwrite:YES];
                      
                      NSLog(@" \nblockSelf.interval:%f\nhttpWaste: %f",  blockSelf.interval,httpWaste);
                  }
                  else {
                      [blockSelf refreshFaild];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf refreshFaild];
                }];
}
- (void)refreshFaild {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if (self.isSyncSuccessed == NO) {
		[self performSelector:@selector(refreshServerTime) withObject:nil afterDelay:30];
	}
}

- (void)clearActions {
	self.isSyncSuccessed = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
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
