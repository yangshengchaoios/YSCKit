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
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.avatarImageView makeRoundWithRadius:5];
    self.lastMessageLabel.text = self.timePassedLabel.text = nil;
    self.badgeBkgView.backgroundColor = [UIColor clearColor];
}
+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    if ([object isKindOfClass:[NSNull class]]) {
        return AUTOLAYOUT_LENGTH(20);
    }
    else {
        return AUTOLAYOUT_LENGTH(120);
    }
}
- (void)layoutObject:(AVIMConversation *)conversation {
    if (isNotEmpty(conversation)) {
        [self layoutConversationByConvId:conversation.conversationId];
        ChatUserModel *cUser = [[ChatUserModel alloc] initWithString:conversation.attributes[OtherUserInfo] error:nil];
        [self.avatarImageView setImageWithURLString:cUser.avatarUrl placeholderImageName:@"default_avatar" withFadeIn:NO];
        self.nameLabel.text = Trim(cUser.realName);
    }
}
- (void)layoutConversationByConvId:(NSString *)convId {
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
