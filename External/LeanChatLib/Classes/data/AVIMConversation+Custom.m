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

static NSString *ObjectTagKeyLastMessage = @"ObjectTagKeyLastMessage";
static NSString *ObjectTagKeyUnreadCount = @"ObjectTagKeyUnreadCount";
static NSString *ObjectTagKeyMentioned = @"ObjectTagKeyMentioned";
static NSString *ObjectTagKeyUpdatedTime = @"ObjectTagKeyUpdatedTime";

@implementation AVIMConversation (Custom)

- (AVIMTypedMessage *)lastMessage {
    return objc_getAssociatedObject(self, &ObjectTagKeyLastMessage);
}

- (void)setLastMessage:(AVIMTypedMessage *)_lastMessage {
    objc_setAssociatedObject(self, &ObjectTagKeyLastMessage, _lastMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)unreadCount {
    return [objc_getAssociatedObject(self, @selector(unreadCount)) integerValue];
}

- (void)setUnreadCount:(NSInteger)_unreadCount {
    objc_setAssociatedObject(self, @selector(unreadCount), @(_unreadCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mentioned {
    return [objc_getAssociatedObject(self, &ObjectTagKeyMentioned) boolValue];
}

- (void)setMentioned:(BOOL)_mentioned {
    objc_setAssociatedObject(self, &ObjectTagKeyMentioned, @(_mentioned), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)updatedTime {
    return objc_getAssociatedObject(self, &ObjectTagKeyUpdatedTime);
}
- (void)setUpdatedTime:(NSDate *)_updatedTime {
    objc_setAssociatedObject(self, &ObjectTagKeyUpdatedTime, _updatedTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDConvType)type {
    return [[self.attributes objectForKey:CONV_TYPE] intValue];
}
- (NSString *)ezgoalType {
    return Trim(self.attributes[kParamEzgoalType]);
}
- (RescueStatusType)ezgoalStatus {
    return [self.attributes[kParamEzgoalStatus] integerValue];
}
- (NSString *)rescueId {
    return Trim(self.attributes[kParamRescueId]);
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
        if ([members[0] isEqualToString:[CDChatManager manager].selfId]) {
            return @"";
        }
        else {
            return members[0];
        }
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
