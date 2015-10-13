//
//  AVIMConversation+CustomAttributes.m
//  LeanChatLib
//
//  Created by lzw on 15/4/8.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import "AVIMConversation+Custom.h"
#import "CDChatManager.h"
#import "UIImage+Icon.h"
#import <objc/runtime.h>

@implementation AVIMConversation (Custom)

- (AVIMTypedMessage *)lastMessage {
    return objc_getAssociatedObject(self, @selector(lastMessage));
}

- (void)setLastMessage:(AVIMTypedMessage *)lastMessage {
    objc_setAssociatedObject(self, @selector(lastMessage), lastMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)unreadCount {
    return [objc_getAssociatedObject(self, @selector(unreadCount)) intValue];
}

- (void)setUnreadCount:(NSInteger)unreadCount {
    objc_setAssociatedObject(self, @selector(unreadCount), @(unreadCount), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)mentioned {
    return [objc_getAssociatedObject(self, @selector(mentioned)) boolValue];
}

- (void)setMentioned:(BOOL)mentioned {
    objc_setAssociatedObject(self, @selector(mentioned), @(mentioned), OBJC_ASSOCIATION_ASSIGN);
}

- (CDConvType)type {
    return [[self.attributes objectForKey:CONV_TYPE] intValue];
}

+ (NSString *)nameOfUserIds:(NSArray *)userIds {
    NSMutableArray *names = [NSMutableArray array];
    for (int i = 0; i < userIds.count; i++) {
        id <CDUserModel> user = [[CDChatManager manager].userDelegate getUserById:[userIds objectAtIndex:i]];
        [names addObject:user.username];
    }
    return [names componentsJoinedByString:@","];
}

- (NSString *)displayName {
    if ([self type] == CDConvTypeSingle) {
        NSString *otherId = [self otherId];
        id <CDUserModel> other = [[CDChatManager manager].userDelegate getUserById:otherId];
        return other.username;
    }
    else {
        return self.name;
    }
}

- (NSString *)otherId {
    NSArray *members = self.members;
    if (members.count == 0) {
        [NSException raise:@"invalid conv" format:nil];
    }
    if (members.count == 1) {
        return members[0];
    }
    NSString *otherId;
    if ([members[0] isEqualToString:[CDChatManager manager].selfId]) {
        otherId = members[1];
    }
    else {
        otherId = members[0];
    }
    return otherId;
}

- (NSString *)title {
    if (self.type == CDConvTypeSingle) {
        return self.displayName;
    }
    else {
        return [NSString stringWithFormat:@"%@(%ld)", self.displayName, (long)self.members.count];
    }
}

- (UIImage *)icon {
    return [UIImage imageWithHashString:self.conversationId displayString:[[self.name substringWithRange:NSMakeRange(0, 1)] capitalizedString]];
}

@end
