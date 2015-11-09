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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
        
        self.timeStampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.statusView = [[XHMessageStatusView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.timeStampLabel];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bubbleImageView];
        [self.contentView addSubview:self.statusView];
    }
    return self;
}

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerClass:self.class forCellReuseIdentifier:NSStringFromClass(self.class)];
}
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView {
    EZGMessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    return cell;
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
//计算内容部分的坐标和大小
//TODO:如何转换成edgeInsets？
- (CGRect)calculateContentFrame {
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        return CGRectOffset(CGRectInset(self.bubbleImageView.frame,
                                        AUTOLAYOUT_LENGTH(15) + kXHBubbleMarginHor,
                                        AUTOLAYOUT_LENGTH(5) + kXHBubbleMarginVer),
                            AUTOLAYOUT_LENGTH(6), 0);
    }
    else {
        return CGRectOffset(CGRectInset(self.bubbleImageView.frame,
                                        AUTOLAYOUT_LENGTH(15) + kXHBubbleMarginHor,
                                        AUTOLAYOUT_LENGTH(5) + kXHBubbleMarginVer),
                            -AUTOLAYOUT_LENGTH(6), 0);
    }
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
        if (EZGBubbleMessageTypeSending == [self bubbleMessageType]) {//自己的头像
            [self.avatarImageView setImageWithURLString:USER.userAvatar];
        }
        else {//对方的头像
            [self.avatarImageView setImageWithURLString:APPDATA.chatUser.avatarUrl];
        }
    }
    
    //3. 设置气泡图片
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(30, 28, 85, 28);
    if (message.mediaType >= EZGMessageTypeScene) {//TODO:自定义消息类型固定为白色背景
        if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
            self.bubbleImageView.image = [[UIImage imageNamed:@"weChatBubble_Receiving_Solid"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
        else {
            self.bubbleImageView.image = [[UIImage imageNamed:@"weChatBubble_Sending_Solid"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
    }
    else {
        if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
            self.bubbleImageView.image = [[UIImage imageNamed:@"weChatBubble_Receiving_Solid"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
        else {
            self.bubbleImageView.image = [[UIImage imageNamed:@"weChatBubble_Sending_Solid"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.bubbleImageView.clipsToBounds = YES;
    self.timeStampLabel.font = [UIFont systemFontOfSize:13];
    self.contentView.backgroundColor = [UIColor randomColor];
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
    self.bubbleImageView.clipsToBounds = YES;
    self.bubbleImageView.backgroundColor = [UIColor redColor];
    self.timeStampLabel.font = [UIFont systemFontOfSize:13];
    self.timeStampLabel.top = kXHLabelPadding;
    self.timeStampLabel.height = kXHTimeStampLabelHeight;
    self.avatarImageView.width = kXHAvatarImageSize;
    self.avatarImageView.height = kXHAvatarImageSize;
    self.statusView.width = kXHStatusViewWidth;
    self.statusView.height = kXHStatusViewHeight;
    
    self.avatarImageView.top = layoutOriginY;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.avatarImageView.left = kXHAvatorPadding;
    }
    else {
        self.avatarImageView.left = SCREEN_WIDTH - kXHAvatorPadding - kXHAvatarImageSize;
    }
    
    //重新调整气泡位置和大小
    self.bubbleImageView.top = self.avatarImageView.top;
    self.bubbleImageView.size = [self.class BubbleFrameWithMessage:self.typedMessage];
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleImageView.left = kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding;
    }
    else {
        self.bubbleImageView.left = self.avatarImageView.left - (kXHBubbleMessageViewPadding + self.bubbleImageView.width);
    }
    
    //重新调整statusView位置
    if(EZGBubbleMessageTypeSending == [self bubbleMessageType]) {
        self.statusView.hidden = YES;
        self.statusView.centerY = self.bubbleImageView.centerY;
        self.statusView.left = self.bubbleImageView.left - (kXHBubbleMessageViewPadding + kXHStatusViewWidth);
    }
    else {
        self.statusView.hidden = YES;
    }
}
//判断消息的方向
- (EZGBubbleMessageType)bubbleMessageType {
    if ([[CDChatManager manager].selfId isEqualToString:self.typedMessage.clientId]) {
        return EZGBubbleMessageTypeSending;
    }
    else {
        return EZGBubbleMessageTypeReceiving;
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
