//
//  EZGMessageBaseCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"
#import "CDChatManager.h"

@implementation EZGMessageBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.bubbleImageView.clipsToBounds = YES;
    self.timeStampLabel.font = AUTOLAYOUT_FONT(self.timeStampLabel.font.pointSize);
    self.timeStampLabel.top = kXHLabelPadding;
    self.timeStampLabel.height = kXHTimeStampLabelHeight;
    self.avatarImageView.width = self.avatarImageView.height = kXHAvatarImageSize;
    self.statusView.width = kXHStatusViewWidth;
    self.statusView.height = kXHStatusViewHeight;
}

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerNib:[[self class] NibNameOfCell] forCellReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView {
    EZGMessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] identifier]];
    return cell;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)NibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算大小
//动态计算图片显示的大小，等比例缩放，填满
+ (CGSize)SizeForPhoto:(UIImage *)photo {
    //TODO:需要判断空、根据image大小来设置
    CGSize photoSize = CGSizeMake(120, 120);
    return photoSize;
}
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMTypedMessage *)message {
    return CGSizeZero;
}
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    //提前下载文件
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片、音频、视频
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
        }];
    }
    
    CGFloat timestampHeight = displayTimestamp ? (kXHTimeStampLabelHeight + kXHLabelPadding * 2) : kXHLabelPadding;
    CGFloat avatarHeight = kXHAvatarImageSize;
    CGFloat bubbleHeight = [self BubbleFrameWithMessage:message].height;
    return timestampHeight + MAX(avatarHeight, bubbleHeight) + kXHLabelPadding;
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    self.typedMessage = message;
    
    //1. 设置时间
    self.timeStampLabel.hidden = ! displayTimestamp;
    if (displayTimestamp) {
        self.timeStampLabel.text = [self formatMessageTimeByTimeStamp:message.sendTimestamp];
    }
    
    //2. 设置头像
    if (message.attributes[MParamAvatarUrl]) {//如果消息中带有头像地址就直接显示该头像
        [self.avatarImageView setImageWithURLString:message.attributes[MParamAvatarUrl]];
    }
    else {
        if (XHBubbleMessageTypeSending == [self bubbleMessageType]) {//自己的头像
            [self.avatarImageView setImageWithURLString:USER.userAvatar];
        }
        else {//对方的头像
            [self.avatarImageView setImageWithURLString:APPDATA.chatUser.avatarUrl];
        }
    }
    
    //3. 设置气泡图片
    if (message.mediaType >= EZGMessageTypeScene) {//自定义消息类型固定为白色背景
        //TODO:固定为白色
    }
    else {
        
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL displayTimestamp = ! self.timeStampLabel.hidden;
    CGFloat layoutOriginY = kXHLabelPadding;
    //调整timeStampLabel位置
    if (displayTimestamp) {
        [self.timeStampLabel sizeToFit];
        self.timeStampLabel.centerX = SCREEN_WIDTH / 2;
        self.timeStampLabel.width += 4;
        layoutOriginY += kXHTimeStampLabelHeight + kXHLabelPadding;
    }
    
    //调整头像位置
    self.avatarImageView.top = layoutOriginY;
    if (XHBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.avatarImageView.left = kXHAvatorPadding;
    }
    else {
        self.avatarImageView.right = SCREEN_WIDTH - kXHAvatorPadding;
    }
    
    //重新调整气泡位置和大小
    self.bubbleImageView.top = self.avatarImageView.top;
    if (XHBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleImageView.left = CGRectGetMaxX(self.avatarImageView.frame) + kXHBubbleMessageViewPadding;
    }
    else {
        self.bubbleImageView.right = self.avatarImageView.left - kXHBubbleMessageViewPadding;
    }
    self.bubbleImageView.size = [self.class BubbleFrameWithMessage:self.typedMessage];
    
    //重新调整statusView位置
    if(XHBubbleMessageTypeSending == [self bubbleMessageType]) {
        self.statusView.hidden = NO;
        self.statusView.centerY = self.bubbleImageView.centerY;
        self.statusView.right = self.bubbleImageView.left - kXHBubbleMessageViewPadding;
    }
    else {
        self.statusView.hidden = YES;
    }
}
//判断消息的方向
- (XHBubbleMessageType)bubbleMessageType {
    if ([[CDChatManager manager].selfId isEqualToString:self.typedMessage.clientId]) {
        return XHBubbleMessageTypeSending;
    }
    else {
        return XHBubbleMessageTypeReceiving;
    }
}
//格式化消息时间
- (NSString *)formatMessageTimeByTimeStamp:(int64_t)timeStamp {
    NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
    return [self formatMessageTimeByDate:sendDate];
}
- (NSString *)formatMessageTimeByDate:(NSDate *)messageDate {
    NSString *dateText = [messageDate stringWithFormat:@"yyyy-M-d"];
    NSString *timeText = [messageDate stringWithFormat:@"HH:mm"];
    if ([messageDate isThisYear]) {
        if ([messageDate isToday]) {
            dateText = NSLocalizedStringFromTable(@"Today", @"MessageDisplayKitString", @"今天");
        }
        else if ([messageDate isYesterday]) {
            dateText = NSLocalizedStringFromTable(@"Yesterday", @"MessageDisplayKitString", @"昨天");
        }
        else {
            dateText = [messageDate stringWithFormat:@"M-d"];
        }
    }
    return [NSString stringWithFormat:@"%@ %@",dateText,timeText];
}

@end
