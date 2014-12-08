//
//  UIDevice+Additions.h
//  KQ
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>
enum {
    DeviceTypeUnknown = 0,
    DeviceTypeiPhone320x480,        // iPhone 1,3,3GS (320x480px)
    DeviceTypeiPhone640x960,        // iPhone 4,4S (640x960px)
    DeviceTypeiPhone640x1136,       // iPhone 5,5c,5s (640x1136px)
    DeviceTypeiPhone750x1334,       // iPhone 6 (750x1334px)
    DeviceTypeiPhone1242x2208,      // iPhone 6 plus (1242x2208px)
    
    DeviceTypeiPad1024x768,         // iPad 1,2 (1024x768px)
    DeviceTypeiPad2048x1536         // iPad 3 High Resolution(2048x1536px)
    
    //TODO:ipad mini
    
}; typedef NSUInteger DeviceType;

@interface UIDevice (Additions)
/*
 * Available device memory in MB
 */
@property(readonly) double availableMemory;

+ (DeviceType) currentDeviceType;
+ (BOOL)isRunningOnSimulator;
+ (NSString *) platformString;
@end
