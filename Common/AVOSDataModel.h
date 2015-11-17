//
//  AVOSDataModel.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/8.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "AVObject.h"

//在线参数名称
@interface AVOSParamName : AVObject <AVSubclassing>
@property (nonatomic, strong) NSString *appId;          //C_EZGoal  B_EZGoal
@property (nonatomic, strong) NSString *type;           //ios android
@property (nonatomic, strong) NSString *name;           //参数名称
@property (nonatomic, strong) NSArray *values;          //不同版本参数不同
@property (nonatomic, strong) NSString *defaultValue;   //参数默认值
@property (nonatomic, assign) BOOL isOn;                //是否启用在线参数
@property (nonatomic, strong) NSString *desc;           //描述
@end

//在线参数值
@interface AVOSParamValue : AVObject <AVSubclassing>
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *ver_1;
@property (nonatomic, strong) NSString *ver_2;
@property (nonatomic, strong) NSString *ver_3;
@property (nonatomic, strong) NSString *buildId;
@property (nonatomic, strong) NSString *desc;
@end

//设备信息
@interface AVOSDevice : AVObject <AVSubclassing>
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *type;//ios
@property (nonatomic, strong) NSString *appId;//C_EZGoal
@property (nonatomic, strong) NSString *appVersion;//1.2.6 (3)
@property (nonatomic, strong) NSString *deviceName;//xx 的iPhone
@property (nonatomic, strong) NSString *deviceSystemVersion;//7.1.1
@property (nonatomic, strong) NSString *deviceType;//iPhone iPad
@property (nonatomic, strong) NSString *deviceInfo;//扩展模型，缓存其它有用的信息

//上传设备信息
+ (void)uploadDeviceInfo;
@end
