//
//  EZGMessageCenterCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/13.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "EZGMessageCenterCell.h"

@implementation EZGMessageCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.avatarImageView makeRoundWithRadius:5];
    self.lastMessageLabel.text = self.timePassedLabel.text = nil;
    self.badgeBkgView.backgroundColor = [UIColor clearColor];
}
+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(120);
}
- (void)layoutObject:(AVIMConversation *)conversation {
    if (isNotEmpty(conversation)) {
        WEAKSELF
        //启动最后一条聊天记录刷新线程
        if (nil == conversation.lastMessage) {
            self.badgeView.hidden = YES;
            self.lastMessageLabel.text = self.timePassedLabel.text = nil;
            [conversation queryMessagesWithLimit:1 callback:^(NSArray *objects, NSError *error) {
                if (isNotEmpty(objects)) {
                    [[CDConversationStore store] updateLastMessage:objects[0] byConvId:conversation.conversationId];
                    [weakSelf layoutLastMessageByConvId:conversation.conversationId];
                }
            }];
        }
        else {
            [self layoutLastMessageByConvId:conversation.conversationId];
        }
        //启动用户信息刷新线程
        ChatUserModel *chatUser = [ChatUserModel GetLocalDataByUserId:conversation.otherId];
        if (nil == chatUser) {
            self.nameLabel.text = nil;
            self.avatarImageView.image = DefaultAvatarImage;
            [ChatUserModel RefreshByUserIds:@[Trim(conversation.otherId)] ezgoalType:conversation.ezgoalType block:^(NSObject *object, NSString *errorMessage) {
                if (isNotEmpty(object)) {
                    ChatUserModel *userModel1 = [ChatUserModel GetLocalDataByUserId:conversation.otherId];
                    [weakSelf.avatarImageView setImageWithURLString:userModel1.avatarUrl placeholderImage:DefaultAvatarImage withFadeIn:NO];
                    weakSelf.nameLabel.text = Trim(userModel1.userName);
                }
            }];
        }
        else {
            [self.avatarImageView setImageWithURLString:chatUser.avatarUrl placeholderImage:DefaultAvatarImage withFadeIn:NO];
            self.nameLabel.text = Trim(chatUser.userName);
        }
    }
}
//显示最后一条消息
- (void)layoutLastMessageByConvId:(NSString *)convId {
    AVIMConversation *conversation = [[CDConversationStore store] selectOneConversationByConvId:convId];//查询本地的conv才会有未读数
    if (conversation) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%ld", (long)conversation.unreadCount];
        self.badgeView.hidden = (conversation.unreadCount == 0);
        if (conversation.lastMessage) {
            self.lastMessageLabel.attributedText = [[CDMessageHelper helper] attributedStringWithMessage:conversation.lastMessage conversation:conversation];
            self.timePassedLabel.text = [NSDate TimePassedByStartDate:[NSDate dateWithTimeIntervalSince1970:conversation.lastMessage.sendTimestamp / 1000]];
        }
        else {
            self.badgeView.hidden = YES;
            self.lastMessageLabel.text = self.timePassedLabel.text = nil;
        }
    }
    else {
        self.badgeView.hidden = YES;
        self.lastMessageLabel.text = self.timePassedLabel.text = nil;
    }
}
- (JSBadgeView *)badgeView {
    if (nil == _badgeView) {
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.badgeBkgView alignment:JSBadgeViewAlignmentCenter];
    }
    return _badgeView;
}

@end
