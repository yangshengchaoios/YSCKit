//
//  YSCKitConstant.h
//  YSCKit
//
//  Created by 杨胜超 on 16/3/22.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#ifndef YSCKitConstant_h
#define YSCKitConstant_h

#ifndef kAppConfigPlist
    #define kAppConfigPlist         @"YSCKit_AppConfig"
#endif
#ifndef kAppConfigPlist
    #define kAppConfigDebugPlist    @"YSCKit_AppConfigDebug"
#endif

// 在线参数优先级 > 本地参数
#define kPathDomain                 [YSCDataInstance stringFromConfigByName:@"kPathDomain"]
#define kPathVersion                [YSCDataInstance stringFromConfigByName:@"kPathVersion"]
#define kPathCommon                 [YSCDataInstance stringFromConfigByName:@"kPathCommon"]
#define kCheckNewVersionType        [YSCDataInstance intFromConfigByName:@"kCheckNewVersionType"]
#define kIsRequestEncrypted         [YSCDataInstance boolFromConfigByName:@"kIsRequestEncrypted"]

/**
 * 基本接口地址
 */
#ifndef kPathAppResUrl              //资源文件前缀
    #define kPathAppResUrl          kPathDomain
#endif
#ifndef kPathAppBaseUrl             //普通接口地址前缀，后跟版本号
    #define kPathAppBaseUrl         [kPathDomain stringByAppendingPathComponent:kPathVersion]
#endif
#ifndef kPathAppCommonUrl           //公共接口地址前缀，与APP无关，与版本号无关
    #define kPathAppCommonUrl       [kPathDomain stringByAppendingPathComponent:kPathCommon]
#endif
/**
 * 接口名称
 */
#ifndef kPathCheckNewVersion
    #define kPathCheckNewVersion    @"CheckNewVersion"
#endif
#ifndef kPathGetServerTime
    #define kPathGetServerTime      @"GetServerTime"
#endif


/**
 * 默认变量值
 */
#ifndef kDefaultPageStartIndex      // 默认分页起始页码
    #define kDefaultPageStartIndex  1
#endif
#ifndef kDefaultPageSize            // 默认分页每页的条数
    #define kDefaultPageSize        10
#endif
#ifndef kDefaultAppChannel          // 发布的渠道
    #define kDefaultAppChannel      @"AppStore"
#endif
#ifndef kDefaultUMAppKey            // 友盟key
    #define kDefaultUMAppKey        @""
#endif
#ifndef kDefaultAppStoreId          // app在app store上的唯一编号
    #define kDefaultAppStoreId      @""
#endif
#ifndef kDefaultAppUpdateUrl        // app更新的网址
    #define kDefaultAppUpdateUrl    [@"https://itunes.apple.com/app/id" stringByAppendingString:kDefaultAppStoreId]
#endif


/**
 * 默认图片
 */
#ifndef kDefaultImage
    #define kDefaultImage                   [UIImage imageNamed:@"default_image"]
#endif



#ifndef kDefaultNaviBarBackImage
    #define kDefaultNaviBarBackImage        [UIImage imageNamed:@"bg_navigationbar"]
#endif


/**
 * 默认颜色
 */
#ifndef kDefaultColor
    #define kDefaultColor                   RGB(47, 152, 233)       //app默认主色(普通按钮+文本)
#endif
#ifndef kDefaultViewColor
    #define kDefaultViewColor               RGB(238, 238, 238)      //self.view的默认背景颜色
#endif
#ifndef kDefaultBorderColor
    #define kDefaultBorderColor             RGB(218, 218, 218)      //默认边框颜色
#endif
#ifndef kDefaultPlaceholderColor
    #define kDefaultPlaceholderColor        RGB(200, 200, 200)      //默认占位字符颜色
#endif
#ifndef kDefaultImageBackColor
    #define kDefaultImageBackColor          RGB(240, 240, 240)      //默认图片背景色
#endif






//>>>>>>>>>>>>>>>默认导航栏颜色（TODO:需要封装UI配置层）>>>>>>>>>>>>>>>
#ifndef kDefaultNaviBarTintColor
    #define kDefaultNaviBarTintColor        RGB(47, 152, 233)       //导航栏默认文字、icon的颜色
#endif
#ifndef kDefaultNaviBarTitleColor
    #define kDefaultNaviBarTitleColor       RGB(10, 10, 10)         //导航栏标题颜色
#endif
#ifndef kDefaultNaviBarTitleFont
    #define kDefaultNaviBarTitleFont        [UIFont boldSystemFontOfSize:AUTOLAYOUT_LENGTH(34)]    //导航栏标题字体大小
#endif
#ifndef kDefaultNaviTintColor
    #define kDefaultNaviTintColor           RGBA(255, 255, 255, 1)  //系统导航栏背景颜色(包括了StatusBar)
#endif
#ifndef kDefaultNaviBarItemColor
    #define kDefaultNaviBarItemColor        kDefaultNaviBarTintColor//导航栏左右文字颜色
#endif
#ifndef kDefaultNaviBarItemFont
    #define kDefaultNaviBarItemFont         AUTOLAYOUT_FONT(28)     //导航栏左右文字大小
#endif
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//TODO:封装在网络请求层
#define kDefaultRequestTimeOut  18.0f
#define kDefaultMD5SecretKey    [YSCDataInstance stringFromConfigByName:@"kDefaultMD5SecretKey"]
#define kDefaultAESSecretKey    [YSCDataInstance stringFromConfigByName:@"kDefaultMD5SecretKey"]

#endif /* YSCKitConstant_h */
