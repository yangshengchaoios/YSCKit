//
//  EZGMessageBaseCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"
#import "CDChatManager.h"

#define kXHLabelPadding             AUTOLAYOUT_LENGTH(20)   //timeStampLabel上下间隔
#define kXHTimeStampLabelHeight     AUTOLAYOUT_LENGTH(40)   //timeStampLabel高度
#define kXHAvatorPadding            AUTOLAYOUT_LENGTH(20)   //头像与父view左边间隔
#define kXHAvatarImageSize          AUTOLAYOUT_LENGTH(80)   //头像的长宽
#define kXHBubbleMessageViewPadding AUTOLAYOUT_LENGTH(10)   //气泡距离头像间隔
#define kXHStatusViewWidth          AUTOLAYOUT_LENGTH(80)   //
#define kXHStatusViewHeight         AUTOLAYOUT_LENGTH(40)   //

@implementation EZGMessageBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.timeStampLabel.font = AUTOLAYOUT_FONT(22);
    self.timeStampLabel.height = kXHTimeStampLabelHeight;
    self.avatarImageView.width = self.avatarImageView.height = kXHAvatarImageSize;
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

#pragma mark - 计算高度
//动态计算图片显示的高度，等比例缩放，填满
+ (CGSize)SizeForPhoto:(UIImage *)photo {
    //TODO:需要判断空、根据image大小来设置
    CGSize photoSize = CGSizeMake(120, 120);
    return photoSize;
}
//计算气泡高度
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
    //1. 设置时间
    self.timeStampLabel.hidden = ! displayTimestamp;
    if (displayTimestamp) {
        NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:message.sendTimestamp / 1000];;
        NSString *dateText = [sendDate stringWithFormat:@"yyyy-M-d"];
        NSString *timeText = [sendDate stringWithFormat:@"HH:mm"];
        if ([sendDate isThisYear]) {
            if ([sendDate isToday]) {
                dateText = NSLocalizedStringFromTable(@"Today", @"MessageDisplayKitString", @"今天");
            }
            else if ([sendDate isYesterday]) {
                dateText = NSLocalizedStringFromTable(@"Yesterday", @"MessageDisplayKitString", @"昨天");
            }
            else {
                dateText = [sendDate stringWithFormat:@"M-d"];
            }
        }
        self.timeStampLabel.text = [NSString stringWithFormat:@"%@ %@",dateText,timeText];
    }
    self.typedMessage = message;
    //设置头像
    if (XHBubbleMessageTypeSending == [self bubbleMessageType]) {//自己的头像
        [self.avatarImageView setImageWithURLString:USER.userAvatar];
    }
    else {//对方的头像
        [self.avatarImageView setImageWithURLString:APPDATA.chatUser.avatarUrl];
    }
    //设置气泡图片
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

//在显示界面的时候重新根据message来调整元素位置
- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL displayTimestamp = ! self.timeStampLabel.hidden;
    CGFloat layoutOriginY = kXHLabelPadding;
    //调整timeStampLabel位置
    if (displayTimestamp) {
        [self.timeStampLabel sizeToFit];
        self.timeStampLabel.top = kXHLabelPadding;
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
        self.bubbleImageView.right = SCREEN_WIDTH - (CGRectGetMinX(self.avatarImageView.frame) + kXHBubbleMessageViewPadding);
    }
    self.bubbleImageView.size = [self.class BubbleFrameWithMessage:self.typedMessage];
    
    //重新调整statusView位置
    if([self bubbleMessageType] == XHBubbleMessageTypeSending) {
        self.statusView.hidden = NO;
        CGFloat statusX = CGRectGetMinX(self.messageBubbleView.bubbleFrame) - kXHStatusViewWidth - 3;
        CGFloat halfH = self.messageBubbleView.bubbleFrame.size.height / 2;
        CGRect statusFrame = self.statusView.frame;
        statusFrame.origin.y = layoutOriginY + halfH;
        statusFrame.origin.x = statusX;
        self.statusView.frame = statusFrame;
    }
    else {
        self.statusView.hidden = YES;
    }
}

@end
