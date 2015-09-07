//
//  YSCEnum.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#ifndef EZGoal_YSCEnum_h
#define EZGoal_YSCEnum_h

typedef NS_ENUM(NSInteger, RegexType) {
    RegexTypeEmail          = 0,
    RegexTypeMobilePhone,
    RegexTypeUserName,
    RegexTypePassword,
    RegexTypeNickName,
    RegexTypeIdentityCard,
    RegexTypeAllNumbers
};

typedef NS_ENUM (NSInteger, RequestType) {
    RequestTypeGET = 0,
    RequestTypePOST,
    RequestTypeUploadFile,
    RequestTypeDownloadFile,
    RequestTypePostBodyData,
    RequestTypeCustomResponse       //数据来源不是AFNManger
};

typedef NS_ENUM(NSInteger, AudioType) {
    AudioTypeStart = 0,
    AudioTypeMoreItem,
    AudioTypePanicSuccess,
    AudioTypeMore,
    AudioTypeMenuOpen,
    AudioTypeMenuClose,
    AudioTypeShare,
    AudioTypeHeartbeat,
    AudioTypePush,
    AudioTypeAddAlert
};

typedef NS_ENUM(NSInteger, VersionCompareResult) {
    VersionCompareResultAscending = -1,
    VersionCompareResultSame = 0,
    VersionCompareResultDescending = 1
};

/*  图片质量
 *  高质量：原图
 *  中等质量：原图大小的70%。最小宽度：480 最大宽度：720
 *  低质量：原图大小的50%。最小宽度：320 最大宽度：480
 */
typedef NS_ENUM(NSInteger, ImageQuality) {
    ImageQualityLow = 0,        //低质量图片
    ImageQualityNormal = 1,     //中等质量图片
    ImageQualityHigh = 2,       //高质量图片
    ImageQualityAuto = 10       //根据网络自动选择图片质量
};

typedef NS_ENUM(NSInteger, BackType) {
    BackTypeDefault = 0,
    BackTypeImage,
    BackTypeSliding,
    BackTypeDismiss NS_DEPRECATED_IOS(2_0, 3_0)
};

#endif
