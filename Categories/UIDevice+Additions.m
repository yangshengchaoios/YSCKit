//
//  UIDevice+Additions.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "UIDevice+Additions.h"
#include <sys/sysctl.h>
#include <mach/mach.h>

@implementation UIDevice (Additions)
//可用内存(参考)
- (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


/******************************************************************************
 函数名称 : - (DeviceType) currentDeviceType
 函数描述 : 获取当前分辨率
 ******************************************************************************/
+ (DeviceType) currentDeviceType {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){//iphone设备
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width  * [UIScreen mainScreen].scale,
                                     [[UIScreen mainScreen] bounds].size.height * [UIScreen mainScreen].scale);
            if (480 == size.height) {
                return DeviceTypeiPhone320x480;
            }
            else if (960 == size.height) {
                return DeviceTypeiPhone640x960;
            }
            else if (1136 == size.height) {
                return DeviceTypeiPhone640x1136;
            }
            else if (1334 == size.height) {
                return DeviceTypeiPhone750x1334;
            }
            else if (2208 == size.height) {
                return DeviceTypeiPhone1242x2208;
            }
            else {
                return DeviceTypeUnknown;
            }
        }
        else {
            return DeviceTypeiPhone320x480;
        }
    }
    else {//iPad设备
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width  * [UIScreen mainScreen].scale,
                                     [[UIScreen mainScreen] bounds].size.height * [UIScreen mainScreen].scale);
            if (768 == size.height) {
                return DeviceTypeiPad1024x768;
            }
            else if (1536 == size.height) {
                return DeviceTypeiPad2048x1536;
            }
            else {
                return DeviceTypeUnknown;
            }
        }
        else {
            return DeviceTypeiPad1024x768;
        }
    }
}

/******************************************************************************
 函数名称 : - (BOOL)isRunningOnSimulator
 函数描述 : 判断是否运行在模拟器上
 ******************************************************************************/
+ (BOOL)isRunningOnSimulator{
#if defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}


/******************************************************************************
 函数名称 : - (NSString *) platformString
 函数描述 : 返回平台名称
 ******************************************************************************/
+ (NSString *) platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    return @"";
}

@end
