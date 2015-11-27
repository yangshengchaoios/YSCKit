//
//  EZGDataModel.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/8.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "AVObject.h"

@protocol ChatUserModel               @end

//=============================================
//
//  AVOS在线参数模型
//
//=============================================
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



//=============================================
//
//  业务模型
//
//=============================================
//聊天对象里的用户模型
@interface ChatUserModel : BaseDataModel
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSNumber *commentScore;
//重新查询B端用户信息
+ (void)InitChatUserTable;
+ (void)RefreshByUserIds:(NSArray *)userIds ezgoalType:(NSString *)ezgoalType block:(YSCObjectResultBlock)block;
+ (instancetype)GetLocalDataByUserId:(NSString *)userId;
@end