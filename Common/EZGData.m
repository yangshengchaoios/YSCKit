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

@interface EZGData () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (nonatomic, strong) BMKLocationService *locationService;  //后台定位服务
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;      //后台GPS坐标解析(成文字信息)
@property (nonatomic, copy) YSCResultBlock geoCodeResultBlock;      //GPS解析结果回调
@property (nonatomic, assign) BOOL isGeoCodeResolving;              //是否正在进行GPS解析

@property (nonatomic, assign) BOOL isChecking;                      //是否正在监测登陆状态
@property (nonatomic, assign) BOOL isNeedCheckLogin;                //是否需要监测登陆状态
@end

@implementation EZGData

- (void)dealloc {
    removeAllObservers(self);
}
- (id)init {
    if (self = [super init]) {
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
    
    //注册IM用户登陆的通知
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
            [EZGDATA refreshConversationsByPageIndex:kDefaultPageStartIndex pageSize:20 block:nil];
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
            NSLog(@"succed");
        }
        else {
            NSLog(@"error:%@", error);
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
- (void)updateInstallationToEnsureUniqueUserId:(NSString *)userId {
    NSString *deviceToken = [AppConfigManager sharedInstance].deviceToken;
    NSLog(@"deviceToken2=%@", deviceToken);
    ReturnWhenObjectIsEmpty(userId);
    ReturnWhenObjectIsEmpty(deviceToken);
    AVQuery *query = [AVQuery queryWithClassName:@"_Installation"];
    [query whereKey:@"channels" containsString:userId];
    [query whereKey:@"deviceToken" notEqualTo:deviceToken];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (isEmpty(error)) {
            for (AVObject *object in objects) {
                NSLog(@"convId:%@", object.objectId);
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


//刷新用户最近的所有会话列表
- (void)refreshConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block {
    [self refreshConversationsByEzgoalType:nil pageIndex:pageIndex pageSize:pageSize block:block];
}
//刷新用户最近的特殊会话列表
- (void)refreshConversationsByEzgoalType:(NSString *)ezgoalType pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize block:(AVIMArrayResultBlock)block {
    AVIMConversationQuery *query = [[AVIMClient defaultClient] conversationQuery];
    query.cachePolicy = kAVCachePolicyNetworkOnly;
    [query orderByDescending:@"lm"];
    [query whereKey:AVIMAttr(CONV_TYPE) equalTo:@(CDConvTypeSingle)];
    [query whereKey:kAVIMKeyMember containedIn:@[USERID]];
    [query whereKey:kAVIMKeyMember sizeEqualTo:2];
    
    //查询条件ezgoalType: nil-所有会话  empty-普通会话 notempty-特殊会话
    if (isNotEmpty(ezgoalType)) {
        [query whereKey:AVIMAttr(kParamEzgoalType) equalTo:Trim(ezgoalType)];
        [query whereKey:AVIMAttr(kParamS4Id) equalTo:S4ID];
        if ([EzgoalTypeRescue isEqualToString:ezgoalType]) {//查询有效的救援会话
            [query whereKey:AVIMAttr(kParamEzgoalStatus) containedIn:@[@(RescueStatusTypeUnProcess),
                                                                       @(RescueStatusTypeProcessing),
                                                                       @(RescueStatusTypeCancelByC)]];
        }
        else if ([EzgoalTypeReservation isEqualToString:ezgoalType]) {//查询有效的预约会话
            //TODO:
        }
    }
    else if (nil != ezgoalType) {//只查询普通会话
        [query whereKey:AVIMAttr(kParamEzgoalType) equalTo:@""];
    }
    query.skip = MAX(0, pageIndex - 1) * pageSize;
    query.limit = pageSize;
    [self searchByConversationQuery:query block:block];
}
//根据对方id数组查询会话列表
- (void)searchConversationsFromNetworkByOtherIds:(NSArray *)otherIds block:(AVIMArrayResultBlock)block {
    NSString *creatorId = USERID;
    ReturnWhenObjectIsEmpty(creatorId);
    ReturnWhenObjectIsEmpty(otherIds); //未登录不能查询
    AVIMConversationQuery *query = [[AVIMClient defaultClient] conversationQuery];
    query.cachePolicy = kAVCachePolicyNetworkOnly;
    [query whereKey:AVIMAttr(CONV_TYPE) equalTo:@(CDConvTypeSingle)];
    [query whereKey:kAVIMKeyMember sizeEqualTo:2];
    [query whereKey:kAVIMKeyCreator equalTo:creatorId];
    [query whereKey:kAVIMKeyMember containedIn:otherIds];
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
            [[CDChatManager manager] fecthConvWithConvid:Trim(userInfo[kParamConversationId]) callback:^(AVIMConversation *conversation, NSError *error) {
                if (error) {
                    conversation = nil;
                }
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
                if (isEmpty(error) && objects.count > 0) {
                    conversation = objects[0];
                }
                if (conversation) {
                    [EZGDATA openChatRoomByConversion:conversation byParams:paramsChatRoom];
                }
                else {
                    if (isEmpty(error)) {//如果是之前创建会话失败，可以自动再次创建救援会话
                        NSDictionary *params = @{kParamOtherId  : Trim(userInfo[kParamOtherId]),
                                                 kParamChatRoom : userInfo[kParamChatRoom],
                                                 kParamExtendAttributes : userInfo[kParamExtendAttributes]};
                        postNWithInfo(kNotificationOpenChatRoom, params);
                    }
                    else {
                        NSString *errMsg = [NSString stringWithFormat:@"查询救援会话出错：%@", error];
                        [LogManager saveLog:errMsg];
                        NSLog(@"err:%@", errMsg);
                        [UIView showResultThenHideOnWindow:@"查询救援会话出错"];
                        [AppData resetRescueModel:nil];
                    }
                }
            }];
        }
    }
    //3. 根据附加条件创建会话
    else {
        NSDictionary *extendAttributes = userInfo[kParamExtendAttributes];
        //如果是普通会话，则根据对方id查找本地缓存的会话
        if (nil == extendAttributes[kParamEzgoalType]) {
            NSArray *tempArray = [[CDConversationStore store] selectAllConversations];
            for (AVIMConversation *conv in tempArray) {
                if ([conv.otherId isEqualToString:userInfo[kParamOtherId]] &&
                    isEmpty(conv.ezgoalType)) {
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
                                                 type:CDConvTypeSingle
                                     extendAttributes:attributes
                                             callback:^(AVIMConversation *conversation, NSError *error) {
                                                 if (error) {//两种错误：查询出错；创建出错
                                                     NSLog(@"connect to LeanCloudIM server error:%@", error);
                                                     NSString *errMsg = [NSString stringWithFormat:@"fetchConvWithMembers:%@ attributes:%@ error:%@",members, attributes, error];
                                                     [LogManager saveLog:errMsg];
                                                     NSLog(@"建立会话失败：%@", errMsg);
                                                     [UIView showAlertVieWithMessage:@"建立会话失败，请检查网络连接！"];
                                                 }
                                                 else {// 跳转到 ChatView 页面进行聊天
                                                     [[CDConversationStore store] updateConversation:conversation];//将会话保存在本地
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
            [[CDChatManager manager] fecthConvWithConvid:convId callback:^(AVIMConversation *conversation, NSError *error) {
                if (error) {
                    [EZGDATA resetClicked];
                    //TODO:偶尔会出现刚创建的会话不能根据convId查询的情况！暂时屏蔽错误提示！
                    //                    NSString *errMsg = [NSString stringWithFormat:@"fecthConvWithConvid:%@ error:%@", convId, error];
                    //                    [UIView showAlertVieWithMessage:errMsg];
                }
                else {
                    [EZGDATA openChatRoomByConversion:conversation byParams:params];
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
                [EZGDATA bk_performBlock:^(id obj) {//TODO:test
                    [EZGDATA openChatRoomByConversion:conversation byParams:params];
                } afterDelay:1];
            }];
        }
    }
    else if ([currentViewController isKindOfClass:NSClassFromString(@"EZGFastRescueViewController")]) {//需要关闭快速救援入口窗口
        [currentViewController.navigationController dismissViewControllerAnimated:NO completion:^{
            [EZGDATA bk_performBlock:^(id obj) {
                [EZGDATA openChatRoomByConversion:conversation byParams:params];
            } afterDelay:1];
        }];
    }
    else {//进入聊天会话窗口
        CDChatRoomVC *chatRoom = nil;
        if (isNotEmpty(conversation.ezgoalType)) {//进入特殊会话窗口
            chatRoom = [[EZGRescueChatRoomViewController alloc] initWithConv:conversation];
        }
        else {//进入普通会话窗口
            chatRoom = [[EZGChatRoomViewController alloc] initWithConv:conversation];
        }
        chatRoom.params = params;
        if ([params[kParamIsPush] boolValue]) {
            chatRoom.hidesBottomBarWhenPushed = YES;
            [currentViewController.navigationController pushViewController:chatRoom animated:YES];
        }
        else {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatRoom];
            [currentViewController presentViewController:navigationController animated:YES completion:nil];
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
//删除所有不合法的会话
- (void)deleteInvalidConversations {
    AVQuery *query = [AVQuery queryWithClassName:@"_Conversation"];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (isEmpty(error)) {
            for (AVObject *conv in objects) {
                NSLog(@"convId:%@", conv.objectId);
                NSDictionary *attr = [conv objectForKey:@"attr"];
                NSArray *members = [conv objectForKey:@"m"];
                ChatUserModel *bUser = [[ChatUserModel alloc] initWithString:attr[@"BUserInfo"] error:nil];
                ChatUserModel *cUser = [[ChatUserModel alloc] initWithString:attr[@"CUserInfo"] error:nil];
                if (isEmpty(bUser.userId) ||
                    isEmpty(cUser.userId) ||
                    NO == [members containsObject:Trim(bUser.userId)] ||
                    NO == [members containsObject:Trim(cUser.userId)]) {
                    NSLog(@"---------------------------will delete!!!");
                    AVObject *object = [AVObject objectWithoutDataWithClassName:@"_Conversation" objectId:conv.objectId];
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"delete successed");
                        }
                        else {
                            NSLog(@"delete faild:%@", error);
                        }
                    }];
                }
            }
        }
        else {
            NSLog(@"error:%@", error);
        }
    }];
}
//更新conversation的扩展属性
- (void)updateConversation:(AVIMConversation *)conversation byParams:(NSDictionary *)params block:(YSCResultBlock)block {
    if (isEmpty(conversation)) {
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
    //更新conversion
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [tempDict addEntriesFromDictionary:conversation.attributes];
    for (NSString *paramKey in params.allKeys) {
        tempDict[paramKey] = params[paramKey];
    }
    AVIMConversationUpdateBuilder *updateBuilder = [conversation newUpdateBuilder];
    updateBuilder.attributes = tempDict;
    [conversation update:[updateBuilder dictionary] callback:^(BOOL succeeded, NSError *error) {
        [[CDConversationStore store] updateConversation:conversation];
        if (block) {
            block(error);
        }
    }];
}
//拦截消息到达通知
- (void)messageReceived:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ( ! [message isKindOfClass:[AVIMTypedMessage class]] || message.mediaType < EZGMessageTypeScene) {
        postN(kNotificationRefreshMessageCenter);//刷新消息中心
        return;
    }
    
    //特殊类型的消息
    RescueStatusType rescueStatus = 0;//默认不修改
    BOOL isUpdatedByC = YES;//C端需要调用接口更新救援任务状态
    if (EZGMessageTypeServiceCancel == message.mediaType) {//C端发出之前需要先修改救援任务状态
        //B端处理：conversation的ezgoalType修改为RescueStatusTypeCancelByC
        rescueStatus = RescueStatusTypeCancelByC;
    }
    else if (EZGMessageTypeServiceComment == message.mediaType) {//C端发出之前需要先修改救援任务状态
        //B端处理：conversation的ezgoalType修改为RescueStatusTypeConfirm
        rescueStatus = RescueStatusTypeConfirm;
    }
    else if (EZGMessageTypeService == message.mediaType) {//救援过程中的业务数据往来
        if (EZGServiceTypeStart == [message.attributes[MParamServiceType] integerValue]) {
            //C端处理：conversation的ezgoalType修改为RescueStatusTypeProcessing
            rescueStatus = RescueStatusTypeProcessing;
            isUpdatedByC = NO;
        }
        else if (EZGServiceTypeFinish == [message.attributes[MParamServiceType] integerValue]) {
            //C端处理：conversation的ezgoalType修改为RescueStatusTypeFinished
            rescueStatus = RescueStatusTypeFinished;
            isUpdatedByC = NO;
        }
        else if (EZGServiceTypeOver == [message.attributes[MParamServiceType] integerValue]) {
            //C端处理：conversation的ezgoalType修改为RescueStatusTypeCancelByB
            rescueStatus = RescueStatusTypeCancelByB;
            isUpdatedByC = NO;
        }
        else if (EZGServiceTypeResume == [message.attributes[MParamServiceType] integerValue]) {//C端发出之前需要先修改救援任务状态
            //B端处理：conversation的ezgoalType修改为RescueStatusTypeProcessing
            rescueStatus = RescueStatusTypeProcessing;
        }
    }
    
    if (rescueStatus != 0) {//有修改
        AVIMConversation *conv = [[CDConversationStore store] selectOneConversationByConvId:message.conversationId];
        //更新救援任务状态
        if ((IsAppTypeC && isUpdatedByC) || (IsAppTypeB && ! isUpdatedByC)) {
            [RescueModel updateRescueInfo:@{kParamRescueId : Trim(conv.rescueId),
                                            kParamS4Id : Trim(conv.s4Id),
                                            kParamRescueStatus : @(rescueStatus)
                                            }
                                    block:^(NSObject *object, NSError *error) {
                                        //更新conversation
                                        [EZGDATA updateConversation:conv byParams:@{kParamEzgoalStatus : @(rescueStatus)} block:^(NSObject *object) {
                                            postN(kNotificationRefreshMessageCenter);//刷新消息中心
                                            APPDATA.isRescueModelChanged = YES;//通知会话页面，报告conv的状态已经更新了
                                            //FIXME:更新失败的处理？？？
                                        }];
                                    }];
        }
        else {
            //更新本地救援模型
            if ([message.conversationId isEqualToString:APPDATA.rescueModel.conversationId] ||
                [conv.rescueId isEqualToString:APPDATA.rescueModel.rescueId]) {
                APPDATA.rescueModel.rescueStatus = rescueStatus;
                SaveObjectByFile(APPDATA.rescueModel, kCachedRescueModel, kParamAppModel);
            }
            //更新conversation
            [EZGDATA updateConversation:conv byParams:@{kParamEzgoalStatus : @(rescueStatus)} block:^(NSObject *object) {
                postN(kNotificationRefreshMessageCenter);//刷新消息中心
                APPDATA.isRescueModelChanged = YES;//通知会话页面，报告conv的状态已经更新了
                //FIXME:更新失败的处理？？？
            }];
        }
    }
    else {
        postN(kNotificationRefreshMessageCenter);//刷新消息中心
    }
}
@end
