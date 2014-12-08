//
//  ShareManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "SNSShareManager.h"

@implementation SNSShareManager

+ (BOOL)IsOauthAndTokenNotExpired:(ShareType)shareType {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    return [UMSocialAccountManager isOauthAndTokenNotExpired:platformName];
}

+ (NSString *)PlatformTypeOfUMeng:(ShareType)shareType {
    NSString *platformName = nil;
    if (ShareTypeWeiboSina == shareType) {
        platformName = UMShareToSina;
    }
    else if (ShareTypeWeiboTencent == shareType) {
        platformName = UMShareToTencent;
    }
    else if (ShareTypeWechatSession == shareType) {
        platformName = UMShareToWechatSession;
    }
    else if (ShareTypeWechatTimeline == shareType) {
        platformName = UMShareToWechatTimeline;
    }
    else if (ShareTypeWechatFavorite == shareType) {
        platformName = UMShareToWechatFavorite;
    }
    else if (ShareTypeMobileQQ == shareType) {
        platformName = UMShareToQQ;
    }
    
    return platformName;
}

+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    return [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
}



+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
                  result:(UMSocialDataServiceCompletion)result {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    //调用UMeng的社会化分享控件
    if (platformName) {
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[platformName] content:content image:image location:nil urlResource:nil presentedController:nil completion:result];
    }
}

@end
