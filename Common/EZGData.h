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

- (id)init;
+ (instancetype)sharedInstance;
- (void)initCarNumberArray;

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
//刷新用户的最近会话列表(分页显示)
- (void)refreshConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block;
- (void)refreshConversationsFromNetworkByUserId:(NSString *)userId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block;
//根据对方id数组查询会话列表
- (void)searchConversationsFromNetworkByOtherIds:(NSArray *)otherIds block:(AVIMArrayResultBlock)block;
//触发消息：打开聊天窗口
- (void)openChatRoomByNotification:(NSNotification *)notification;
//打开会话框
- (void)openChatRoomByPushMessage;
//根据对方id查找会话对象
- (AVIMConversation *)findConversionByOtherUserId:(NSString *)otherUserId;
//删除所有不合法的会话
- (void)deleteInvalidConversations;
//更新conversation的扩展属性
- (void)updateConversation:(AVIMConversation *)conversation byParams:(NSDictionary *)params block:(YSCResultBlock)block;

@end
