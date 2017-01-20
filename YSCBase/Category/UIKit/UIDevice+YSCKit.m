//
//  UIDevice+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIDevice+YSCKit.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#include <sys/sysctl.h>
#include <mach/mach.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation UIDevice (YSCKit)
+ (YSCDeviceType)ysc_currentDeviceType {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){//iphone设备
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width  * [UIScreen mainScreen].scale,
                                     [[UIScreen mainScreen] bounds].size.height * [UIScreen mainScreen].scale);
            if (480 == size.height) {
                return YSCDeviceTypeiPhone320x480;
            }
            else if (960 == size.height) {
                return YSCDeviceTypeiPhone640x960;
            }
            else if (1136 == size.height) {
                return YSCDeviceTypeiPhone640x1136;
            }
            else if (1334 == size.height) {
                return YSCDeviceTypeiPhone750x1334;
            }
            else if (2208 == size.height || [UIScreen mainScreen].scale == 3.0f) {
                return YSCDeviceTypeiPhone1242x2208;
            }
            else {
                return YSCDeviceTypeUnknown;
            }
        }
        else {
            return YSCDeviceTypeiPhone320x480;
        }
    }
    else {//iPad设备
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width  * [UIScreen mainScreen].scale,
                                     [[UIScreen mainScreen] bounds].size.height * [UIScreen mainScreen].scale);
            if (768 == size.height) {
                return YSCDeviceTypeiPad1024x768;
            }
            else if (1536 == size.height) {
                return YSCDeviceTypeiPad2048x1536;
            }
            else {
                return YSCDeviceTypeUnknown;
            }
        }
        else {
            return YSCDeviceTypeiPad1024x768;
        }
    }
}
+ (BOOL)ysc_isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
+ (BOOL)ysc_isPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}
+ (BOOL)ysc_isRunningOnSimulator{
    //方法一：
#if defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
    //方法二：
    //    return NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location;
}
+ (BOOL)ysc_isJailbroken {
    //1. 判断是否是模拟器
    if ([self ysc_isRunningOnSimulator]) {
        return NO;
    }
    //2. 判断cydia能否打开
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    //3. 判断常见的越狱文件是否存在
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    //4. 判断bash是否可读
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    //5. 判断是否可以在private中写文件
    NSString *path = [NSString stringWithFormat:@"/private/%@", [UIDevice ysc_stringWithUUID]];
    if ([@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    return NO;
}

/** device info */
+ (NSString *)ysc_openUdid {
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = @"";
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    if ([deviceID isKindOfClass:[NSString class]] &&
        OBJECT_ISNOT_EMPTY(deviceID)) {
        return deviceID;
    }
    else {
        return @"";
    }
}
+ (NSString *)ysc_deviceInfo {
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"%@;", [UIDevice currentDevice].name];
    [info appendFormat:@"%@;", [UIDevice currentDevice].systemName];
    [info appendFormat:@"%@;", [UIDevice currentDevice].systemVersion];
    return info;
}
+ (NSString *)ysc_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}
+ (NSString *)ysc_machineModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *model = [NSString stringWithUTF8String:machine];
    free(machine);
    return model;
}
+ (NSString *)ysc_machineModelName {
    NSString *model = [self ysc_machineModel];
    if ( ! model) {
        return nil;
    }
    NSDictionary *dic = @{
                          @"Watch1,1" : @"Apple Watch",
                          @"Watch1,2" : @"Apple Watch",
                          
                          @"iPod1,1" : @"iPod touch 1",
                          @"iPod2,1" : @"iPod touch 2",
                          @"iPod3,1" : @"iPod touch 3",
                          @"iPod4,1" : @"iPod touch 4",
                          @"iPod5,1" : @"iPod touch 5",
                          @"iPod7,1" : @"iPod touch 6",
                          
                          @"iPhone1,1" : @"iPhone 1G",
                          @"iPhone1,2" : @"iPhone 3G",
                          @"iPhone2,1" : @"iPhone 3GS",
                          @"iPhone3,1" : @"iPhone 4 (GSM)",
                          @"iPhone3,2" : @"iPhone 4",
                          @"iPhone3,3" : @"iPhone 4 (CDMA)",
                          @"iPhone4,1" : @"iPhone 4S",
                          @"iPhone5,1" : @"iPhone 5",
                          @"iPhone5,2" : @"iPhone 5",
                          @"iPhone5,3" : @"iPhone 5c",
                          @"iPhone5,4" : @"iPhone 5c",
                          @"iPhone6,1" : @"iPhone 5s",
                          @"iPhone6,2" : @"iPhone 5s",
                          @"iPhone7,1" : @"iPhone 6 Plus",
                          @"iPhone7,2" : @"iPhone 6",
                          @"iPhone8,1" : @"iPhone 6s",
                          @"iPhone8,2" : @"iPhone 6s Plus",
                          
                          @"iPad1,1" : @"iPad 1",
                          @"iPad2,1" : @"iPad 2 (WiFi)",
                          @"iPad2,2" : @"iPad 2 (GSM)",
                          @"iPad2,3" : @"iPad 2 (CDMA)",
                          @"iPad2,4" : @"iPad 2",
                          @"iPad2,5" : @"iPad mini 1",
                          @"iPad2,6" : @"iPad mini 1",
                          @"iPad2,7" : @"iPad mini 1",
                          @"iPad3,1" : @"iPad 3 (WiFi)",
                          @"iPad3,2" : @"iPad 3 (4G)",
                          @"iPad3,3" : @"iPad 3 (4G)",
                          @"iPad3,4" : @"iPad 4",
                          @"iPad3,5" : @"iPad 4",
                          @"iPad3,6" : @"iPad 4",
                          @"iPad4,1" : @"iPad Air",
                          @"iPad4,2" : @"iPad Air",
                          @"iPad4,3" : @"iPad Air",
                          @"iPad4,4" : @"iPad mini 2",
                          @"iPad4,5" : @"iPad mini 2",
                          @"iPad4,6" : @"iPad mini 2",
                          @"iPad4,7" : @"iPad mini 3",
                          @"iPad4,8" : @"iPad mini 3",
                          @"iPad4,9" : @"iPad mini 3",
                          @"iPad5,1" : @"iPad mini 4",
                          @"iPad5,2" : @"iPad mini 4",
                          @"iPad5,3" : @"iPad Air 2",
                          @"iPad5,4" : @"iPad Air 2",
                          
                          @"i386" : @"Simulator x86",
                          @"x86_64" : @"Simulator x64",
                          };
    NSString *name = dic[model];
    if ( ! name) {
        name = model;
    }
    return name;
}

/** check available */
+ (BOOL)ysc_isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
+ (BOOL)ysc_isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
+ (BOOL)ysc_isBackCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
+ (BOOL)ysc_isCanUseCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (AVAuthorizationStatusAuthorized == status) || (AVAuthorizationStatusNotDetermined == status);
}
+ (BOOL)ysc_isCanMakeCall {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}
+ (BOOL)ysc_isLocationAvaible {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL isAppAuthorized = (kCLAuthorizationStatusAuthorizedWhenInUse == status ||
                            kCLAuthorizationStatusAuthorizedAlways == status ||
                            kCLAuthorizationStatusNotDetermined == status);
    return [CLLocationManager locationServicesEnabled] && isAppAuthorized;
}
+ (BOOL)ysc_isPhotoLibraryAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL)ysc_isSavedPhotosAlbumAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}
+ (BOOL)ysc_isCameraFlashAvailable {
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}
+ (BOOL)ysc_isGyroscopeAvailable {
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    return motionManager.gyroAvailable;
}
+ (BOOL)ysc_isHandingAvailable {
    return [CLLocationManager headingAvailable];
}
+ (BOOL)ysc_isCameraSupportShootingVideos {
    return [self ysc_isCameraSupportsMedia:(NSString *)kUTTypeMovie
                            sourceType:UIImagePickerControllerSourceTypeCamera];
}
+ (BOOL)ysc_isCameraSupportTakingPhotos {
    return [self ysc_isCameraSupportsMedia:(NSString *)kUTTypeImage
                            sourceType:UIImagePickerControllerSourceTypeCamera];
}
+ (BOOL)ysc_isCanUserPickVideosFromPhotoLibrary {
    return [self ysc_isCameraSupportsMedia:(NSString *)kUTTypeMovie
                            sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL)ysc_isCanUserPickPhotosFromPhotoLibrary {
    return [self ysc_isCameraSupportsMedia:(NSString *)kUTTypeImage
                            sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL)ysc_isCameraSupportsMedia:(NSString *)paramMediaType
                       sourceType:(UIImagePickerControllerSourceType)paramSourceType {
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
+ (void)ysc_forceToChangeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIApplication sharedApplication] statusBarOrientation] == orientation) {
        return;// 只有当设备方向不一致时才发消息
    }
#if __has_feature(objc_arc)
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
#else
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                       withObject:@(orientation)];
    }
#endif
}

/** Disk Space */
+ (int64_t)ysc_diskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] unsignedLongLongValue];
    if (space < 0) space = -1;
    return space;
}
+ (int64_t)ysc_diskSpaceFree {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    if (space < 0) space = -1;
    return space;
}
+ (int64_t)ysc_diskSpaceUsed {
    int64_t total = [self ysc_diskSpace];
    int64_t free = [self ysc_diskSpaceFree];
    if (total < 0 || free < 0) return -1;
    int64_t used = total - free;
    if (used < 0) used = -1;
    return used;
}

/** Memory Information */
+ (int64_t)ysc_memoryTotal {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}
+ (int64_t)ysc_memoryFree {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}
+ (int64_t)ysc_memoryErasable {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.purgeable_count * page_size;
}
+ (int64_t)ysc_memoryUsed {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return page_size * (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count);
}
+ (int64_t)ysc_memoryActive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}
+ (int64_t)ysc_memoryInactive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.inactive_count * page_size;
}
+ (int64_t)ysc_memoryWired {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.wire_count * page_size;
}

/** CPU Information */
+ (NSUInteger)ysc_cpuCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}
+ (float)ysc_cpuUsage {
    float cpu = 0;
    NSArray *cpus = [self ysc_cpuUsagePerProcessor];
    if (cpus.count == 0) return -1;
    for (NSNumber *n in cpus) {
        cpu += n.floatValue;
    }
    return cpu;
}
+ (NSArray *)ysc_cpuUsagePerProcessor {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if (_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}
@end
