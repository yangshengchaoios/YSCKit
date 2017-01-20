//
//  UIDevice+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

/**
 *  判断设备的相关参数
 */
#ifndef SCREEN_WIDTH
    #define SCREEN_WIDTH            ([UIScreen mainScreen].bounds.size.width) //屏幕的宽度(point)
#endif
#ifndef SCREEN_HEIGHT
    #define SCREEN_HEIGHT           ([UIScreen mainScreen].bounds.size.height)//屏幕的高度(point)
#endif
#ifndef IOS7_OR_LATER
    #define IOS7_OR_LATER           __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#endif
#ifndef IOS8_OR_LATER
    #define IOS8_OR_LATER           __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#endif
#ifndef IOS9_OR_LATER
    #define IOS9_OR_LATER           __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#endif

typedef NS_ENUM(NSInteger, YSCDeviceType) {
    YSCDeviceTypeUnknown = 0,
    YSCDeviceTypeiPhone320x480,        // iPhone 1,3,3GS (320x480px)
    YSCDeviceTypeiPhone640x960,        // iPhone 4,4S (640x960px)
    YSCDeviceTypeiPhone640x1136,       // iPhone 5,5c,5s (640x1136px)
    YSCDeviceTypeiPhone750x1334,       // iPhone 6 (750x1334px)
    YSCDeviceTypeiPhone1242x2208,      // iPhone 6 plus (1242x2208px)
    
    YSCDeviceTypeiPad1024x768,         // iPad 1,2 (1024x768px)
    YSCDeviceTypeiPad2048x1536         // iPad 3 High Resolution(2048x1536px)
};


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface UIDevice (YSCKit)

+ (YSCDeviceType)ysc_currentDeviceType;
+ (BOOL)ysc_isPad;
+ (BOOL)ysc_isPhone;
+ (BOOL)ysc_isRunningOnSimulator;

/** device info */
+ (NSString *)ysc_openUdid;
+ (NSString *)ysc_deviceInfo;
+ (NSString *)ysc_stringWithUUID;
+ (NSString *)ysc_machineModel;
+ (NSString *)ysc_machineModelName;

// 只能判断摄像头是否可用，但不能判断是否被用户禁用了!
+ (BOOL)ysc_isCameraAvailable;
+ (BOOL)ysc_isFrontCameraAvailable;
+ (BOOL)ysc_isBackCameraAvailable;

//判断是否可用使用摄像头
+ (BOOL)ysc_isCanUseCamera;
//判断是否可用打电话
+ (BOOL)ysc_isCanMakeCall;
//判断定位是否可用(包括已经授权和没有决定)
+ (BOOL)ysc_isLocationAvaible;
// 相册是否可用
+ (BOOL)ysc_isPhotoLibraryAvailable;
// 照片流是否可用
+ (BOOL)ysc_isSavedPhotosAlbumAvailable;
// 闪光灯是否可用
+ (BOOL)ysc_isCameraFlashAvailable;
// 检测陀螺仪是否可用
+ (BOOL)ysc_isGyroscopeAvailable;
// 检测指南针或磁力计
+ (BOOL)ysc_isHandingAvailable;
// 检查摄像头是否支持录像
+ (BOOL)ysc_isCameraSupportShootingVideos;
// 检查摄像头是否支持拍照
+ (BOOL)ysc_isCameraSupportTakingPhotos;
// 是否可以在相册中选择视频
+ (BOOL)ysc_isCanUserPickVideosFromPhotoLibrary;
// 是否可以在相册中选择图片
+ (BOOL)ysc_isCanUserPickPhotosFromPhotoLibrary;
//强制修改设备的方向
+ (void)ysc_forceToChangeInterfaceOrientation:(UIInterfaceOrientation)orientation;

/** Disk Space */
+ (int64_t)ysc_diskSpace;
+ (int64_t)ysc_diskSpaceFree;
+ (int64_t)ysc_diskSpaceUsed;

/** Memory Information */
+ (int64_t)ysc_memoryTotal;
+ (int64_t)ysc_memoryFree;
+ (int64_t)ysc_memoryErasable;//erasable memory
+ (int64_t)ysc_memoryUsed;// = active + inactive + wired
+ (int64_t)ysc_memoryActive;
+ (int64_t)ysc_memoryInactive;
+ (int64_t)ysc_memoryWired;

/** CPU Information */
+ (NSUInteger)ysc_cpuCount;
+ (float)ysc_cpuUsage;//1.0 means 100%
+ (NSArray *)ysc_cpuUsagePerProcessor;//1.0 means 100%

@end
