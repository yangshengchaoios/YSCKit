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

#define kCDConversatoinTableCreateSQL                                       \
    @"CREATE TABLE IF NOT EXISTS " kCDConversationTableName @" ("           \
        kCDConversationTableKeyId           @" VARCHAR(63) PRIMARY KEY, "   \
        kCDConversationTableKeyData         @" BLOB NOT NULL, "             \
        kCDConversationTableKeyUnreadCount  @" INTEGER DEFAULT 0, "         \
        kCDConversationTableKeyMentioned    @" BOOL DEFAULT FALSE "         \
    @")"

#define kCDConversationTableInsertSQL                           \
    @"INSERT OR IGNORE INTO " kCDConversationTableName @" ("    \
        kCDConversationTableKeyId               @", "           \
        kCDConversationTableKeyData             @", "           \
        kCDConversationTableKeyUnreadCount      @", "           \
        kCDConversationTableKeyMentioned                        \
    @") VALUES(?, ?, ?, ?)"

#define kCDConversationTableWhereClause                         \
    @" WHERE " kCDConversationTableKeyId         @" = ?"

#define kCDConversationTableDeleteSQL                           \
    @"DELETE FROM " kCDConversationTableName                    \
    kCDConversationTableWhereClause

#define kCDConversationTableIncreaseUnreadCountSQL              \
    @"UPDATE " kCDConversationTableName         @" "            \
    @"SET " kCDConversationTableKeyUnreadCount  @" = "          \
            kCDConversationTableKeyUnreadCount  @" + 1 "        \
    kCDConversationTableWhereClause

#define kCDConversationTableUpdateUnreadCountSQL                \
    @"UPDATE " kCDConversationTableName         @" "            \
    @"SET " kCDConversationTableKeyUnreadCount  @" = ? "        \
    kCDConversationTableWhereClause

#define kCDConversationTableUpdateMentionedSQL                  \
    @"UPDATE " kCDConversationTableName         @" "            \
    @"SET " kCDConversationTableKeyMentioned    @" = ? "        \
    kCDConversationTableWhereClause

#define kCDConversationTableSelectSQL                           \
    @"SELECT * FROM " kCDConversationTableName                  \

#define kCDConversationTableSelectOneSQL                        \
    @"SELECT * FROM " kCDConversationTableName                  \
    kCDConversationTableWhereClause

#define kCDConversationTableUpdateDataSQL                       \
    @"UPDATE " kCDConversationTableName @" "                    \
    @"SET " kCDConversationTableKeyData @" = ? "                \
    kCDConversationTableWhereClause                             \

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

- (void)setupStoreWithDatabasePath:(NSString *)path {
    if (self.databaseQueue) {
        DLog(@"database queue not nil !!!!");
    }
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversatoinTableCreateSQL];
    }];
}

#pragma mark - conversations local data

- (NSData *)dataFromConversation:(AVIMConversation *)conversation {
    AVIMKeyedConversation *keydConversation = [conversation keyedConversation];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:keydConversation];
    return data;
}

- (AVIMConversation *)conversationFromData:(NSData *)data{
    AVIMKeyedConversation *keyedConversation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [[AVIMClient defaultClient] conversationWithKeyedConversation:keyedConversation];
}

- (void)updateUnreadCountToZeroWithConversation:(AVIMConversation *)conversation {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversationTableUpdateUnreadCountSQL  withArgumentsInArray:@[@0 , conversation.conversationId]];
    }];
}

- (void)deleteConversation:(AVIMConversation *)conversation {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversationTableDeleteSQL withArgumentsInArray:@[conversation.conversationId]];
    }];
}

- (void )insertConversation:(AVIMConversation *)conversation {
    if (conversation.creator == nil) {
        return;
    }
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSData *data = [self dataFromConversation:conversation];
        [db executeUpdate:kCDConversationTableInsertSQL withArgumentsInArray:@[conversation.conversationId, data, @0, @(NO)]];
    }];
}

- (BOOL)isConversationExists:(AVIMConversation *)conversation {
    __block BOOL exists = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:kCDConversationTableSelectOneSQL withArgumentsInArray:@[conversation.conversationId]];
        if ([resultSet next]) {
            exists = YES;
        }
        [resultSet close];
    }];
    return exists;
}

- (void)increaseUnreadCountWithConversation:(AVIMConversation *)conversation {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversationTableIncreaseUnreadCountSQL withArgumentsInArray:@[conversation.conversationId]];
    }];
}

- (void)updateMentioned:(BOOL)mentioned conversation:(AVIMConversation *)conversation {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDConversationTableUpdateMentionedSQL withArgumentsInArray:@[@(mentioned), conversation.conversationId]];
    }];
}

- (AVIMConversation *)createConversationFromResultSet:(FMResultSet *)resultSet {
    NSData *data = [resultSet dataForColumn:kCDConversationTableKeyData];
    NSInteger unreadCount = [resultSet intForColumn:kCDConversationTableKeyUnreadCount];
    BOOL mentioned = [resultSet boolForColumn:kCDConversationTableKeyMentioned];
    AVIMConversation *conversation = [self conversationFromData:data];
    conversation.unreadCount = unreadCount;
    conversation.mentioned = mentioned;
    return conversation;
}

- (NSArray *)selectAllConversations {
    NSMutableArray *conversations = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * resultSet = [db executeQuery:kCDConversationTableSelectSQL withArgumentsInArray:@[]];
        while ([resultSet next]) {
            [conversations addObject:[self createConversationFromResultSet:resultSet]];
        }
        [resultSet close];
    }];
    return conversations;
}

- (void)updateConversations:(NSArray *)conversations {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (AVIMConversation *conversation in conversations) {
            [db executeUpdate:kCDConversationTableUpdateDataSQL, [self dataFromConversation:conversation], conversation.conversationId];
        }
        [db commit];
    }];
}

@end