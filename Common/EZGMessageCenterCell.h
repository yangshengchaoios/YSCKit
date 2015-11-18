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
#import "DateTools.h"

/*
 *  消息cell基类
 */
@interface EZGMessageCenterCell : YSCBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (nonatomic, weak) IBOutlet UIView *badgeBkgView;//专门用来放badgeView的
@property (nonatomic, strong) JSBadgeView *badgeView;

- (void)layoutConversationByConvId:(NSString *)convId;

@end
