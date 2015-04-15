//
//  ShareManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSShareManager : NSObject

+ (BOOL)IsOauthAndTokenNotExpired:(ShareType)shareType;
//将本项目的分享类型转义成UMeng支持的分享类型
+ (NSString *)PlatformTypeOfUMeng:(ShareType)shareType;
//将本项目的分享类型映射到UMeng的分享类型对象
+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType;

#pragma mark - 分享功能

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController;

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController
                  result:(UMSocialDataServiceCompletion)result;

@end
