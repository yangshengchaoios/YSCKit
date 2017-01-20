//
//  AppMarcro.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//


//==============================================================================
//
//  @NOTE:
//      该文件只是示范具体项目中常用的全局变量定义，使用时视具体项目取舍
//      包括：颜色值、API接口前缀、全局常量、全局枚举以及宏定义等
//
//==============================================================================

#ifndef AppMarcro_h
#define AppMarcro_h

/** 定义默认值 */
//灰色
#define kDefaultGray240                 RGB_GRAY(240)
#define kDefaultGray204                 RGB_GRAY(204)
#define kDefaultGray160                 RGB_GRAY(160)
#define kDefaultGray153                 RGB_GRAY(153)
#define kDefaultGray149                 RGB_GRAY(149)
#define kDefaultGray102                 RGB_GRAY(102)
#define kDefaultGray51                  RGB_GRAY(51)
#define kDefaultGrayColor               kDefaultGray204

//蓝色
#define kDefaultBlueColor               RGB(106, 202, 249)
#define kDefaultBlueColor1              RGB(24, 167, 244)
#define kDefaultBlueColor2              RGB(103, 191, 250)
#define kDefaultBlueColor3              RGB(84, 149, 253)
#define kDefaultBlueColor4              RGB(47, 176, 249)
#define kDefaultBlueColor5              RGB(0, 162, 227)
#define kDefaultBlueColor6              RGB(40, 170, 248)       //按钮突出
#define kDefaultBlueColor7              RGB(198, 236, 254)      //选中剧集

//橘色
#define kDefaultOrangeColor             RGB(254, 102, 0)
#define kDefaultOrangeColor1            RGB(235, 92, 6)         //缓存列表删除背景
#define kDefaultOrangeColor2            RGB(253, 153, 95)       //剧集NEW背景

//绿色
#define kDefaultGreenColor              RGB(137, 182, 1)

/** 获取配置信息 */
#define kPathDomain                     @"http://test.api.com"
#ifdef kPathAppBaseUrl
    #undef kPathAppBaseUrl
#endif
#define kPathAppBaseUrl                 [kPathDomain stringByAppendingString:@"/Router/Rest/Post"]
#define kKanPianAppKey                  @"16031014"
#define kKanPianAppSecret               @"a674125b391e4b09ae6734aaf5475458"
#define kPathVitamio                    @"http://ps.api.ip008.com"



/** 定义全局枚举类型 */
typedef NS_ENUM (NSInteger, PSCacheType) {
    PSCacheTypeNone     = 0, //没有选择缓存方式
    PSCacheTypeZJB      = 1, //默认缓存至追剧宝
    PSCacheTypeLocal    = 2, //默认缓存至手机本地
};
typedef NS_ENUM (NSInteger, PSRemainZJBUpdateType) {
    PSRemainZJBUpdateTypePause          = 0,
    PSRemainZJBUpdateTypePending        = 1,
    PSRemainZJBUpdateTypeDownloading    = 2,
    PSRemainZJBUpdateTypeDeleteRecord   = 3,
    PSRemainZJBUpdateTypeDeleteMission  = 4,
};

/** 定义接口地址 */
static NSString * const kMethodSearchPromptList         = @"KanPian.Service.Contract.IApplicationService.SearchPromptList";
static NSString * const kMethodSearch                   = @"KanPian.Service.Contract.IApplicationService.Search";

/** 定义接口参数名称 */
static NSString * const kParamCoverUrl                  = @"coverUrl";
static NSString * const kParamPlayUrl                   = @"playUrl";
static NSString * const kParamPlayUrls                  = @"playUrls";
static NSString * const kParamPlayName                  = @"playName";
static NSString * const kParamFileId                    = @"fileId";
static NSString * const kParamProgramId                 = @"programId";
static NSString * const kParamProgramType               = @"programType";
static NSString * const kParamEpisode                   = @"episode";
static NSString * const kParamWebsite                   = @"website";

#pragma mark - 影片四种类型在服务器上对应的编号

static NSInteger const kFilmTypeMovie = 10;
static NSInteger const kFilmTypeSeries = 20;
static NSInteger const kFilmTypeEntertainment = 30;
static NSInteger const kFilmTypeCartoon = 40;
static NSInteger const kFilmTypeExpressNews = 50;

#pragma mark - ViewController应用的类名，可以通过类名直接跳转界面，减少控制器之间的耦合

static NSString * const kRouteSiftViewController = @"SiftViewController";

#pragma mark - 通知的name
static NSString * const kNotifyApplicationSpotlight          = @"kNotifyApplicationSpotlight";
static NSString * const kNotifyFilmsPlayCacheListChanged     = @"kNotifyFilmsPlayCacheListChanged";
static NSString * const kNotifyFilmsDownloadCacheListChanged = @"kNotifyFilmsDownloadCacheListChanged";
static NSString * const kNotifyApplicationRate               = @"kNotifyApplicationRate";
static NSString * const kNotifyApplicationToday              = @"kNotifyApplicationToday";
static NSString * const kNotifyReplayFromToday               = @"kNotifyReplayFromToday";
static NSString * const kNotifyReplayFromSearch              = @"kNotifyReplayFromSearch";
static NSString * const kNotifyShowPlayer                    = @"kNotifyShowPlayer";

#endif /* AppMarcro_h */
