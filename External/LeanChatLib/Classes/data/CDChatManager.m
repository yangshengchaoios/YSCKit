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

static NSString *kConversationUnreadsKey = @"unreads";
static NSString *kConversationMentionKey = @"mention";

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
        [AVIMClient defaultClient].delegate =self;
        /* 取消下面的注释，将对 im的 open ，start(create conv),kick,invite 操作签名，更安全
         可以从你的服务器获得签名，这里从云代码获取，需要部署云代码，https://github.com/leancloud/leanchat-cloudcode
         */
        //        _imClient.signatureDataSource=self;
        _cachedConvs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (AVIMClient *)imClient {
    return [AVIMClient defaultClient];
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
    }];
}

- (void)closeWithCallback:(AVBooleanResultBlock)callback {
    if (_selfId == nil) {
        return;
    }
    _selfId = nil;
    [[AVIMClient defaultClient] closeWithCallback:callback];
}

#pragma mark - conversation

- (void)fecthConvWithConvid:(NSString *)convid callback:(AVIMConversationResultBlock)callback {
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    [q whereKey:@"objectId" equalTo:convid];
    [q findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        else {
            callback([objects objectAtIndex:0], error);
        }
    }];
}

- (void)fetchConvWithMembers:(NSArray *)members type:(CDConvType)type callback:(AVIMConversationResultBlock)callback {
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    [q whereKey:AVIMAttr(CONV_TYPE) equalTo:@(type)];
    [q whereKey:kAVIMKeyMember containsAllObjectsInArray:members];
    [q whereKey:kAVIMKeyMember sizeEqualTo:members.count];
    [q orderByDescending:@"createdAt"];
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
        name = [AVIMConversation nameOfUserIds:members];
    }
    [[AVIMClient defaultClient] createConversationWithName:name clientIds:members attributes:@{ CONV_TYPE:@(type) } options:AVIMConversationOptionNone callback:callback];
}

- (void)findGroupedConvsWithBlock:(AVIMArrayResultBlock)block {
    AVIMConversationQuery *q = [[AVIMClient defaultClient] conversationQuery];
    [q whereKey:AVIMAttr(CONV_TYPE) equalTo:@(CDConvTypeGroup)];
    [q whereKey:kAVIMKeyMember containedIn:@[self.selfId]];
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
        q.limit = 1000;  // default limit:10
        [q findConversationsWithCallback:callback];
    }
    else {
        callback([NSMutableArray array], nil);
    }
}

#pragma mark - utils

- (void)sendMessage:(AVIMTypedMessage*)message conversation:(AVIMConversation *)conversation callback:(AVBooleanResultBlock)block {
    id<CDUserModel> selfUser = [[CDChatManager manager].userDelegate getUserById:self.selfId];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:selfUser.username forKey:@"username"];
    if (self.useDevPushCerticate) {
        [attributes setObject:@YES forKey:@"dev"];
    }
    message.attributes = attributes;
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
        NSMutableArray *typedMessages = [NSMutableArray array];
        for (AVIMTypedMessage *message in messages) {
            if ([message isKindOfClass:[AVIMTypedMessage class]]) {
                [typedMessages addObject:message];
            }
        }
        block(typedMessages, error);
    };
    if(timestamp == 0) {
        [conversation queryMessagesWithLimit:limit callback:callback];
    } else {
        [conversation queryMessagesBeforeId:nil timestamp:timestamp limit:limit callback:callback];
    }
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

- (void)updateConnectStatus {
    self.connect = [AVIMClient defaultClient].status == AVIMClientStatusOpened;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationConnectivityUpdated object:@(self.connect)];
}

#pragma mark - AVIMMessageDelegate

- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
}

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
    [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationMessageReceived object:message];
}

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
        refreshedFromServer = YES;
        NSMutableSet *convids = [NSMutableSet set];
        for (AVIMConversation *conversation in conversations) {
            [convids addObject:conversation.conversationId];
        }
        [self fetchConvsWithConvids:convids callback:^(NSArray *objects, NSError *error) {
            if (error) {
                block(conversations, nil);
            } else {
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
        [self.userDelegate cacheUserByIds:userIds block: ^(BOOL succeeded, NSError *error) {
            if (error) {
                block(nil,0, error);
            }
            else {
                block(sortedRooms, totalUnreadCount, error);
            }
        }];
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
