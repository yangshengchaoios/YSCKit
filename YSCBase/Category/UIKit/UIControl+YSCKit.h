//
//  UIControl+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//


//==============================================================================
//
//  封装事件的添加
//  @Author: Builder
//
//==============================================================================
@interface UIControl (YSCKit)
// add event
- (void)ysc_addTouchUpInsideEventBlock:(void (^)(id sender))block;
- (void)ysc_addBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents;
//  first remove then add
- (void)ysc_reAddTouchUpInsideEventBlock:(void (^)(id sender))block;
- (void)ysc_reAddBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents;
// remove event
- (void)ysc_removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;
@end
