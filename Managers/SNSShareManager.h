//
//  ShareManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSShareManager : NSObject

@property (nonatomic, copy) YSCResultBlock completion;

+ (instancetype)sharedInstance;
+ (BOOL)IsOauthAndTokenNotExpired:(ShareType)shareType;
//将本项目的分享类型转义成UMeng支持的分享类型
+ (NSString *)PlatformTypeOfUMeng:(ShareType)shareType;
//将本项目的分享类型映射到UMeng的分享类型对象
+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType;

#pragma mark - 分享到单个、多个平台
- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController;

- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController
              completion:(YSCResultBlock)completion;


#pragma mark - 单个平台的分享功能(DEPRECATED)
+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController DEPRECATED_ATTRIBUTE;

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController
                  result:(UMSocialDataServiceCompletion)result DEPRECATED_ATTRIBUTE;

@end
