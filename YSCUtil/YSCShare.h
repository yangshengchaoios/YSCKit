//
//  YSCShare.h
//  MicroVideo
//
//  Created by 杨胜超 on 16/12/21.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  支持的APP平台
 */
typedef NS_ENUM(NSUInteger, YSCSharePlatform) {
    YSCSharePlatformUnsupported,
    YSCSharePlatformWeiXin,
    YSCSharePlatformQQ,
    YSCSharePlatformSinaWeibo,
    YSCSharePlatformAlipay,
};

/** 
 *  定义各个平台的分享方式
 */
typedef NS_ENUM(NSUInteger, YSCShareType) {
    YSCShareTypeWeiXinSession,      //微信会话（好友）
    YSCShareTypeWeiXinTimeline,     //微信朋友圈
    YSCShareTypeWeiXinFavorite,     //微信收藏
    
    YSCShareTypeQQFriends,          //QQ好友
    YSCShareTypeQQZone,             //QQ空间
    YSCShareTypeQQFavorite,         //QQ收藏
    YSCShareTypeQQDataline,         //QQ数据线
    
    YSCShareTypeSinaWeibo,          //新浪微博
};

/**
 *  定义分享数据的类型
 */
typedef NS_ENUM(NSUInteger, YSCShareMessageType) {
    YSCShareMessageTypeAutoDetect,
    YSCShareMessageTypeNews,
    YSCShareMessageTypeAudio,
    YSCShareMessageTypeVideo,
    YSCShareMessageTypeApp,
    YSCShareMessageTypeFile,
};


/**
 *  粘贴板数据的编码方式
 */
typedef NS_ENUM(NSUInteger, YSCSharePasteboardEncodingType) {
    YSCSharePasteboardEncodingTypeKeyedArchiver,
    YSCSharePasteboardEncodingTypeListSerialization,
};

/**
 *  分享数据模型
 */
@interface YSCShareMessage : NSObject
@property (nonatomic, strong) NSString *title;           // 标题
@property (nonatomic, strong) NSString *content;         // 简单描述
@property (nonatomic, strong) NSString *link;            // 点击消息跳转的url
@property (nonatomic, strong) UIImage *fullImage;        // 原始图
@property (nonatomic, strong) UIImage *thumbImage;       // 缩略图
@property (nonatomic, assign) YSCShareMessageType shareMessageType;
@property (nonatomic, strong) NSString *extraInfo;       // 额外信息
@property (nonatomic, strong) NSString *mediaDataUrl;    // 多媒体播放地址
@property (nonatomic, strong) NSData *fileData;          // 文件对象
@property (nonatomic, strong) NSString *fileExtention;   // 文件后缀名

// 计算属性
@property (nonatomic, strong) NSData *fullImageData;
@property (nonatomic, strong) NSString *titleBase64;
@property (nonatomic, strong) NSString *contentBase64;
@property (nonatomic, strong) NSString *linkBase64;
- (NSData *)thumbImageDataWithSize:(CGSize)size;

@end

/** 
 *  分享/授权/支付 完成后的回调
 *  error为nil即为成功
 *  error不为nil，则返回结果保存在userInfo中
 */
typedef void (^YSCShareCompletion) (NSObject *result, NSError *error);



/**
 *  与第三方APP交互
 *
 *  1. 微信：会话、朋友圈、收藏、登录
 *  2. QQ：好友、空间、收藏、数据线
 *  3. 新浪微博：时间线、登录
 */
@interface YSCShare : NSObject

+ (void)registerAppKey:(NSString *)appKey forPlatform:(YSCSharePlatform)platform;
+ (BOOL)isInstalled:(YSCSharePlatform)platform;
+ (void)authOn:(YSCSharePlatform)platform redirectURI:(NSString *)redirectURI completion:(YSCShareCompletion)completion;
+ (void)shareMessage:(YSCShareMessage *)message type:(YSCShareType)type completion:(YSCShareCompletion)completion;

// 底层通过剪贴板交互的方法
+ (NSError *)setValue:(NSDictionary *)dict forPasteboardType:(NSString*)key encoding:(YSCSharePasteboardEncodingType)encoding;
+ (NSDictionary *)getValueByKey:(NSString*)key encoding:(YSCSharePasteboardEncodingType)encoding;
+ (void)handleOpenURL:(NSURL *)url;
@end
