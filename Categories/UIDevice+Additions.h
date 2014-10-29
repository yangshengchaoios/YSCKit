//
//  UIDevice+Additions.h
//  TGO2
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>
enum {
    DeviceTypeUnknown = 0,
    DeviceTypeiPhone320x480,        // iPhone 1,3,3GS 标准分辨率(320x480px)
    DeviceTypeiPhone640x960,        // iPhone 4,4S 高清分辨率(640x960px)
    DeviceTypeiPhone640x1136,       // iPhone 5,5c,5s 高清分辨率(640x1136px)
    DeviceTypeiPhone750x1334,       // iPhone 6 (750x1334px)
    DeviceTypeiPhone1080x1920,      // iPhone 6 plus (1080x1920px)
    
    DeviceTypeiPad1024x768,         // iPad 1,2 标准分辨率(1024x768px)
    DeviceTypeiPad2048x1536         // iPad 3 High Resolution(2048x1536px)
    
    //TODO:ipad mini
    
}; typedef NSUInteger DeviceType;

@interface UIDevice (Additions)
/*
 * Available device memory in MB
 */
@property(readonly) double availableMemory;

- (DeviceType) currentDeviceType;
- (BOOL)isRunningOnSimulator;
- (NSString *) platformString;
@end
