//
//  UIGestureRecognizer+YSCKit.h
//  YSCKitDemo
//
//  Created by Builder on 16/8/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//==============================================================================
//
//  常用手势功能封装
//  @Author: Builder
//
//==============================================================================
@interface UIGestureRecognizer (YSCKit)
@property (nonatomic, copy, setter = ysc_setHandleBlock:) void (^ysc_handleBlock)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location);
@property (nonatomic, setter = ysc_setHandleBlockDelay:) NSTimeInterval ysc_handleBlockDelay;

+ (instancetype)ysc_recognizerWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;
+ (instancetype)ysc_recognizerWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay;

- (instancetype)ysc_initWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;
- (instancetype)ysc_initWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay;

@end
