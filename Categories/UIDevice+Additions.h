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
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    DeviceTypeiPhoneStandard      = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    DeviceTypeiPhoneHigh            = 2,
    // iPhone 5 高清分辨率(640x1136px)
    DeviceTypeiPhoneTallerHigh      = 3,
    // iPad 1,2 标准分辨率(1024x768px)
    DeviceTypeiPadStandard        = 4,
    // iPad 3 High Resolution(2048x1536px)
    DeviceTypeiPadHigh              = 5
}; typedef NSUInteger DeviceType;

@interface UIDevice (Additions)
/*
 * Available device memory in MB
 */
@property(readonly) double availableMemory;

- (DeviceType) currentDeviceType;
- (BOOL)isLongScreen;
- (BOOL)isRunningOnSimulator;
- (NSString *) platformString;
@end
