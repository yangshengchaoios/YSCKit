//
//  UIControl+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIControl+YSCKit.h"
#import <objc/runtime.h>

@interface _YSCUIControlBlockTarget : NSObject
@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;
- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;
@end
@implementation _YSCUIControlBlockTarget
- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = block;
        _events = events;
    }
    return self;
}
- (void)invoke:(id)sender {
    if (self.block) {
        self.block(sender);
    }
}
@end


//==============================================================================
//
//  封装事件的添加
//  @Author: Builder
//
//==============================================================================
@implementation UIControl (YSCKit)
- (void)ysc_addTouchUpInsideEventBlock:(void (^)(id sender))block {
    [self ysc_addBlock:block forControlEvents:UIControlEventTouchUpInside];
}
- (void)ysc_addBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;
    _YSCUIControlBlockTarget *target = [[_YSCUIControlBlockTarget alloc]
                                        initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self _ysc_allUIControlBlockTargets];
    [targets addObject:target];
}

- (void)ysc_reAddTouchUpInsideEventBlock:(void (^)(id sender))block {
    [self ysc_reAddBlock:block forControlEvents:UIControlEventTouchUpInside];
}
- (void)ysc_reAddBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents {
    [self ysc_removeAllBlocksForControlEvents:controlEvents];
    [self ysc_addBlock:block forControlEvents:controlEvents];
}

- (void)ysc_removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;
    
    NSMutableArray *targets = [self _ysc_allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_YSCUIControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {// 非独立的target需要去掉相应的events
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            }
            else {// 独立的target需要remove
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)_ysc_allUIControlBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, _cmd);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}
@end
