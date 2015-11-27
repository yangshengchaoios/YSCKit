//
//  EZGDataModel.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/8.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGDataModel.h"
#import <FMDB/FMDB.h>

//=============================================
//
//  AVOS在线参数模型
//
//=============================================
@implementation AVOSParamName
@dynamic appId;
@dynamic type;
@dynamic name;
@dynamic values;
@dynamic defaultValue;
@dynamic isOn;
@dynamic desc;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"AppParamName";
}
@end

@implementation AVOSParamValue
@dynamic value;
@dynamic udid;
@dynamic ver_1;
@dynamic ver_2;
@dynamic ver_3;
@dynamic buildId;
@dynamic desc;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"AppParamValue";
}
@end


@implementation AVOSDevice
@dynamic udid;
@dynamic deviceToken;
@dynamic type;
@dynamic appId;
@dynamic appVersion;
@dynamic deviceName;
@dynamic deviceSystemVersion;
@dynamic deviceType;
@dynamic deviceInfo;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"AppDevice";
}
- (id)init {
    self = [super init];
    if (self) {
        self.udid = [AppConfigManager sharedInstance].udid;
        self.deviceToken = [AppConfigManager sharedInstance].deviceToken;
        self.type = @"ios";
        self.appId = kAppId;
        self.deviceName = [UIDevice currentDevice].name;
        self.deviceSystemVersion = [UIDevice currentDevice].systemVersion;
        self.deviceType = [UIDevice currentDevice].model;
        self.deviceInfo = @"";//暂时不收集其它信息
    }
    return self;
}
+ (void)uploadDeviceInfo {
    NSDate *lastUploadDate = GetCacheObject(@"lastUploadDeviceInfoDate");
    NSInteger intervalMinutes = [kUploadDeviceInfoInterval integerValue];
    if (nil == lastUploadDate) {
        lastUploadDate = [NSDate dateWithMinutesBeforeNow:2 * intervalMinutes];
    }
    NSInteger currentMinutes = [[NSDate date] minutesAfterDate:lastUploadDate];
    if (currentMinutes < intervalMinutes) {
        NSLog(@"pause uploading device info...");
        return;
    }
    //保存设备信息
    AVQuery *query = [AVOSDevice query];
    [query whereKey:@"udid" equalTo:[AppConfigManager sharedInstance].udid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        AVOSDevice *device = nil;
        if ([objects count] > 0) {
            device = objects[0];
        }
        else {
            device = [AVOSDevice new];
        }
        
        if (device && isNotEmpty(device.udid)) {
            device.appVersion = ProductVersion;
            [device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    SaveCacheObject([NSDate date], @"lastUploadDeviceInfoDate");
                }
            }];
        }
    }];
}

@end

//=============================================
//
//  业务模型
//
//=============================================
@implementation ChatUserModel
+ (void)InitChatUserTable {
    NSString *tablesql_ChatUser = @"CREATE TABLE IF NOT EXISTS ChatUser ( \
    userId Varchar(100) PRIMARY KEY, \
    userInfo TEXT DEFAULT NULL)";
    [YSCCommonUtils SqliteUpdate:tablesql_ChatUser dbPath:EZGDATA.cacheDBPath];
}
+ (void)RefreshByUserIds:(NSArray *)userIds ezgoalType:(NSString *)ezgoalType block:(YSCObjectResultBlock)block {
    if (isEmpty(userIds)) {
        if (block) {
            block(nil, CreateNSError(@"传入的userId数组为空"));
        }
        return;
    }
    
    NSString *userType = kAppId;
    if ([EzgoalTypeB2B isEqualToString:ezgoalType] || IsAppTypeC) {
        userType = @"B_EZGoal";
    }
    else {
        userType = @"C_EZGoal";
    }
    
    //调用接口
    [AFNManager getDataFromUrl:kResPathAppCommonUrl
                       withAPI:kResPathGetUserChatInfo
                  andDictParam:@{kParamUserType : userType,
                                 kParamUserIds : [userIds componentsJoinedByString:@","]}
                     modelName:[ChatUserModel class]
              requestSuccessed:^(id responseObject) {
                  NSArray *array = (NSArray *)responseObject;
                  if (isNotEmpty(array)) {
                      for (ChatUserModel *model in array) {
                          [model saveToDB];
                      }
                  }
                  if (block) {
                      block(responseObject, nil);
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    if (block) {
                        block(nil, CreateNSError(errorMessage));
                    }
                }];
}
+ (instancetype)GetLocalDataByUserId:(NSString *)userId {
    FMDatabase *db = [FMDatabase databaseWithPath:EZGDATA.cacheDBPath];
    ChatUserModel *userModel = nil;
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ChatUser WHERE userId = '%@'", Trim(userId)];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next]) {
            NSString *userInfo = Trim([resultSet stringForColumn:@"userInfo"]);
            userModel = [[ChatUserModel alloc] initWithString:userInfo error:nil];
        }
        [resultSet close];
    }
    [db close];
    return userModel;
}
//保存模型至本地数据库
- (void)saveToDB {
    NSString *delSql = [NSString stringWithFormat:@"DELETE FROM ChatUser WHERE userId = '%@'", Trim(self.userId)];
    [YSCCommonUtils SqliteUpdate:delSql dbPath:EZGDATA.cacheDBPath];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO ChatUser(userId,userInfo) VALUES('%@', '%@')",
                     Trim(self.userId), Trim([self toJSONString])];
    [YSCCommonUtils SqliteUpdate:insertSql dbPath:EZGDATA.cacheDBPath];
}
@end