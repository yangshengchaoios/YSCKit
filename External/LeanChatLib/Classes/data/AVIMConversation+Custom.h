//
//  AVIMConversation+CustomAttributes.h
//  LeanChatLib
//
//  Created by lzw on 15/4/8.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import <AVOSCloudIM/AVOSCloudIM.h>

#define CONV_TYPE @"type"

typedef enum : NSUInteger {
    CDConvTypeSingle = 0,
    CDConvTypeGroup,
} CDConvType;

@interface AVIMConversation (Custom)

@property (nonatomic, strong) AVIMTypedMessage *lastMessage;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) BOOL mentioned;

- (CDConvType)type;
- (NSString *)otherId;
- (NSString *)displayName;
- (NSString *)title;
- (UIImage *)icon;

+ (NSString *)nameOfUserIds:(NSArray *)userIds;

@end
