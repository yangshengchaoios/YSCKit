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
+ (void)addNewParam:(NSString *)name values:(NSArray *)values block:(AVBooleanResultBlock)block {
    [self addNewParam:name defaultValue:@"" values:values block:block];
}
+ (void)addNewParam:(NSString *)name defaultValue:(NSString *)value block:(AVBooleanResultBlock)block {
    [self addNewParam:name defaultValue:value values:@[] block:block];
}
+ (void)addNewParam:(NSString *)name defaultValue:(NSString *)value values:(NSArray *)values block:(AVBooleanResultBlock)block {
    AVOSParamName *paramName = [AVOSParamName new];
    paramName.appId = kAppId;
    paramName.type = @"ios";
    paramName.name = name;
    paramName.isOn = YES;
    paramName.values = values;
    paramName.defaultValue = Trim(value);
    [paramName saveInBackgroundWithBlock:block];
}
@end

@implementation AVOSParamValue
@dynamic value;
@dynamic udid;
@dynamic ver1;
@dynamic ver2;
@dynamic ver3;
@dynamic buildId;
@dynamic desc;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"AppParamValue";
}
+ (instancetype)CreateNewParamValue:(NSString *)value {
    return [self CreateNewParamValue:value udid:nil];
}
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid {
    return [self CreateNewParamValue:value udid:udid v1:nil];
}
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 {
    return [self CreateNewParamValue:value udid:udid v1:v1 v2:nil];
}
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2 {
    return [self CreateNewParamValue:value udid:udid v1:v1 v2:v2 v3:nil];
}
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2 v3:(NSString *)v3 {
    return [self CreateNewParamValue:value udid:udid v1:v1 v2:v2 v3:v3 buildId:nil];
}
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2 v3:(NSString *)v3 buildId:(NSString *)buildId {
    AVOSParamValue *newValue = [AVOSParamValue new];
    newValue.value = Trim(value);
    newValue.udid = Trim(udid);
    newValue.ver1 = Trim(v1);
    newValue.ver2 = Trim(v2);
    newValue.ver3 = Trim(v3);
    newValue.buildId = Trim(buildId);
    newValue.desc = @"";
    return newValue;
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
        //NOTE:很奇怪！这里初始化的值能在save中覆盖掉查询回来的值。
    }
    return self;
}
+ (instancetype)CreateNewDevice {
    AVOSDevice *device = [AVOSDevice new];
    device.udid = [AppConfigManager sharedInstance].udid;
    device.deviceToken = [AppConfigManager sharedInstance].deviceToken;
    device.type = @"ios";
    device.appId = kAppId;
    device.appVersion = ProductVersion;
    device.deviceName = [UIDevice currentDevice].name;
    device.deviceSystemVersion = [UIDevice currentDevice].systemVersion;
    device.deviceType = [UIDevice currentDevice].model;
    device.deviceInfo = @"";//暂时不收集其它信息
    return device;
}
+ (void)uploadDeviceInfo {
    NSDate *lastUploadDate = GetCacheObject(@"lastUploadDeviceInfoDate");
    NSInteger intervalMinutes = [kUploadDeviceInfoInterval integerValue];
    if (nil == lastUploadDate) {
        lastUploadDate = [NSDate dateWithMinutesBeforeNow:2 * intervalMinutes];
    }
    NSInteger currentMinutes = [CURRENTDATE minutesAfterDate:lastUploadDate];
    if (currentMinutes < intervalMinutes) {
        NSLog(@"pause uploading device info...");
        return;
    }
    //保存设备信息
    AVQuery *query = [AVOSDevice query];
    [query whereKey:@"udid" equalTo:[AppConfigManager sharedInstance].udid];
    [query whereKey:@"appId" equalTo:kAppId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        AVOSDevice *device = nil;
        if ([objects count] > 0) {
            device = objects[0];
        }
        else {
            device = [AVOSDevice CreateNewDevice];
        }
        
        if (isNotEmpty(device.udid)) {
            device.appVersion = ProductVersion;
            device.deviceName = [UIDevice currentDevice].name;
            [device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    SaveCacheObject(CURRENTDATE, @"lastUploadDeviceInfoDate");
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
+ (void)RefreshByUserIds:(NSArray *)userIds ezgoalType:(NSString *)ezgoalType block:(YSCResponseErrorMessageBlock)block {
    if (isEmpty(userIds)) {
        if (block) {
            block(nil, @"传入的userId数组为空");
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
                     dataModel:[ChatUserModel class]
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
                requestFailure:^(ErrorType errorType, NSError *error) {
                    if (block) {
                        block(nil, [YSCCommonUtils ResolveErrorType:errorType andError:error]);
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
            userModel = [ChatUserModel ObjectWithKeyValues:userInfo];
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
@implementation BMKCustomAnnotation         @end