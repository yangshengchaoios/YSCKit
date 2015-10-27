//
//  CDDatabaseManager.m
//  LeanChatLib
//
//  Created by lzw on 15/7/13.
//  Copyright (c) 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import "CDConversationStore.h"
#import <FMDB/FMDB.h>
#import "AVIMConversation+Custom.h"
#import "CDMacros.h"

#define kCDConversationTableName @"conversations"

#define kCDConversationTableKeyId @"id"
#define kCDConversationTableKeyData @"data"
#define kCDConversationTableKeyUnreadCount @"unreadCount"
#define kCDConversationTableKeyMentioned @"mentioned"
#define kCDConversationTableKeyLastMessage @"lastMessage"
#define kCDConversationTableKeyUpdatedTime @"updatedTime"

#define kCDConversatoinTableCreateSQL                                       \
    @"CREATE TABLE IF NOT EXISTS " kCDConversationTableName @" ("           \
        kCDConversationTableKeyId           @" VARCHAR(200) PRIMARY KEY, "  \
        kCDConversationTableKeyData         @" BLOB NOT NULL, "             \
        kCDConversationTableKeyUnreadCount  @" INTEGER DEFAULT 0, "         \
        kCDConversationTableKeyMentioned    @" BOOL DEFAULT FALSE, "        \
        kCDConversationTableKeyLastMessage  @" BLOB NOT NULL, "             \
        kCDConversationTableKeyUpdatedTime  @" DATETIME DEFAULT NULL "      \
    @")"

#define kCDConversationTableInsertSQL                           \
    @"INSERT OR IGNORE INTO " kCDConversationTableName @" ("    \
        kCDConversationTableKeyId               @", "           \
        kCDConversationTableKeyData             @", "           \
        kCDConversationTableKeyUnreadCount      @", "           \
        kCDConversationTableKeyMentioned        @", "           \
        kCDConversationTableKeyLastMessage      @", "           \
        kCDConversationTableKeyUpdatedTime                      \
    @") VALUES(?, ?, ?, ?, ?, ?)"

@interface CDConversationStore ()
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@end

@implementation CDConversationStore

+ (CDConversationStore *)store {
    static CDConversationStore *store;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        store = [[CDConversationStore alloc] init];
    });
    return store;
}

//会在 openClient 时调用 跟自己的clientId相关的数据库路径
- (void)setupStoreWithDatabasePath:(NSString *)path {
    if (self.databaseQueue) {
        DLog(@"database queue not nil !!!!");
    }
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversatoinTableCreateSQL];
    }];
}

//插入一条最近会话
- (void)insertConversation:(AVIMConversation *)conversation {
    ReturnWhenObjectIsEmpty(conversation.creator);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSData *data = [self dataFromConversation:conversation];
        NSDate *lastDate = conversation.lastMessageAt;
        if (nil == lastDate) {
            lastDate = [NSDate date];
        }
        [db executeUpdate:kCDConversationTableInsertSQL withArgumentsInArray:@[conversation.conversationId, data, @0, @(NO), @"", lastDate]];
    }];
}
//判断会话是否存在本地
- (BOOL)isConversationExistsByConvId:(NSString *)convId {
    ReturnNOWhenObjectIsEmpty(convId);
    __block BOOL exists = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM conversations WHERE id = '%@'", Trim(convId)];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next]) {
            exists = YES;
        }
        [resultSet close];
    }];
    return exists;
}
//删除所有会话
- (void)deleteAllConversions {
//    [self.databaseQueue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:@"DELETE FROM conversations"];
//    }];
    //应该删除本地所有会话数据库文件！
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [YSCFileUtils allPathsInDirectoryPath:libPath];
    for (NSString *filePath in files) {
        if ([filePath hasPrefix:@"com.leancloud.leanchatlib."]) {
            [YSCFileUtils deleteFileOrDirectory:[libPath stringByAppendingPathComponent:filePath]];
        }
    }
}
//删除单个会话
- (void)deleteConversationByConvId:(NSString *)convId {
    ReturnWhenObjectIsEmpty(convId);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM conversations WHERE id = '%@'", Trim(convId)];
        [db executeUpdate:sql];
    }];
}
//清空某个会话的未读数
- (void)updateUnreadCountToZeroByConvId:(NSString *)convId {
    ReturnWhenObjectIsEmpty(convId);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE conversations SET unreadCount = 0 WHERE id = '%@'", Trim(convId)];
        [db executeUpdate:sql];
    }];
}
//增加未读数
- (void)increaseUnreadCountByConvId:(NSString *)convId {
    ReturnWhenObjectIsEmpty(convId);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE conversations SET unreadCount = unreadCount + 1 WHERE id = '%@'", Trim(convId)];
        [db executeUpdate:sql];
    }];
}
//更新 mentioned 值，当接收到消息发现 @了我的时候，设为 YES，进入聊天页面，设为 NO
- (void)updateMentioned:(BOOL)mentioned convId:(NSString *)convId {
    ReturnWhenObjectIsEmpty(convId);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE conversations SET mentioned = ? WHERE id = ?" withArgumentsInArray:@[@(mentioned), convId]];
    }];
}
//更新会话(列表)，如果没有就新建
- (void)updateConversations:(NSArray *)conversations {
    for (AVIMConversation *conv in conversations) {
        [self updateConversation:conv];
    }
}
//更新会话列表，如果没有就新建
- (void)updateConversation:(AVIMConversation *)conversation {
    ReturnWhenObjectIsEmpty(conversation);
    if ([self isConversationExistsByConvId:conversation.conversationId]) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db beginTransaction];
            [db executeUpdate:@"UPDATE conversations SET data = ? WHERE id = ?", [self dataFromConversation:conversation], conversation.conversationId];
            [db commit];
        }];
    }
    else {
        [self insertConversation:conversation];
    }
}
//更新最后一条消息记录成功发送的时间
- (void)updateLastMessage:(AVIMTypedMessage *)message byConvId:(NSString *)convId {
    ReturnWhenObjectIsEmpty(message);
    ReturnWhenObjectIsEmpty(convId);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [db executeUpdate:@"UPDATE conversations SET lastMessage = ?, updatedTime = ? WHERE id = ?",
         [self dataFromMessage:message], [NSDate dateWithTimeIntervalSince1970:message.sendTimestamp / 1000], convId];
        [db commit];
    }];
}

//从本地数据库查找未读消息总数
- (NSInteger)selectTotalUnreadCount {
    __block NSInteger totalUnreadCount = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM conversations WHERE unreadCount > 0"];
        while ([resultSet next]) {
            NSInteger unreadCount = [resultSet intForColumn:kCDConversationTableKeyUnreadCount];
            if (unreadCount > 0) {
                totalUnreadCount += unreadCount;
            }
        }
        [resultSet close];
    }];
    return totalUnreadCount;
}
//从本地数据库查找指定会话的未读消息数
- (NSInteger)selectUnreadCountByConvId:(NSString *)convId {
    if (isEmpty(convId)) {
        return 0;
    }
    __block NSInteger retUnreadCount = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM conversations WHERE id = ?" withArgumentsInArray:@[convId]];
        if ([resultSet next]) {
            NSInteger unreadCount = [resultSet intForColumn:kCDConversationTableKeyUnreadCount];
            if (unreadCount > 0) {
                retUnreadCount = unreadCount;
            }
        }
        [resultSet close];
    }];
    return retUnreadCount;
}

//从本地数据库查找所有的对话
- (NSArray *)selectAllConversations {
    NSMutableArray *conversations = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * resultSet = [db executeQuery:@"SELECT * FROM conversations"];
        while ([resultSet next]) {
            AVIMConversation *conv = [self createConversationFromResultSet:resultSet];
            if (isNotEmpty(conv)) {
                [conversations addObject:conv];
            }
        }
        [resultSet close];
    }];
    return conversations;
}
- (AVIMConversation *)selectOneConversationByConvId:(NSString *)convId {
    ReturnNilWhenObjectIsEmpty(convId);
    __block AVIMConversation *conv = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * resultSet = [db executeQuery:@"SELECT * FROM conversations WHERE id = ?" withArgumentsInArray:@[convId]];
        if ([resultSet next]) {
            conv = [self createConversationFromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return conv;
}
//分页获取本地会话列表
- (NSArray *)selectConversationsByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    pageIndex--;
    __block NSMutableArray *retArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM conversations ORDER BY updatedTime DESC LIMIT %ld,%ld",
                         (long)(pageIndex * pageSize), (long)pageSize];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            AVIMConversation *conv = [self createConversationFromResultSet:resultSet];
            if (isNotEmpty(conv)) {
                [retArray addObject:conv];
            }
        }
        [resultSet close];
    }];
    return retArray;
}
//查询本地是否有会话
- (BOOL)isConversationExists {
    __block BOOL exists = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM conversations"];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next]) {
            exists = YES;
        }
        [resultSet close];
    }];
    return exists;
}

- (NSData *)dataFromMessage:(AVIMTypedMessage *)message {
    ReturnNilWhenObjectIsEmpty(message);
    return [NSKeyedArchiver archivedDataWithRootObject:message];
}
- (AVIMTypedMessage *)messageFromData:(NSData *)data {
    ReturnNilWhenObjectIsEmpty(data);
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSData *)dataFromConversation:(AVIMConversation *)conversation {
    ReturnNilWhenObjectIsEmpty(conversation);
    AVIMKeyedConversation *keydConversation = [conversation keyedConversation];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:keydConversation];
    return data;
}
- (AVIMConversation *)conversationFromData:(NSData *)data {
    ReturnNilWhenObjectIsEmpty(data);
    AVIMKeyedConversation *keyedConversation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [[AVIMClient defaultClient] conversationWithKeyedConversation:keyedConversation];
}
- (AVIMConversation *)createConversationFromResultSet:(FMResultSet *)resultSet {
    ReturnNilWhenObjectIsEmpty(resultSet);
    AVIMConversation *conversation = [self conversationFromData:[resultSet dataForColumn:kCDConversationTableKeyData]];
    if (conversation) {
        conversation.lastMessage = [self messageFromData:[resultSet dataForColumn:kCDConversationTableKeyLastMessage]];
        conversation.unreadCount = [resultSet intForColumn:kCDConversationTableKeyUnreadCount];
        conversation.mentioned = [resultSet boolForColumn:kCDConversationTableKeyMentioned];
        conversation.updatedTime = [resultSet dateForColumn:kCDConversationTableKeyUpdatedTime];//最近一条消息的发送时间
    }
    return conversation;
}

@end