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

+ (NSString *)PlatformTypeOfUMeng:(ShareType)shareType;

+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType;

#pragma mark - 分享功能

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
                  result:(UMSocialDataServiceCompletion)result;

@end
