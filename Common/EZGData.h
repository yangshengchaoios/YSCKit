//
//  EZGData.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/17.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  【翼畅行】C端和B端共享代码——单列对象
 */
@interface EZGData : NSObject
@property (nonatomic, strong) BMKUserLocation *userLocation;
@property (nonatomic, assign) double currentLongitude;          //当前用户的经度104.7(百度地图)
@property (nonatomic, assign) double currentLatitude;           //当前用户的维度30.2(百度地图)
@property (nonatomic, strong) NSMutableArray *carNumberArray;   //车牌二维数组
@property (nonatomic, strong) NSString *cacheDBPath;            //部分业务数据缓存数据库路径

- (id)init;
+ (instancetype)sharedInstance;
- (void)initCarNumberArray;
//删除本地聊天记录
+ (void)clearSpeechData;
//清空本地缓存
+ (void)clearLocalDataByRemoveSdImages:(BOOL)removeSDImages;

#pragma mark - 百度地图
//开启定位
- (void)startLocationService;
//关闭定位
- (void)stopLocationService;
//解析当前GPS坐标成文字信息
- (void)resolveUserLocationWithBlock:(YSCResultBlock)block;
- (void)resolveLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate2D block:(YSCResultBlock)block;
- (void)resolveLocationByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude block:(YSCResultBlock)block;


#pragma mark - LeanCloud
//配置AVOSCloud
+ (void)initAVOSCloud:(NSDictionary *)launchOptions;
//触发消息：连接聊天服务器
- (void)connectToChatServer;
//保存deviceToken
+ (void)saveInstallationWithDeviceToken:(NSData *)deviceTokenData;
//更新_Installation，保证同一个userId只能对应一个deviceToken
- (void)updateInstallationToEnsureUniqueUserId:(NSString *)userId;


//C端需求：1. 所有会话列表
- (void)refreshAllConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block;
//B端需求：1. 普通会话列表
- (void)refreshNormalConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block;
//B端需求：2. 指定某类的业务会话列表
//查询条件ezgoalType: nil-所有会话  empty string-普通会话 not empty string-业务会话
- (void)refreshConversationsByEzgoalType:(NSString *)ezgoalType pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block;


//触发消息：打开聊天窗口
- (void)openChatRoomByNotification:(NSNotification *)notification;
//打开会话框
- (void)openChatRoomByPushMessage;
//根据对方id查找会话对象
- (AVIMConversation *)findConversionByOtherUserId:(NSString *)otherUserId;
//更新conversation的扩展属性
- (void)updateConversation:(AVIMConversation *)conversation byParams:(NSDictionary *)params block:(YSCResultBlock)block;

@end
