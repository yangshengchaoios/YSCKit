//
//  YSCData.m
//  YSCKit
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCData.h"
#import "YYReachability.h"
#define CachedSyncInterval          @"CachedSyncInterval"       //本地缓存的与服务器时间差(毫秒)
#define ConfigPlistPath             [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]
#define ConfigDebugPlistPath        [[NSBundle mainBundle] pathForResource:@"AppConfigDebug" ofType:@"plist"]

//--------------------------------------
//  定义全局变量
//--------------------------------------
@interface YSCData () <AVAudioPlayerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) YYReachability *reachability;
// 参数配置
@property (nonatomic, strong) NSMutableDictionary *appParams;           //内存中的参数(high)
@property (nonatomic, strong) NSMutableDictionary *onlineParams;        //在线参数(normal)
@property (nonatomic, strong) NSMutableDictionary *localParams;         //本地参数(low)
// 同步服务器时间
@property (assign, nonatomic) BOOL isSyncSuccess;                       //服务器时间是否同步成功
@property (assign, nonatomic) NSTimeInterval syncInterval;              //服务器时间 - 本地时间 (服务器时间比本地时间快多少毫秒)
// 播放音频
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end
@implementation YSCData
+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}
- (id)init {
    self = [super init];
    if (self) {
        self.isReachable = YES;//FIXME:test
//        [self _initReachability];//FIXME:test
        self.appParams = [NSMutableDictionary dictionary];
        self.onlineParams = [NSMutableDictionary dictionary];
        self.localParams = [NSMutableDictionary dictionary];
        
        // 监控APP运行状态
        ADD_OBSERVER(@selector(_didAppBecomeActive), UIApplicationDidBecomeActiveNotification);
        ADD_OBSERVER(@selector(_didAppEnterBackground), UIApplicationDidEnterBackgroundNotification);
        
        // 初始化时间差
        if (nil == YSCGetObject(CachedSyncInterval)) {
            YSCSaveObject(@(-500), CachedSyncInterval);
            self.syncInterval = -500;
        }
        else {
            self.syncInterval =  [YSCGetObject(CachedSyncInterval) doubleValue];
        }
    }
    return self;
}
- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//APP恢复运行
- (void)_didAppBecomeActive {
    [self _refreshServerTime];//每次打开APP都会运行，防止本地修改了时间
}
//用户按下Home键,APP进入后台
- (void)_didAppEnterBackground {
    self.isSyncSuccess = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(_refreshServerTime)
                                               object:nil];
}
//缓存数据库路径
- (NSString *)cacheDBPath {
    NSString *dbName = [NSString stringWithFormat:@"ysckit_cache_%@.sqlite", USER_ID];
    return [[YSCFileManager directoryPathOfDocuments] stringByAppendingPathComponent:dbName];
}


#pragma mark - 网络状态
- (void)_initReachability {
    self.reachability = [YYReachability reachability];
    YSCDataInstance.isReachable = YSCDataInstance.reachability.reachable;
    self.reachability.notifyBlock = ^(YYReachability *reachability){
        YSCDataInstance.isReachable = YSCDataInstance.reachability.reachable;
    };
}
- (BOOL)isReachableViaWiFi {
    return YYReachabilityStatusWiFi == self.reachability.status;
}


#pragma mark - 定位当前位置
- (void)startLocationService {
    if ([UIDevice isLocationAvaible]) {
        if (nil == self.locationManager) {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;//will be informed of any movement
        }
//        [self.locationManager requestAlwaysAuthorization];
//        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"location service is not avaible!!!");
    }
}
- (void)stopLocationService {
    [self.locationManager stopUpdatingLocation];
}
//解析当前GPS坐标成文字信息
- (void)resolveUserLocationWithBlock:(YSCObjectBlock)block {
    [self resolveLocationByLatitude:self.currentLatitude longitude:self.currentLongitude block:block];
}
- (void)resolveLocationByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude block:(YSCObjectBlock)block {
    //TODO:解析地理位置信息
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"----------didUpdateLocations--------");
    for (CLLocation *location in locations) {
        CLLocationCoordinate2D locationCoordinate = location.coordinate;
        CLLocationAccuracy accuracy = location.horizontalAccuracy;
    }
    NSLog(@"-----------------------------------");
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"----didUpdateToLocation----");
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"----didUpdateHeading----");
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"----didFailWithError----");
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"status=%d", status);
}


#pragma mark - 获取服务器当前时间
- (NSDate *)currentDate {
    return [NSDate dateWithTimeIntervalSinceNow:(self.syncInterval / 1000.0f)];
}
- (NSTimeInterval)currentTimeInterval {
    return [self.currentDate timeIntervalSince1970];
}
- (void)refreshServerTimeWithBlock:(YSCObjectBlock)block {
    [YSCRequestInstance requestFromUrl:kPathAppCommonUrl
                               withApi:kPathGetServerTime
                                params:nil
                             dataModel:nil
                                  type:YSCRequestTypeGET
                               success:^(id responseObject) {
                                   NSString *tempStr = [NSString stringWithFormat:@"%@", responseObject];
                                   if (block) {
                                       block(tempStr);
                                   }
                               }
                                failed:^(YSCErrorType errorType, NSError *error) {
                                    if (block) {
                                        block(nil);
                                    }
                                }];
}
//刷新服务器时间
- (void)_refreshServerTime {
    static BOOL isRunning = NO;
    if (isRunning) {
        return;
    }
    isRunning = YES;
    
    NSDate *startDate = [NSDate date];
    [self refreshServerTimeWithBlock:^(NSObject *object) {
        isRunning = NO;
        if (OBJECT_ISNOT_EMPTY(object)) {
            NSDate *endDate = [NSDate date];
            NSTimeInterval httpWaste = [endDate timeIntervalSinceDate:startDate];
            NSLog(@"waste:%lf", httpWaste);
            if (httpWaste >= 2) {//如果接口执行时间大于2秒就得重新请求
                [self _refreshFaild];
            }
            else {
                [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                         selector:@selector(_refreshServerTime)
                                                           object:nil];
                self.isSyncSuccess = YES;
                NSString *tempStr = (NSString *)object;
                NSTimeInterval oldServerTime = [tempStr doubleValue];
                if (oldServerTime < 1000000000.0f * 1000.0f) {//如果单位是秒就需要转换成毫秒
                    oldServerTime *= 1000.0f;
                }
                NSTimeInterval serverTime = oldServerTime + httpWaste * 1000.0f / 2.0f;
                NSTimeInterval localTime = [endDate timeIntervalSince1970] * 1000.0f;
                self.syncInterval = serverTime - localTime;
                YSCSaveObject(@(self.syncInterval), CachedSyncInterval);
            }
        }
        else {
            [self _refreshFaild];
        }
    }];
}
- (void)_refreshFaild {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(_refreshServerTime)
                                               object:nil];
    if (NO == self.isSyncSuccess) {
        [self performSelector:@selector(_refreshServerTime) withObject:nil afterDelay:30];
    }
}


#pragma mark - 获取配置参数(本地参数+在线参数)
- (NSString *)udid {
    if (nil == _udid) {
        NSString *tempUdid = YSCGetObject(@"OpenUDID");
        if (OBJECT_IS_EMPTY(tempUdid)) {
            tempUdid = [UIDevice openUdid];//保证只获取一次udid就保存在内存中！
            if (OBJECT_ISNOT_EMPTY(tempUdid)) {
                YSCSaveObject(tempUdid, @"OpenUDID");
            }
        }
        _udid = tempUdid;
    }
    return _udid == nil ? @"" : _udid;
}
- (NSString *)deviceToken {
    if (OBJECT_IS_EMPTY(_deviceToken)) {
        _deviceToken = YSCGetObject(@"DeviceToken");
    }
    return _deviceToken == nil ? @"" : _deviceToken;
}
- (void)resetConfigParams {
    [self.onlineParams removeAllObjects];
    [self.appParams removeAllObjects];
}

- (BOOL)boolFromConfigByName:(NSString *)name {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value boolValue];
}
- (float)floatFromConfigByName:(NSString *)name {
    RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value floatValue];
}
- (NSInteger)intFromConfigByName:(NSString *)name {
    RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value integerValue];
}
- (UIColor *)colorFromConfigByName:(NSString *)name {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [UIColor colorWithRGBString:value];
}
- (UIImage *)imageFromConfigByName:(NSString *)name {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [UIImage imageNamed:value];
}
- (NSString *)stringFromConfigByName:(NSString *)name {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(name);
    //1. 判断一级缓存
    if (self.appParams[name]) {
        return TRIM_STRING(self.appParams[name]);
    }
    
    NSString *tempValue = [self _valueOfOnlineConfig:name];
    //2. 获取在线配置的参数
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    
    //3. 获取本地配置的参数
    tempValue = [self _valueOfLocalConfig:name];
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    return @"";
}
// 获取本地缓存的在线参数值
- (NSString *)_valueOfOnlineConfig:(NSString *)name {
    if (self.onlineParams[name]) {
        return TRIM_STRING(self.onlineParams[name]);
    }
    [self.onlineParams removeAllObjects];
    self.onlineParams = YSCGetObjectByFile(@"AppParams", @"OnLineParams");
    if (self.onlineParams[name]) {
        return TRIM_STRING(self.onlineParams[name]);
    }
    return nil;
}
// 获取本地配置文件参数值(只有第一次访问是读取硬盘的文件，以后就直接从内存中读取参数值)
- (NSString *)_valueOfLocalConfig:(NSString *)name {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(name);
    //1. 检测缓存
    if (self.localParams[name]) {
        return TRIM_STRING(self.localParams[name]);
    }
    //2. 加载到缓存
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kAppConfigPlist ofType:@"plist"];
    if (DEBUG_MODEL) {
        plistPath = [[NSBundle mainBundle] pathForResource:kAppConfigDebugPlist ofType:@"plist"];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [self.localParams removeAllObjects];
    [self.localParams addEntriesFromDictionary:dict];
    if (self.localParams[name]) {
        return TRIM_STRING(self.localParams[name]);
    }
    return nil;
}


#pragma mark - 播放音频
- (void)playAudioWithFilePath:(NSString *)filePath {
    [self playAudioWithFilePath:filePath repeatCount:0];
}
- (void)playAudioWithFilePath:(NSString *)filePath repeatCount:(NSInteger)count {
    [self stopPlaying];
    if ([YSCFileManager fileExistsAtPath:filePath]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
        NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:filePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer setNumberOfLoops:count];
        [self.audioPlayer play];
    }
}
- (void)stopPlaying {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}
#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    player = nil;
}
@end
