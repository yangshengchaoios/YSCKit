//
//  UIGestureRecognizer+YSCKit.m
//  YSCKitDemo
//
//  Created by Builder on 16/8/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <objc/runtime.h>
#import "UIGestureRecognizer+YSCKit.h"

static const void *YSCGestureRecognizerBlockKey = &YSCGestureRecognizerBlockKey;
static const void *YSCGestureRecognizerDelayKey = &YSCGestureRecognizerDelayKey;

@implementation UIGestureRecognizer (YSCKit)

+ (instancetype)ysc_recognizerWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block {
    return [[[self class] alloc] ysc_initWithBlock:block delay:0.0];
}
+ (instancetype)ysc_recognizerWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
                        delay:(NSTimeInterval)delay {
    return [[[self class] alloc] ysc_initWithBlock:block delay:delay];
}

- (instancetype)ysc_initWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block {
    return [self ysc_initWithBlock:block delay:0.0];
}
- (instancetype)ysc_initWithBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
                  delay:(NSTimeInterval)delay {
    UIGestureRecognizer *gestureRecognizer = [self initWithTarget:self action:@selector(_ysc_handleAction:)];
    if (gestureRecognizer) {
        gestureRecognizer.ysc_handleBlock = block;
        gestureRecognizer.ysc_handleBlockDelay = delay;
    }
    return gestureRecognizer;
}

- (void)_ysc_handleAction:(UIGestureRecognizer *)recognizer {
    if ( ! recognizer.ysc_handleBlock) {
        return;
    }
    
    NSTimeInterval delay = recognizer.ysc_handleBlockDelay;
    CGPoint location = [self locationInView:self.view];
    void (^block)(void) = ^{
        recognizer.ysc_handleBlock(self, self.state, location);
    };
    
    if (fabs(0 - delay) < 0.000001) {
        block();
    }
    else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), block);
    }
}


#pragma mark - Properties
- (void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))ysc_handleBlock {
    return objc_getAssociatedObject(self, YSCGestureRecognizerBlockKey);
}
- (void)ysc_setHandleBlock:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block {
    objc_setAssociatedObject(self, YSCGestureRecognizerBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSTimeInterval)ysc_handleBlockDelay {
    return [objc_getAssociatedObject(self, YSCGestureRecognizerDelayKey) doubleValue];
}
- (void)ysc_setHandleBlockDelay:(NSTimeInterval)delay {
    NSNumber *delayValue = delay ? @(delay) : nil;
    objc_setAssociatedObject(self, YSCGestureRecognizerDelayKey, delayValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
