//
//  EZGMessageBaseCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageStatusView.h"

//基类cell布局参数
#define kXHLabelPadding             AUTOLAYOUT_LENGTH(20)   //timeStampLabel上下间隔
#define kXHTimeStampLabelHeight     AUTOLAYOUT_LENGTH(40)   //timeStampLabel高度
#define kXHAvatorPadding            AUTOLAYOUT_LENGTH(20)   //头像与父view左边间隔
#define kXHAvatarImageSize          AUTOLAYOUT_LENGTH(80)   //头像的长宽
#define kXHBubbleMessageViewPadding 0//AUTOLAYOUT_LENGTH(10)   //气泡两边间隔
#define kXHStatusViewWidth          AUTOLAYOUT_LENGTH(80)   //消息发送状态宽度
#define kXHStatusViewHeight         AUTOLAYOUT_LENGTH(40)   //消息发送状态高度

//气泡内部间隔参数
#define kXHBubbleMarginVer          AUTOLAYOUT_LENGTH(20)   //内容距离气泡的上下边距
#define kXHBubbleMarginHor          AUTOLAYOUT_LENGTH(20)   //内容距离气泡的左右边距
#define kXHBubbleMarginVerOffset    AUTOLAYOUT_LENGTH(5)    //气泡可见边缘的上下边距
#define kXHBubbleArrowWidth         AUTOLAYOUT_LENGTH(25)   //气泡箭头宽度
#define kXHBubbleTailWidth          AUTOLAYOUT_LENGTH(13)   //气泡箭头相反方向的边距

#define kBubbleTextFont             AUTOLAYOUT_FONT(30)
#define kBubbleTitleFont            AUTOLAYOUT_FONT(24)
#define kBubbleTitleFontColor       RGB(85, 85, 85)
#define kBubbleDetailFont           AUTOLAYOUT_FONT(24)
#define kBubbleDetailFontColor      [UIColor blackColor]
#define kBubbleServiceWidth         AUTOLAYOUT_LENGTH(300 + 14)//服务特殊会话的气泡宽度
#define kBubbleServiceTextWidth     (kBubbleServiceWidth - kXHBubbleMarginHor * 2 - kXHBubbleArrowWidth - kXHBubbleTailWidth) // 特殊服务会话的文本最大宽度

//文本最大宽度
#define kMaxTextWidth               (SCREEN_WIDTH - 2 * (kXHAvatorPadding + kXHAvatarImageSize + kXHBubbleMessageViewPadding + kXHBubbleMarginHor) - kXHBubbleArrowWidth - kXHBubbleTailWidth)

typedef NS_ENUM(NSInteger, EZGBubbleMessageType) {
    EZGBubbleMessageTypeSending = 0,
    EZGBubbleMessageTypeReceiving
};


@interface EZGMessageBaseCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeStampLabel;       //时间戳
@property (strong, nonatomic) UIImageView *avatarImageView;  //用户头像
@property (strong, nonatomic) UIImageView *bubbleImageView;  //气泡图片
@property (strong, nonatomic) XHMessageStatusView *statusView;//发送消息的状态
@property (strong, nonatomic) AVIMTypedMessage *typedMessage;

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView;
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView;

#pragma mark - 计算大小
//动态计算图片显示的大小，等比例缩放，填满
+ (CGSize)SizeForPhoto:(UIImage *)photo;
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMTypedMessage *)message;
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp;
//计算内容部分的坐标和大小
- (CGRect)calculateContentFrame;

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp;
//判断消息的方向
- (EZGBubbleMessageType)bubbleMessageType;
//格式化消息时间
- (NSString *)formatMessageTimeByTimeStamp:(int64_t)timeStamp;
- (NSString *)formatMessageTimeByDate:(NSDate *)messageDate;


#pragma mark - Long Press Gesture
//自动判断是否添加
- (void)addLongPressGesture;

@end
