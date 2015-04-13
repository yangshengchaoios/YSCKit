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
    else if (ShareTypeWechatSession == shareType || ShareTypeWeiXin == shareType) {
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
    else if (ShareTypeQQZone == shareType) {
        platformName = UMShareToQzone;
    }
    
    return platformName;
}

+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    ReturnNilWhenObjectIsEmpty(platformName);
    return [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
}

#pragma mark - 分享功能

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
     presentedController:(UIViewController *)viewController {
    [self ShareWithContent:content image:image platform:shareType presentedController:viewController result:nil];
}

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
     presentedController:(UIViewController *)viewController
                  result:(UMSocialDataServiceCompletion)result {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    UMSocialSnsPlatform *snsPlatform = [self SocialSnsPlatform:shareType];
    if (nil == snsPlatform) {
        if (UMShareToWechatSession == platformName ||
            UMShareToWechatTimeline == platformName ||
            UMShareToWechatFavorite == platformName) {
            [UIView showResultThenHideOnWindow:@"请先安装微信客户端"];
        }
        else {
            if (result) {
                result(nil);
            }
        }
        return;
    }
    
    if (ShareTypeQQZone == shareType) {
        if ([NSString isEmpty:content] || nil == image) {
            [UIView showAlertVieWithMessage:@"分享到QQ空间必须同时设置文本和图片"];
            return;
        }
    }
    [UIView showResultThenHideOnWindow:@"正在分享中" afterDelay:5];
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[platformName]
                                                       content:content
                                                         image:image
                                                      location:nil
                                                   urlResource:nil
                                           presentedController:viewController
                                                    completion:^(UMSocialResponseEntity *response) {
                                                        if (UMSResponseCodeSuccess == response.responseCode) {
                                                            [UIView showResultThenHideOnWindow:@"分享成功"];
                                                        }
                                                        else if (UMSResponseCodeCancel == response.responseCode) {
                                                            [UIView showResultThenHideOnWindow:@"取消分享"];
                                                        }
                                                        else {
                                                            NSString *errorMessage = [NSString stringWithFormat:@"分享失败失败(%d)", response.responseCode];
                                                            [UIView showResultThenHideOnWindow:errorMessage];
                                                        }
                                                        
                                                        if (result) {
                                                            result(response);
                                                        }
                                                    }];
}

@end
