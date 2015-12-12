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

+ (void)addNewParam:(NSString *)name values:(NSArray *)values block:(AVBooleanResultBlock)block;
+ (void)addNewParam:(NSString *)name defaultValue:(NSString *)value block:(AVBooleanResultBlock)block;
+ (void)addNewParam:(NSString *)name defaultValue:(NSString *)value values:(NSArray *)values block:(AVBooleanResultBlock)block;
@end

//在线参数值
@interface AVOSParamValue : AVObject <AVSubclassing>
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *ver1;
@property (nonatomic, strong) NSString *ver2;
@property (nonatomic, strong) NSString *ver3;
@property (nonatomic, strong) NSString *buildId;
@property (nonatomic, strong) NSString *desc;

+ (instancetype)CreateNewParamValue:(NSString *)value;
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid;
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1;
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2;
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2 v3:(NSString *)v3;
+ (instancetype)CreateNewParamValue:(NSString *)value udid:(NSString *)udid v1:(NSString *)v1 v2:(NSString *)v2 v3:(NSString *)v3 buildId:(NSString *)buildId;
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
+ (void)RefreshByUserIds:(NSArray *)userIds ezgoalType:(NSString *)ezgoalType block:(YSCResponseErrorMessageBlock)block;
+ (instancetype)GetLocalDataByUserId:(NSString *)userId;
@end


//=============================================
//
//  百度地图节点模型
//
//=============================================
@interface BMKCustomAnnotation : BMKPointAnnotation
@property (nonatomic, assign) NSInteger type; //0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
@property (nonatomic, assign) NSInteger degree;
@property (nonatomic, strong) NSString *imageName;
@end


