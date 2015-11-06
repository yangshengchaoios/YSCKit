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
#define kXHBubbleMessageViewPadding AUTOLAYOUT_LENGTH(10)   //气泡两边间隔
#define kXHStatusViewWidth          AUTOLAYOUT_LENGTH(80)   //消息发送状态宽度
#define kXHStatusViewHeight         AUTOLAYOUT_LENGTH(40)   //消息发送状态高度

//气泡内部间隔参数
#define kXHBubbleMarginTop          AUTOLAYOUT_LENGTH(16)   //内容距离气泡的上边距
#define kXHBubbleMarginLeft         AUTOLAYOUT_LENGTH(16)   //内容距离气泡的左边距
#define kXHBubbleMarginBottom       AUTOLAYOUT_LENGTH(16)   //内容距离气泡的下边距
#define kXHBubbleMarginRight        AUTOLAYOUT_LENGTH(16)   //内容距离气泡的右边距
#define kXHBubbleArrowWidth         AUTOLAYOUT_LENGTH(14)   //气泡箭头宽度

// image STRETCH
#define XH_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])


@interface EZGMessageBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;       //时间戳
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;  //用户头像
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;  //气泡图片
@property (weak, nonatomic) IBOutlet XHMessageStatusView *statusView;//发送消息的状态
@property (weak, nonatomic) AVIMTypedMessage *typedMessage;

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

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp;
//判断消息的方向
- (XHBubbleMessageType)bubbleMessageType;
//格式化消息时间
- (NSString *)formatMessageTimeByTimeStamp:(int64_t)timeStamp;
- (NSString *)formatMessageTimeByDate:(NSDate *)messageDate;

@end
