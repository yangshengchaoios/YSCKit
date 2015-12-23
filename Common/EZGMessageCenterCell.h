//
//  EZGCustomerServiceCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/13.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "JSBadgeView.h"
#import "CDConversationStore.h"
#import "CDMessageHelper.h"

/*
 *  消息cell基类
 */
@interface EZGMessageCenterCell : YSCBaseTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timePassedLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastMessageLabel;
@property (nonatomic, weak) IBOutlet UIView *badgeBkgView;//专门用来放badgeView的
@property (nonatomic, strong) JSBadgeView *badgeView;

@end
