//
//  CDChatManager.m
//  LeanChat
//
//  Created by lzw on 15/1/21.
//  Copyright (c) 2015年 LeanCloud. All rights reserved.
//

#import "CDChatManager.h"
#import "CDEmotionUtils.h"
#import "CDSoundManager.h"
#import "CDConversationStore.h"
#import "CDFailedMessageStore.h"
#import "CDMacros.h"
#import "CDChatManager_Internal.h"

static CDChatManager *instance;

@interface CDChatManager () <AVIMClientDelegate, AVIMSignatureDataSource>

@property (nonatomic, assign, readwrite) BOOL connect;
@property (nonatomic, strong) NSMutableDictionary *cachedConvs;
@property (nonatomic, strong) NSString *plistPath;
@property (nonatomic, strong) NSMutableDictionary *conversationDatas;
@property (nonatomic, assign) NSInteger totalUnreadCount;

@end

@implementation CDChatManager

#pragma mark - lifecycle

+ (instancetype)manager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[CDChatManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [AVIMClient setTimeoutIntervalInSeconds:20];
        // 以下选项也即是说 A 不在线时，有人往A发了很多条消息，下次启动时，不再收到具体的离线消息，而是收到离线消息的数目(未读通知)
        [AVIMClient setUserOptions:@{AVIMUserOptionUseUnread:@(YES)}];
        [AVIMClient defaultClient].delegate =self;
        /* 取消下面的注释，将对 im的 open ，start(create conv),kick,invite 操作签名，更安全
         可以从你的服务器获得签名，这里从云代码获取，需要部署云代码，https://github.com/leancloud/leanchat-cloudcode
         */
        //        _imClient.signatureDataSource=self;
        _cachedConvs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
}

- (NSString *)databasePathWithUserId:(NSString *)userId{
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"com.leancloud.leanchatlib.%@.db3", userId]];
}

- (void)openWithClientId:(NSString *)clientId callback:(AVIMBooleanResultBlock)callback {
    _selfId = clientId;
    NSString *dbPath = [self databasePathWithUserId:_selfId];
    [[CDConversationStore store] setupStoreWithDatabasePath:dbPath];
    [[CDFailedMessageStore store] setupStoreWithDatabasePath:dbPath];
    [[AVIMClient defaultClient] openWithClientId:clientId callback:^(BOOL succeeded, NSError *error) {
        [self updateConnectStatus];
        if (callback) {
            callback(succeeded, error);
        }
//        [CDEmotionUtils saveEmotions];
    }];
}

- (void)closeWithCallback:(AVBooleanResultBlock)callback {
    [[AVIMClient defaultClient] closeWithCallback:callback];
}

#pragma mark - conversation

- (void)fecthConvWithConvid:(NSString *)convid callback:(AVIMConversationResultBlock)callback {
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    q.cachePolicy = kAVCachePolicyNetworkElseCache;
    [q whereKey:@"objectId" equalTo:convid];
    [q findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        else {
            if (objects.count == 0) {
                callback(nil, [CDChatManager errorWithText:[NSString stringWithFormat:@"conversation of %@ not exists", convid]]);
            } else {
                callback([objects objectAtIndex:0], error);
            }
        }
    }];
}

- (void)checkDuplicateValueOfArray:(NSArray *)array {
    NSSet *set = [NSSet setWithArray:array];
    if (set.count != array.count) {
        [NSException raise:NSInvalidArgumentException format:@"The array has duplicate value"];
    }
}

- (void)fetchConvWithMembers:(NSArray *)members type:(CDConvType)type callback:(AVIMConversationResultBlock)callback {
    if ([members containsObject:self.selfId] == NO) {
        [NSException raise:NSInvalidArgumentException format:@"members should contain myself"];
    }
    [self checkDuplicateValueOfArray:members];
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    [q whereKey:AVIMAttr(CONV_TYPE) equalTo:@(type)];
    [q whereKey:kAVIMKeyMember containsAllObjectsInArray:members];
    // 如果没有数组size限制，传[2,3]，可能取回 [1,2,3]
    [q whereKey:kAVIMKeyMember sizeEqualTo:members.count];
    [q orderByDescending:@"createdAt"];
    q.cachePolicy = kAVCachePolicyNetworkElseCache;
    q.limit = 1;
    [q findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        else {
            if (objects.count > 0) {
                AVIMConversation *conv = [objects objectAtIndex:0];
                callback(conv, nil);
            }
            else {
                [self createConvWithMembers:members type:type callback:callback];
            }
        }
    }];
}

- (void)fetchConvWithMembers:(NSArray *)members callback:(AVIMConversationResultBlock)callback {
    [self fetchConvWithMembers:members type:CDConvTypeGroup callback:callback];
}

- (void)fetchConvWithOtherId:(NSString *)otherId callback:(AVIMConversationResultBlock)callback {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[AVIMClient defaultClient].clientId];
    [array addObject:otherId];
    [self fetchConvWithMembers:array type:CDConvTypeSingle callback:callback];
}

- (void)createConvWithMembers:(NSArray *)members type:(CDConvType)type callback:(AVIMConversationResultBlock)callback {
    NSString *name = nil;
    if (type == CDConvTypeGroup) {
        // 群聊默认名字， 老王、小李
        name = [AVIMConversation nameOfUserIds:members];
    }
    [[AVIMClient defaultClient] createConversationWithName:name clientIds:members attributes:@{ CONV_TYPE:@(type) } options:AVIMConversationOptionNone callback:callback];
}

- (void)findGroupedConvsWithBlock:(AVIMArrayResultBlock)block {
    [self findGroupedConvsWithNetworkFirst:NO block:block];
}

- (void)findGroupedConvsWithNetworkFirst:(BOOL)networkFirst block:(AVIMArrayResultBlock)block {
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    [q whereKey:AVIMAttr(CONV_TYPE) equalTo:@(CDConvTypeGroup)];
    [q whereKey:kAVIMKeyMember containedIn:@[self.selfId]];
    if (networkFirst) {
        q.cachePolicy = kAVCachePolicyNetworkElseCache;
    } else {
        q.cachePolicy = kAVCachePolicyCacheElseNetwork;
        q.cacheMaxAge = 60 * 30; // 半小时
    }
    // 默认 limit 为10
    q.limit = 1000;
    [q findConversationsWithCallback:block];
}

- (void)updateConv:(AVIMConversation *)conv name:(NSString *)name attrs:(NSDictionary *)attrs callback:(AVIMBooleanResultBlock)callback {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (name) {
        [dict setObject:name forKey:@"name"];
    }
    if (attrs) {
        [dict setObject:attrs forKey:@"attrs"];
    }
    [conv update:dict callback:callback];
}

- (void)fetchConvsWithConvids:(NSSet *)convids callback:(AVIMArrayResultBlock)callback {
    if (convids.count > 0) {
        AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
        [q whereKey:@"objectId" containedIn:[convids allObjects]];
        q.cachePolicy = kAVCachePolicyNetworkElseCache;
        q.limit = 1000;  // default limit:10
        [q findConversationsWithCallback:callback];
    } else {
        callback([NSMutableArray array], nil);
    }
}

#pragma mark - utils

- (void)sendMessage:(AVIMTypedMessage*)message conversation:(AVIMConversation *)conversation callback:(AVBooleanResultBlock)block {
    id<CDUserModel> selfUser = [[CDChatManager manager].userDelegate getUserById:self.selfId];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    // 云代码中获取到用户名，来设置推送消息, 老王:今晚约吗？
    if (selfUser.username) {
        // 避免为空造成崩溃
        [attributes setObject:selfUser.username forKey:@"username"];
    }
    if (self.useDevPushCerticate) {
        [attributes setObject:@YES forKey:@"dev"];
    }
    if (message.attributes == nil) {
        message.attributes = attributes;
    } else {
        [attributes addEntriesFromDictionary:message.attributes];
        message.attributes = attributes;
    }
    [conversation sendMessage:message options:AVIMMessageSendOptionRequestReceipt callback:block];
}

- (void)sendWelcomeMessageToOther:(NSString *)other text:(NSString *)text block:(AVBooleanResultBlock)block {
    [self fetchConvWithOtherId:other callback:^(AVIMConversation *conversation, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            AVIMTextMessage *textMessage = [AVIMTextMessage messageWithText:text attributes:nil];
            [self sendMessage:textMessage conversation:conversation callback:block];
        }
    }];
}

#pragma mark - query msgs

- (void)queryTypedMessagesWithConversation:(AVIMConversation *)conversation timestamp:(int64_t)timestamp limit:(NSInteger)limit block:(AVIMArrayResultBlock)block {
    AVIMArrayResultBlock callback = ^(NSArray *messages, NSError *error) {
        //以下过滤为了避免非法的消息，引起崩溃
        NSMutableArray *typedMessages = [NSMutableArray array];
        for (AVIMTypedMessage *message in messages) {
            if ([message isKindOfClass:[AVIMTypedMessage class]]) {
                [typedMessages addObject:message];
            }
        }
        block(typedMessages, error);
    };
    if(timestamp == 0) {
        // sdk 会设置好 timestamp
        [conversation queryMessagesWithLimit:limit callback:callback];
    } else {
        [conversation queryMessagesBeforeId:nil timestamp:timestamp limit:limit callback:callback];
    }
}

#pragma mark - remote notification

- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[@"convid"]) {
        self.remoteNotificationConvid = userInfo[@"convid"];
        return YES;
    }
    return NO;
}

#pragma mark - AVIMClientDelegate

- (void)imClientPaused:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResuming:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResumed:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

#pragma mark - status
// 除了 sdk 的上面三个回调调用了，还在 open client 的时候调用了，好统一处理
- (void)updateConnectStatus {
    self.connect = [AVIMClient defaultClient].status == AVIMClientStatusOpened;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationConnectivityUpdated object:@(self.connect)];
}

#pragma mark - receive message handle

- (void)receiveMessage:(AVIMTypedMessage *)message conversation:(AVIMConversation *)conversation{
    [[CDConversationStore store] insertConversation:conversation];
    if ([self.chattingConversationId isEqualToString:conversation.conversationId] == NO) {
        // 没有在聊天的时候才增加未读数和设置mentioned
        [[CDConversationStore store] increaseUnreadCountWithConversation:conversation];
        if ([self isMentionedByMessage:message]) {
            [[CDConversationStore store] updateMentioned:YES conversation:conversation];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationUnreadsUpdated object:nil];
    }
    if (self.chattingConversationId == nil) {
        if (conversation.muted == NO) {
            [[CDSoundManager manager] playLoudReceiveSoundIfNeed];
            [[CDSoundManager manager] vibrateIfNeed];
        }
    }
    [conversation markAsReadInBackground];
    //只要接受到消息，就表示之前所有已发送的消息都是已读的>>>
    NSString *received_convid = [NSString stringWithFormat:@"received_%@", Trim(conversation.conversationId)];
    SaveCacheObject(@(message.sendTimestamp), received_convid);
    //在进入聊天对话框的时候就设置为已读<<<<<<<<<<<<<<<<<<
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationMessageReceived object:message];
}

#pragma mark - AVIMMessageDelegate

// content : "this is message"
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    // 不做处理，此应用没有用到
    // 可以看做跟 AVIMTypedMessage 两个频道。构造消息和收消息的接口都不一样，互不干扰。
    // 其实一般不用，有特殊的需求时可以考虑优先用 自定义 AVIMTypedMessage 来实现。见 AVIMCustomMessage 类
}

// content : "{\"_lctype\":-1,\"_lctext\":\"sdfdf\"}"  sdk 会解析好
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    if (message.messageId) {
        if (conversation.creator == nil && [[CDConversationStore store] isConversationExists:conversation] == NO) {
            [conversation fetchWithCallback:^(BOOL succeeded, NSError *error) {
                if (error) {
                    DLog(@"%@", error);
                } else {
                    [self receiveMessage:message conversation:conversation];
                }
            }];
        } else {
            [self receiveMessage:message conversation:conversation];
        }
    }
    else {
        DLog(@"Receive Message , but MessageId is nil");
    }
}

- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message {
    DLog();
    if (message != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationMessageDelivered object:message];
    }
}

- (void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread {
    // 需要开启 AVIMUserOptionUseUnread 选项，见 init
    DLog(@"conversatoin:%@ didReceiveUnread:%@", conversation, @(unread));
    [conversation markAsReadInBackground];
}

#pragma mark - AVIMClientDelegate

- (void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId {
    DLog();
}

- (void)conversation:(AVIMConversation *)conversation membersRemoved:(NSArray *)clientIds byClientId:(NSString *)clientId {
    DLog();
}

- (void)conversation:(AVIMConversation *)conversation invitedByClientId:(NSString *)clientId {
    DLog();
}

- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId {
    DLog();
}

#pragma mark - signature

- (id)convSignWithSelfId:(NSString *)selfId convid:(NSString *)convid targetIds:(NSArray *)targetIds action:(NSString *)action {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:selfId forKey:@"self_id"];
    if (convid) {
        [dict setObject:convid forKey:@"convid"];
    }
    if (targetIds) {
        [dict setObject:targetIds forKey:@"targetIds"];
    }
    if (action) {
        [dict setObject:action forKey:@"action"];
    }
    //这里是从云代码获取签名，也可以从你的服务器获取
    return [AVCloud callFunction:@"conv_sign" withParameters:dict];
}

- (AVIMSignature *)getAVSignatureWithParams:(NSDictionary *)fields peerIds:(NSArray *)peerIds {
    AVIMSignature *avSignature = [[AVIMSignature alloc] init];
    NSNumber *timestampNum = [fields objectForKey:@"timestamp"];
    long timestamp = [timestampNum longValue];
    NSString *nonce = [fields objectForKey:@"nonce"];
    NSString *signature = [fields objectForKey:@"signature"];
    
    [avSignature setTimestamp:timestamp];
    [avSignature setNonce:nonce];
    [avSignature setSignature:signature];
    return avSignature;
}

- (AVIMSignature *)signatureWithClientId:(NSString *)clientId
                          conversationId:(NSString *)conversationId
                                  action:(NSString *)action
                       actionOnClientIds:(NSArray *)clientIds {
    if ([action isEqualToString:@"open"] || [action isEqualToString:@"start"]) {
        action = nil;
    }
    if ([action isEqualToString:@"remove"]) {
        action = @"kick";
    }
    if ([action isEqualToString:@"add"]) {
        action = @"invite";
    }
    NSDictionary *dict = [self convSignWithSelfId:clientId convid:conversationId targetIds:clientIds action:action];
    if (dict != nil) {
        return [self getAVSignatureWithParams:dict peerIds:clientIds];
    }
    else {
        return nil;
    }
}

#pragma mark - File Utils

- (NSString *)getFilesPath {
    NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [appPath stringByAppendingString:@"/files/"];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDir = YES;
    if ([fileMan fileExistsAtPath:filesPath isDirectory:&isDir] == NO) {
        [fileMan createDirectoryAtPath:filesPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [NSException raise:@"error when create dir" format:@"error"];
        }
    }
    return filesPath;
}

- (NSString *)getPathByObjectId:(NSString *)objectId {
    return [[self getFilesPath] stringByAppendingFormat:@"%@", objectId];
}

- (NSString *)videoPathOfMessag:(AVIMVideoMessage *)message {
    // 视频播放会根据文件扩展名来识别格式
    return [[self getFilesPath] stringByAppendingFormat:@"%@.%@", message.messageId, message.format];
}

- (NSString *)tmpPath {
    return [[self getFilesPath] stringByAppendingFormat:@"tmp"];
}

- (NSString *)uuid {
    NSString *chars = @"abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    assert(chars.length == 62);
    int len = (int)chars.length;
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < 24; i++) {
        int p = arc4random_uniform(len);
        NSRange range = NSMakeRange(p, 1);
        [result appendString:[chars substringWithRange:range]];
    }
    return result;
}

+ (NSError *)errorWithText:(NSString *)text {
    return [NSError errorWithDomain:@"LeanChatLib" code:0 userInfo:@{NSLocalizedDescriptionKey:text}];
}

#pragma mark - conv cache

- (NSString *)localKeyWithConvid:(NSString *)convid {
    return [NSString stringWithFormat:@"conv_%@", convid];
}

- (AVIMConversation *)lookupConvById:(NSString *)convid {
    return [[AVIMClient defaultClient] conversationForId:convid];
}

- (void)cacheConvsWithIds:(NSMutableSet *)convids callback:(AVBooleanResultBlock)callback {
    NSMutableSet *uncacheConvids = [[NSMutableSet alloc] init];
    for (NSString *convid in convids) {
        AVIMConversation * conversation = [self lookupConvById:convid];
        if (conversation == nil) {
            [uncacheConvids addObject:convid];
        }
    }
    [self fetchConvsWithConvids:uncacheConvids callback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(NO, error);
        }
        else {
            callback(YES, nil);
        }
    }];
}

- (void)selectOrRefreshConversationsWithBlock:(AVIMArrayResultBlock)block {
    static BOOL refreshedFromServer = NO;
    NSArray *conversations = [[CDConversationStore store] selectAllConversations];
    if (refreshedFromServer == NO && self.connect) {
        NSMutableSet *convids = [NSMutableSet set];
        for (AVIMConversation *conversation in conversations) {
            [convids addObject:conversation.conversationId];
        }
        [self fetchConvsWithConvids:convids callback:^(NSArray *objects, NSError *error) {
            if (error) {
                block(conversations, nil);
            } else {
                refreshedFromServer = YES;
                [[CDConversationStore store] updateConversations:objects];
                block([[CDConversationStore store] selectAllConversations], nil);
            }
        }];
    } else {
        block(conversations, nil);
    }
}

- (void)findRecentConversationsWithBlock:(CDRecentConversationsCallback)block {
    [self selectOrRefreshConversationsWithBlock:^(NSArray *conversations, NSError *error) {
        NSMutableSet *userIds = [NSMutableSet set];
        NSUInteger totalUnreadCount = 0;
        for (AVIMConversation *conversation in conversations) {
            NSArray *lastestMessages = [conversation queryMessagesFromCacheWithLimit:1];
            if (lastestMessages.count > 0) {
                conversation.lastMessage = lastestMessages[0];
            }
            if (conversation.type == CDConvTypeSingle) {
                [userIds addObject:conversation.otherId];
            } else {
                if (conversation.lastMessage) {
                    [userIds addObject:conversation.lastMessage.clientId];
                }
            }
            if (conversation.muted == NO) {
                totalUnreadCount += conversation.unreadCount;
            }
        }
        NSArray *sortedRooms = [conversations sortedArrayUsingComparator:^NSComparisonResult(AVIMConversation *conv1, AVIMConversation *conv2) {
            return conv2.lastMessage.sendTimestamp - conv1.lastMessage.sendTimestamp;
        }];
        
        if ([self.userDelegate respondsToSelector:@selector(cacheUserByIds:block:)]) {
            [self.userDelegate cacheUserByIds:userIds block: ^(BOOL succeeded, NSError *error) {
                if (error) {
                    block(nil,0, error);
                }
                else {
                    block(sortedRooms, totalUnreadCount, error);
                }
            }];
        } else {
            DLog(@"self.userDelegate not reponds to cacheUserByIds:block:, may have problem");
            block([NSArray array], 0 , nil);
        }
    }];
}

#pragma mark - mention

- (BOOL)isMentionedByMessage:(AVIMTypedMessage *)message {
    if (![message isKindOfClass:[AVIMTextMessage class]]) {
        return NO;
    } else {
        NSString *text = ((AVIMTextMessage *)message).text;
        NSString *pattern = [NSString stringWithFormat:@"@%@ ",[AVUser currentUser].username];
        if([text rangeOfString:pattern].length > 0) {
            return YES;
        } else {
           return NO;
        }
    }
}

#pragma mark - database 

- (void)deleteConversation:(AVIMConversation *)conversation {
    [[CDConversationStore store] deleteConversation:conversation];
}


@end
