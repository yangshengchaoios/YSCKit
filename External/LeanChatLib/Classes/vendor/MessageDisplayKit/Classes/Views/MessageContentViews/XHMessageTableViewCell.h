//
//  XHMessageTableViewCell.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XHBaseTableViewCell.h"
#import "XHMessageBubbleView.h"
#import "UIView+XHRemoteImage.h"
#import "LKBadgeView.h"

@class XHMessageTableViewCell;

@protocol XHMessageTableViewCellDelegate <NSObject>

@optional
//点击多媒体消息的时候统一触发这个回调
- (void)multiMediaMessageDidSelectedOnMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell;
//双击文本消息，触发这个回调
- (void)didDoubleSelectedOnTextMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath;
//点击消息发送者的头像回调方法
- (void)didSelectedAvatorOnMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath;
//Menu Control Selected Item
- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType;
//点击重发消息按钮
- (void)didRetrySendMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath*)indexPath;

@end

@interface XHMessageTableViewCell : XHBaseTableViewCell

@property (nonatomic, weak) id <XHMessageTableViewCellDelegate> delegate;
@property (nonatomic, weak, readonly) XHMessageBubbleView *messageBubbleView;////自定义多媒体消息内容View
@property (nonatomic, weak, readonly) UIButton *avatorButton;
@property (nonatomic, weak, readonly) LKBadgeView *timestampLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;//Cell所在的位置，用于Cell delegate回调

//获取消息类型
- (XHBubbleMessageType)bubbleMessageType;

//初始化Cell的方法，必须先调用这个，不然不会初始化显示控件
- (instancetype)initWithMessage:(id <XHMessageModel>)message reuseIdentifier:(NSString *)cellIdentifier;

//根据消息Model配置Cell的显示内容
- (void)configureCellWithMessage:(id <XHMessageModel>)message
               displaysTimestamp:(BOOL)displayTimestamp;

//根据消息Model计算Cell的高度
+ (CGFloat)calculateCellHeightWithMessage:(id <XHMessageModel>)message
                        displaysTimestamp:(BOOL)displayTimestamp;

@end
