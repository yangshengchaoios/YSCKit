//
//  EZGData.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/17.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGData.h"
#import "AVIMConversation+Custom.h"
#import "CDConversationStore.h"
#import "EZGChatRoomViewController.h"
#import "EZGRescueChatRoomViewController.h"
#import "ServerTimeSynchronizer.h"
#import "SDImageCache.h"

@interface EZGData () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (nonatomic, strong) BMKLocationService *locationService;  //后台定位服务
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;      //后台GPS坐标解析(成文字信息)
@property (nonatomic, copy) YSCResultBlock geoCodeResultBlock;      //GPS解析结果回调
@property (nonatomic, assign) BOOL isGeoCodeResolving;              //是否正在进行GPS解析
@end

@implementation EZGData

- (void)dealloc {
    removeAllObservers(self);
}
- (id)init {
    if (self = [super init]) {
        //0. 初始化属性
        if (IsAppTypeB) {
            self.normalConvTypeArray = @[EzgoalTypeB2B, EzgoalTypeB2C, EzgoalTypeC2B];
        }
        else {
            self.normalConvTypeArray = @[EzgoalTypeB2C, EzgoalTypeC2B, EzgoalTypeC2C];
        }
        //1. 注册通知：其它任何地方都可以通过发送通知进入聊天界面
        addNObserver(@selector(openChatRoomByNotification:), kNotificationOpenChatRoom);
        //2. 同步服务器时间
        [ServerTimeSynchronizer sharedInstance];
        //3. 拦截消息到达通知
        addNObserver(@selector(messageReceived:), kCDNotificationMessageReceived);
    }
    return self;
}
+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}
- (void)initCarNumberArray {
    if (nil == self.carNumberArray) {
        self.carNumberArray = [NSMutableArray array];
    }
    if ([NSArray isNotEmpty:self.carNumberArray]) {
        return;
    }
    //初始化车牌号选择器
    [self.carNumberArray addObject:@[@"川"]];
    [self.carNumberArray addObject:@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"]];
    for (int i = 0; i < 5; i++) {
        [self.carNumberArray addObject:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"]];
    }
}
- (NSString *)cacheDBPath {
    NSString *dbName = [NSString stringWithFormat:@"ezgoal_cache_%@.sqlite", USERID];
    return [[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:dbName];
}
//删除本地聊天记录
+ (void)clearSpeechData {
    [YSCFileUtils deleteFileOrDirectory:[[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:@"speech_stat.sqlite"]];
    [YSCFileUtils deleteFileOrDirectory:[[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:@"speech_stat.sqlite-shm"]];
    [YSCFileUtils deleteFileOrDirectory:[[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:@"speech_stat.sqlite-wal"]];
}
//清空本地缓存
+ (void)clearLocalDataByRemoveSdImages:(BOOL)removeSDImages {
    if (removeSDImages) {
        //1.删除SDImage的缓存数据
        while ([SDImageCache sharedImageCache].getSize != 0 || [SDImageCache sharedImageCache].getDiskCount != 0) {
            [[SDImageCache sharedImageCache] clearDisk];
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] cleanDisk];
        }
    }
    
    //2.清除目录 "Library/Caches/" 下的缓存数据
    [[StorageManager sharedInstance] clearLibraryCaches];
    
    //3.移除所有的本地网络请求的缓存数据
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

//====================================
//
// 百度地图
//
//====================================
//开启定位
- (void)startLocationService {
    if (nil == self.locationService) {
        self.locationService = [[BMKLocationService alloc] init];
        self.locationService.delegate = self;
    }
    
    if ([UIDevice isLocationAvaible]) {
        [self.locationService startUserLocationService];
    }
    else {
        self.currentLatitude = 0;
        self.currentLongitude = 0;
        self.userLocation = nil;
    }
}
//关闭定位
- (void)stopLocationService {
    if (self.locationService) {
        [self.locationService stopUserLocationService];
        self.locationService.delegate = nil;
        self.locationService = nil;
    }
}
//解析当前GPS坐标成文字信息
- (void)resolveUserLocationWithBlock:(YSCResultBlock)block {
    if (self.userLocation) {
        [self resolveLocationByLatitude:self.currentLatitude longitude:self.currentLongitude block:block];
    }
    else {
        if (block) {
            block(nil);
        }
    }
}
- (void)resolveLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate2D block:(YSCResultBlock)block {
    [self resolveLocationByLatitude:locationCoordinate2D.latitude longitude:locationCoordinate2D.longitude block:block];
}
- (void)resolveLocationByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude block:(YSCResultBlock)block {
    if (0 == latitude || 0 == longitude) {
        if (block) {
            block(nil);
        }
    }
    else {
        if (self.isGeoCodeResolving) {//防止重复解析
            return;
        }
        self.isGeoCodeResolving = YES;
        
        self.geoCodeResultBlock = block;//暂存block
        if (nil == self.geoCodeSearch) {
            self.geoCodeSearch = [BMKGeoCodeSearch new];
            self.geoCodeSearch.delegate = self;
        }
        //开始解析
        BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeocodeSearchOption.reverseGeoPoint = CLLocationCoordinate2DMake(latitude, longitude);
        [self.geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    }
}
#pragma mark - BMKGeoCodeSearchDelegate
//返回反地理编码搜索结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    self.isGeoCodeResolving = NO;
    if (BMK_SEARCH_NO_ERROR == error) {
        if (self.geoCodeResultBlock) {
            self.geoCodeResultBlock(result);
        }
    }
    else {
        if (self.geoCodeResultBlock) {
            self.geoCodeResultBlock(nil);
        }
    }
}
#pragma mark - BMKLocationServiceDelegate
//在地图View将要启动定位时，会调用此函数
- (void)willStartLocatingUser {
    NSLog(@"start locating user");
}
//用户方向更新后，会调用此函数
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    self.userLocation = userLocation;
    self.currentLatitude = userLocation.location.coordinate.latitude;
    self.currentLongitude = userLocation.location.coordinate.longitude;
}
//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    self.userLocation = userLocation;
    self.currentLatitude = userLocation.location.coordinate.latitude;
    self.currentLongitude = userLocation.location.coordinate.longitude;
}
//在地图View停止定位后，会调用此函数
- (void)didStopLocatingUser {
    NSLog(@"stop locating user!");
}
//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error:%@",error);
    self.userLocation = nil;
    self.currentLatitude = 0;
    self.currentLongitude = 0;
}


//====================================
//
// LeanCloud
//
//====================================
//初始化AVOSCloud
+ (void)initAVOSCloud:(NSDictionary *)launchOptions {
    if (DEBUGMODEL) {
        [AVOSCloud setAllLogsEnabled:YES];
        [AVOSCloud setApplicationId:AVOSCloudAppID_TEST clientKey:AVOSCloudAppKey_TEST];
    }
    else {
        [AVOSCloud setApplicationId:AVOSCloudAppID clientKey:AVOSCloudAppKey];
    }
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //注册IM用户登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:EZGDATA
                                             selector:@selector(connectToChatServer)
                                                 name:kNotificationConnectToChatServer
                                               object:nil];
}
//触发消息：连接聊天服务器
- (void)connectToChatServer {
    if (isEmpty(USERID)) {
        return;
    }
    [[CDChatManager manager] openWithClientId:USERID callback:^(BOOL succeeded, NSError *error) {
        if (nil == error) {
            postN(kCDNotificationUnreadsUpdated);//重新计算未读数
        }
        //刷新最近N条会话列表，目的是方便关闭进程的APP从推送栏点击推送消息进入，打开聊天窗口更快速
        if (NO == [[CDConversationStore store] isConversationExists]) {
            [EZGDATA refreshAllConversationsByPageIndex:kDefaultPageStartIndex pageSize:kDefaultConversationPageSize block:nil];
        }
    }];
    [AppData synchronizeDeviceTokenWithUser];
}
//保存deviceToken
+ (void)saveInstallationWithDeviceToken:(NSData *)deviceTokenData {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceTokenData];
    currentInstallation.deviceProfile = [EZGManager deviceProfile];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"save installation successed!");
        }
        else {
            NSLog(@"save installation error:%@", error);
        }
    }];
}
//添加新的deviceToken
- (void)addNewDeviceToken:(NSString *)deviceToken {
    ReturnWhenObjectIsEmpty(deviceToken);
    AVObject *post = [AVObject objectWithClassName:@"_Installation"];
    [post setObject:deviceToken forKey:@"deviceToken"];
    [post setObject:@"Asia/Shanghai" forKey:@"timeZone"];
    [post setObject:@(0) forKey:@"badge"];
    if (isNotEmpty(USERID)) {
        [post setObject:@[USERID] forKey:@"channels"];
    }
    else {
        [post setObject:@[] forKey:@"channels"];
    }
    [post setObject:@"ios" forKey:@"deviceType"];
    [post setObject:[EZGManager deviceProfile] forKey:@"deviceProfile"];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"save device:[%d], error:%@", succeeded, error);
    }];
}
//更新_Installation，保证同一个userId只能对应一个deviceToken
+ (void)updateInstallationToEnsureUniqueUserId:(NSString *)userId {
    NSString *deviceToken = [AppConfigManager sharedInstance].deviceToken;
    ReturnWhenObjectIsEmpty(userId);
    ReturnWhenObjectIsEmpty(deviceToken);
    AVQuery *query = [AVQuery queryWithClassName:@"_Installation"];
    [query whereKey:@"channels" containsString:userId];
    [query whereKey:@"deviceToken" notEqualTo:deviceToken];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (isEmpty(error)) {
            for (AVObject *object in objects) {
                NSMutableArray *tempArray = [[object objectForKey:@"channels"] mutableCopy];
                [tempArray removeObject:userId];
                [object setObject:tempArray forKey:@"channels"];
                [object setObject:@(0) forKey:@"badge"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"delete successed");
                    }
                    else {
                        NSLog(@"delete faild:%@", error);
                    }
                }];
            }
        }
        else {
            NSLog(@"error:%@", error);
        }
    }];
}
//更新在线参数
+ (void)updateOnlineParams {
    [AVCloud callFunctionInBackground:@"GetAppParams"
                       withParameters:@{@"appId"    : Trim(kAppId),
                                        @"type"     : @"ios",
                                        @"udid"     : Trim([AppConfigManager sharedInstance].udid),
                                        @"version"  : Trim(AppVersion),
                                        @"buildId"  : Trim(BundleVersion)}
                                block:^(id object, NSError *error) {
                                    NSLog(@"online params:%@", object);
                                    if (isEmpty(error)) {
                                        NSDictionary *oldParams = GetObjectByFile(@"AppParams", @"OnLineParams");
                                        NSString *oldSign = [AppData SignatureWithParams:oldParams];
                                        NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
                                        NSString *newSign = @"";
                                        if ([object isKindOfClass:[NSDictionary class]]) {
                                            [newParams addEntriesFromDictionary:(NSDictionary *)object];
                                            newSign = [AppData SignatureWithParams:newParams];
                                        }
                                        //检测是否有参数变更
                                        if (NO == [oldSign isEqualToString:newSign]) {
                                            SaveObjectByFile(newParams, @"AppParams", @"OnLineParams");
                                            [[AppConfigManager sharedInstance] resetAppParams];
                                            postN(kNotificationRefreshHome);
                                        }
                                    }
                                    else {
                                        NSLog(@"get online params error:%@", error);
                                    }
                                }];
}

//C端需求：1. 所有会话列表
- (void)refreshAllConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block {
    [self refreshConversationsByEzgoalType:nil pageIndex:pageIndex pageSize:pageSize block:block];
}
//B端需求：1. 普通会话列表
- (void)refreshNormalConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block {
    [self refreshConversationsByEzgoalType:@"" pageIndex:pageIndex pageSize:pageSize block:block];
}
//B端需求：2. 指定某类的业务会话列表
//查询条件ezgoalType: nil-所有会话  empty string-普通会话 not empty string-业务会话
- (void)refreshConversationsByEzgoalType:(NSString *)ezgoalType pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block {
    AVIMConversationQuery *query = [[AVIMClient defaultClient] conversationQuery];
    query.cachePolicy = kAVCachePolicyNetworkOnly;
    [query orderByDescending:@"lm"];
    [query whereKey:kAVIMKeyMember containedIn:@[USERID]];
    [query whereKey:kAVIMKeyMember sizeEqualTo:2];
    if (isNotEmpty(ezgoalType)) {
        [query whereKey:AVIMAttr(kParamEzgoalType) equalTo:Trim(ezgoalType)];
        [query whereKey:AVIMAttr(kParamS4Id) equalTo:S4ID];
    }
    else if (nil != ezgoalType) {
        [query whereKey:AVIMAttr(kParamEzgoalType) containedIn:EZGDATA.normalConvTypeArray];
    }
    else {
        //查询所有会话
    }
    query.skip = MAX(0, pageIndex - 1) * pageSize;
    query.limit = pageSize;
    [self searchByConversationQuery:query block:block];
}
//处理查询回来的会话列表
- (void)searchByConversationQuery:(AVIMConversationQuery *)query block:(AVIMArrayResultBlock)block {
    [query findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        if (isEmpty(error)) {
            if (isNotEmpty(objects)) {
                [[CDConversationStore store] updateConversations:objects];
                postN(kCDNotificationUnreadsUpdated);
            }
        }
        if (block) {
            block(objects, error);
        }
    }];
}

//触发消息：打开聊天窗口
//自动判断普通会话与特殊会话类型
//userInfo中只需要传入五个参数：kParamOtherId、kParamRescueId、kParamConversationId、kParamChatRoom(dict)、kParamExtendAttributes(dict)
- (void)openChatRoomByNotification:(NSNotification *)notification {
    [self resetClicked];
    NSDictionary *userInfo = notification.userInfo;
    //0. 组装chatRoom的参数
    NSMutableDictionary *paramsChatRoom = [NSMutableDictionary dictionaryWithDictionary:userInfo[kParamChatRoom]];
    if (nil == paramsChatRoom[kParamIsPush]) {
        paramsChatRoom[kParamIsPush] = @(YES);//默认打开聊天窗口是push方式
    }
    //1. 优先根据conversationId查找会话对象
    AVIMConversation *conversation = nil;
    if (isNotEmpty(userInfo[kParamConversationId])) {
        //根据conversationId查找本地会话
        conversation = [[CDConversationStore store] selectOneConversationByConvId:Trim(userInfo[kParamConversationId])];
        
        if (conversation) {//找到了本地会话
            [self openChatRoomByConversion:conversation byParams:paramsChatRoom];
        }
        else {//根据conversationId查找网络会话
            [[CDChatManager manager] fetchConvWithConvid:Trim(userInfo[kParamConversationId]) callback:^(AVIMConversation *conversation, NSError *error) {
                if (conversation) {
                    [EZGDATA openChatRoomByConversion:conversation byParams:paramsChatRoom];
                }
                else {
                    [UIView showResultThenHideOnWindow:@"查询会话出错"];
                }
            }];
        }
    }
    //2. 根据rescueId查找会话对象
    else if (isNotEmpty(userInfo[kParamRescueId])) {
        //根据rescueId查找本地会话
        conversation = [[CDConversationStore store] selectOneConversationByRescueId:Trim(userInfo[kParamRescueId])];
        
        if (conversation) {//找到了本地会话
            [self openChatRoomByConversion:conversation byParams:paramsChatRoom];
        }
        else {//根据rescueId查找网络会话
            AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
            q.cachePolicy = kAVCachePolicyNetworkOnly;
            [q whereKey:AVIMAttr(kParamRescueId) equalTo:userInfo[kParamRescueId]];
            [q findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
                AVIMConversation *conversation = nil;
                if (isNotEmpty(objects)) {
                    conversation = objects[0];
                }
                if (conversation) {
                    [EZGDATA openChatRoomByConversion:conversation byParams:paramsChatRoom];
                }
                else {
                    if (isEmpty(error)) {
                        //如果是之前创建会话失败，可以自动再次创建救援会话
                        if (isNotEmpty(userInfo[kParamOtherId]) &&
                            isNotEmpty(userInfo[kParamChatRoom]) &&
                            isNotEmpty(userInfo[kParamExtendAttributes])) {
                            NSDictionary *params = @{kParamOtherId  : Trim(userInfo[kParamOtherId]),
                                                     kParamChatRoom : userInfo[kParamChatRoom],
                                                     kParamExtendAttributes : userInfo[kParamExtendAttributes]};
                            postNWithInfo(kNotificationOpenChatRoom, params);
                        }
                        else {
                            NSLog(@"救援会话不存在");
                            [UIView showAlertVieWithMessage:@"救援会话不存在"];
                        }
                    }
                    else {
                        postN(kNotificationConnectToChatServer);
                        NSLog(@"查询救援会话出错:%@", error);
                        [UIView showAlertVieWithMessage:@"查询救援会话出错"];
                    }
                }
            }];
        }
    }
    //3. 根据附加条件创建会话
    else {
        NSDictionary *extendAttributes = userInfo[kParamExtendAttributes];
        //如果是普通会话，则根据对方id查找本地缓存的会话
        if ([EZGManager checkConversationIsNormal:extendAttributes[kParamEzgoalType]]) {
            NSArray *tempArray = [[CDConversationStore store] selectAllConversations];
            for (AVIMConversation *conv in tempArray) {
                if ([conv.otherId isEqualToString:userInfo[kParamOtherId]] &&
                    [EZGManager checkConversationIsNormal:conv.ezgoalType]) {
                    conversation = conv;
                    break;
                }
            }
        }
        
        //组装会话人列表
        NSArray *members = @[Trim(userInfo[kParamOtherId]), USERID];
        [self openChatRoomByConversion:conversation byParams:paramsChatRoom members:members attributes:userInfo[kParamExtendAttributes]];
    }
}
//如果有会话对象就直接打开对话框
//如果没有就新建会话对象
- (void)openChatRoomByConversion:(AVIMConversation *)conversation byParams:(NSDictionary *)params members:(NSArray *)members attributes:(NSDictionary *)attributes {
    if (conversation) {
        [self openChatRoomByConversion:conversation byParams:params];
    }
    else {
        [[CDChatManager manager] fetchConvWithMembers:members
                                     extendAttributes:attributes
                                             callback:^(AVIMConversation *conversation, NSError *error) {
                                                 if (error) {//两种错误：查询出错；创建出错
                                                     NSString *errMsg = [NSString stringWithFormat:@"fetchConvWithMembers:%@ attributes:%@ error:%@",members, attributes, error];
                                                     NSLog(@"建立会话失败：%@", errMsg);
                                                     [UIView showAlertVieWithMessage:@"建立会话失败，请检查网络连接！"];
                                                 }
                                                 else {// 跳转到 ChatView 页面进行聊天
                                                     [[CDConversationStore store] updateConversation:conversation];
                                                     [EZGDATA openChatRoomByConversion:conversation byParams:params];
                                                 }
                                             }];
    }
}
//根据推送的message打开会话框
- (void)openChatRoomByPushMessage {
    if (ISNOTLOGGED || isEmpty([CDChatManager manager].remoteNotificationConvid)) {
        return;
    }
    NSString *convId = Trim([CDChatManager manager].remoteNotificationConvid);
    [CDChatManager manager].remoteNotificationConvid = nil;//一旦取值后就清空
    //根据convId在本地缓存查找会话对象
    AVIMConversation *conversation = [[CDConversationStore store] selectOneConversationByConvId:convId];
    NSDictionary *params = @{kParamIsPush : @(NO)};
    if (conversation) {
        [self openChatRoomByConversion:conversation byParams:params];
    }
    else {
        [self bk_performBlock:^(id obj) {//延迟1.5秒居然可以解决下面的问题！
            [[CDChatManager manager] fetchConvWithConvid:convId callback:^(AVIMConversation *conversation, NSError *error) {
                if (conversation) {
                    [EZGDATA openChatRoomByConversion:conversation byParams:params];
                }
                else {
                    [EZGDATA resetClicked];
                }
            }];
        } afterDelay:1.5];
    }
}
//统一入口：进入聊天对话界面
- (void)openChatRoomByConversion:(AVIMConversation *)conversation byParams:(NSDictionary *)params {
    ReturnWhenObjectIsEmpty(conversation);
    UIViewController *currentViewController = [AppConfigManager sharedInstance].currentViewController;
    ReturnWhenObjectIsEmpty(currentViewController);
    if ([currentViewController isKindOfClass:NSClassFromString(@"CDChatRoomVC")]) {//如果处于聊天界面，但不是即将打开的会话，则需要先关闭再打开
        if (NO == [conversation.conversationId isEqualToString:[CDChatManager manager].chattingConversationId]) {
            CDChatRoomVC *chatRoom = (CDChatRoomVC *)currentViewController;
            [chatRoom closeCurrentViewControllerAnimated:NO block:^{
                [EZGDATA openChatRoomByConversion:conversation byParams:params];
            }];
        }
    }
    else if ([currentViewController isKindOfClass:NSClassFromString(@"EZGFastRescueViewController")]) {//需要关闭快速救援入口窗口
        [currentViewController.navigationController dismissViewControllerAnimated:NO completion:^{
            [EZGDATA openChatRoomByConversion:conversation byParams:params];
        }];
    }
    else {//进入聊天会话窗口
        CDChatRoomVC *chatRoom = nil;
        if ([EZGManager checkConversationIsNormal:conversation.ezgoalType]) {//进入普通会话窗口
            chatRoom = [[EZGChatRoomViewController alloc] initWithConv:conversation];
        }
        else {//进入特殊会话窗口
            chatRoom = [[EZGRescueChatRoomViewController alloc] initWithConv:conversation];
        }
        chatRoom.params = params;
        chatRoom.hidesBottomBarWhenPushed = YES;
        if ([params[kParamIsPush] boolValue]) {
            [currentViewController.navigationController pushViewController:chatRoom animated:YES];
        }
        else {
            [currentViewController presentViewController:[UIResponder createNavigationControllerWithRootViewController:chatRoom]
                                                animated:YES completion:nil];
        }
    }
}


//NOTE:关闭防重复点击的开关
- (void)resetClicked {
    YSCBaseViewController *currentVC = (YSCBaseViewController *)[AppConfigManager sharedInstance].currentViewController;
    if ([currentVC isKindOfClass:[YSCBaseViewController class]]) {
        currentVC.isClicked = NO;
    }
}
//根据对方id查找会话对象
- (AVIMConversation *)findConversionByOtherUserId:(NSString *)otherUserId {
    AVIMConversation *conversation = nil;
    NSArray *tempArray = [[CDConversationStore store] selectAllConversations];
    for (AVIMConversation *con in tempArray) {
        if ([otherUserId isEqualToString:con.otherId]) {
            conversation = con;
            break;
        }
    }
    return conversation;
}
//更新conversation的扩展属性(默认是发送消息调用)
- (void)updateConversation:(AVIMConversation *)conv byParams:(NSDictionary *)params block:(YSCResultBlock)block {
    [self updateConversation:conv byParams:params refreshOnly:NO block:block];
}
- (void)updateConversation:(AVIMConversation *)conv byParams:(NSDictionary *)params refreshOnly:(BOOL)refreshOnly block:(YSCResultBlock)block {
    if (isEmpty(conv.conversationId)) {
        if (block) {
            block(@"conversation is empty");
        }
        return;
    }
    if (isEmpty(params)) {
        if (block) {
            block(@"params is empty");
        }
        return;
    }
    if (refreshOnly) {//接受消息仅仅刷新会话
        AVIMConversationQuery *query = [[AVIMClient defaultClient] conversationQuery];
        query.cachePolicy = kAVCachePolicyNetworkOnly;
        [query getConversationById:conv.conversationId callback:^(AVIMConversation *conversation, NSError *error) {
            NSLog(@"conv.attr1=%@", conversation.attributes);
            if (isEmpty(error)) {
                [[CDConversationStore store] updateConversation:conversation];
                if (block) {
                    block(nil);
                }
            }
            else {
                if (block) {
                    block(error);
                }
            }
        }];
    }
    else {//发送消息时需要更新会话扩展属性
        AVIMConversationUpdateBuilder *updateBuilder = [conv newUpdateBuilder];
        updateBuilder.attributes = conv.attributes;
        for (NSString *paramKey in params.allKeys) {
            [updateBuilder setObject:params[paramKey] forKey:paramKey];
        }
        [conv update:[updateBuilder dictionary] callback:^(BOOL succeeded, NSError *error) {
            NSLog(@"conv.attr2=%@", conv.attributes);
            [[CDConversationStore store] updateConversation:conv];
            if (block) {
                block(error);
            }
        }];
    }
}
//拦截消息到达通知
- (void)messageReceived:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ( ! [message isKindOfClass:[AVIMTypedMessage class]] || message.mediaType < EZGMessageTypeScene) {
        postN(kNotificationRefreshMessageCenter);//刷新消息中心
        return;
    }
    
    //特殊类型的消息(发出之前需要先修改救援任务状态)
    if (EZGMessageTypeServiceCancel == message.mediaType ||
        EZGMessageTypeServiceComment == message.mediaType ||
        EZGMessageTypeService == message.mediaType) {
        RescueStatusType rescueStatus = [message.attributes[kParamEzgoalStatus] integerValue];
        AVIMConversation *conv = [[CDConversationStore store] selectOneConversationByConvId:message.conversationId];
        //更新本地救援模型
        if ([conv.rescueId isEqualToString:APPDATA.rescueModel.rescueId]) {
            APPDATA.rescueModel.rescueStatus = rescueStatus;
            SaveObjectByFile(APPDATA.rescueModel, kCachedRescueModel, kParamAppModel);
        }
        //更新conversation
        [EZGDATA updateConversation:conv byParams:@{kParamEzgoalStatus : @(rescueStatus)} refreshOnly:YES block:^(NSObject *object) {
            postN(kNotificationRefreshMessageCenter);//刷新消息中心
            postN(kNotificationRefreshConvStatus);//通知会话页面，报告conv的状态已经更新了
        }];
        //B端接收到系统结束救援的消息、以及C端未开始就取消救援的消息、C端恢复救援的消息 就刷新救援列表
        if (RescueStatusTypeCancelBySystem == rescueStatus ||
            RescueStatusTypeCancelByB == rescueStatus ||
            RescueStatusTypeCancelByC0 == rescueStatus ||
            RescueStatusTypeUnProcess == rescueStatus) {
            YSCBaseViewController *currentVC = (YSCBaseViewController *)[AppConfigManager sharedInstance].currentViewController;
            if (RescueStatusTypeCancelBySystem == rescueStatus &&
                ([currentVC isKindOfClass:NSClassFromString(@"EZGGiveUpCancelViewController")] ||
                [currentVC isKindOfClass:NSClassFromString(@"EZGAgreeCancelRescueViewController")])) {
                [currentVC backViewController];
            }
            postN(kNotificationRefreshRescueList);
        }
    }
    else {
        postN(kNotificationRefreshMessageCenter);//刷新消息中心
    }
}
@end
