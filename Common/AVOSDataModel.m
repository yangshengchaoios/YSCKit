//
//  AVOSDataModel.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/8.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "AVOSDataModel.h"

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
    if (1 != [kUploadDeviceInfo integerValue]) {
        return;
    }
    
    //TODO:改为间隔时间
    
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
                
            }];
        }
    }];
}

@end