//
//  CDFailedMessagesManager.h
//  LeanChatLib
//
//  Created by lzw on 15/7/14.
//  Copyright (c) 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>

@interface CDFailedMessageStore : NSObject

+ (CDFailedMessageStore *)store;

- (void)setupStoreWithDatabasePath:(NSString *)path;

- (void)insertFailedMessage:(AVIMTypedMessage *)message;
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;
- (NSArray *)selectFailedMessagesByConversationId:(NSString *)conversationId;

@end
