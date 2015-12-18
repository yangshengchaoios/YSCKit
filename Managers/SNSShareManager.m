//
//  ShareManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "SNSShareManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentApiInterface.h>

@interface SNSShareManager () <UMSocialUIDelegate>

@end

@implementation SNSShareManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}


#pragma mark - 分享到单个、多个平台
- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController {
    [self shareWithContent:content image:image shareTypes:shareTypes url:url presentedController:viewController completion:nil];
}

- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController
              completion:(YSCResultBlock)completion {
    self.completion = completion;
    NSMutableArray *umengPlatforms = [NSMutableArray array];
    for (NSNumber *platform in shareTypes) {
        ShareType shareType = [platform integerValue];
        NSString *umengPlatformName = [SNSShareManager PlatformTypeOfUMeng:shareType];
        if ((ShareTypeWechatSession == shareType || ShareTypeWechatTimeline == shareType || ShareTypeWechatFavorite == shareType) &&
            [WXApi isWXAppInstalled]) {
            if (ShareTypeWechatSession == shareType) {
                [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            }
            else if (ShareTypeWechatTimeline == shareType) {
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            }
            [umengPlatforms addObject:umengPlatformName];
        }
        //分享到QQ空间必须同时设置文本和图片
        else if (ShareTypeQQZone == shareType && isNotEmpty(content) && isNotEmpty(image) &&
                 ([TencentApiInterface isTencentAppInstall:kIphoneQQ] || [TencentApiInterface isTencentAppInstall:kIphoneQZONE])) {
            [umengPlatforms addObject:umengPlatformName];
        }
        else if (ShareTypeMobileQQ == shareType && [TencentApiInterface isTencentAppInstall:kIphoneQQ]) {
            [umengPlatforms addObject:umengPlatformName];
        }
    }
    if (1 == [umengPlatforms count]) {//只有一个分享平台就直接打开
        [UIView showResultThenHideOnWindow:@"正在分享中" afterDelay:5];
        UMSocialUrlResource *urlResource = nil;
        if ([NSString isNotEmpty:url]) {
            urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:url];
        }
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[umengPlatforms[0]]
                                                           content:content
                                                             image:image
                                                          location:nil
                                                       urlResource:urlResource
                                               presentedController:viewController
                                                        completion:^(UMSocialResponseEntity *response) {
                                                            if (UMSResponseCodeSuccess == response.responseCode) {
                                                                [UIView showResultThenHideOnWindow:@"分享成功"];
                                                                [MobClick event:UMEventKeyShareSuccess];
                                                            }
                                                            else if (UMSResponseCodeCancel == response.responseCode) {
                                                                [UIView showResultThenHideOnWindow:@"取消分享"];
                                                            }
                                                            else {
                                                                NSString *errorMessage = [NSString stringWithFormat:@"分享失败(%d)", response.responseCode];
                                                                [UIView showResultThenHideOnWindow:errorMessage];
                                                            }
                                                            
                                                            if (completion) {
                                                                completion(response);
                                                            }
                                                        }];
    }
    else if ([umengPlatforms count] > 1) {//超过一个分享平台需要弹出选择框
        [UMSocialSnsService presentSnsIconSheetView:viewController
                                             appKey:kUMAppKey
                                          shareText:content
                                         shareImage:image
                                    shareToSnsNames:umengPlatforms
                                           delegate:self];
    }
    else {
        if (completion) {
            completion(nil);
        }
        [UIView showAlertVieWithMessage:@"请先安装要分享的平台APP"];
    }
}


#pragma mark - 单个平台的分享功能(DEPRECATED)
+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController {
    [self ShareWithContent:content image:image platform:shareType urlResource:url presentedController:viewController result:nil];
}

+ (void)ShareWithContent:(NSString *)content
                   image:(UIImage *)image
                platform:(ShareType)shareType
             urlResource:(NSString *)url
     presentedController:(UIViewController *)viewController
                  result:(UMSocialDataServiceCompletion)result {
    [[SNSShareManager sharedInstance] shareWithContent:content image:image shareTypes:@[@(shareType)] url:url presentedController:viewController completion:^(NSObject *object) {
        if (result) {
            if (isNotEmpty(object)) {
                result((UMSocialResponseEntity *)object);
            }
            else {
                result(nil);
            }
        }
    }];
}


#pragma mark - UMSocialUIDelegate
// 配置点击分享列表后是否弹出分享内容编辑页面，再弹出分享，默认需要弹出分享编辑页面
- (BOOL)isDirectShareInIconActionSheet {
    return YES;
}
//各个页面执行授权完成、分享完成、或者评论完成时的回调函数
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    if (UMSResponseCodeSuccess == response.responseCode) {
        [UIView showResultThenHideOnWindow:@"分享成功"];
        [MobClick event:UMEventKeyShareSuccess];
    }
    else if (UMSResponseCodeCancel == response.responseCode) {
        [UIView showResultThenHideOnWindow:@"取消分享"];
    }
    else {
        NSString *errorMessage = [NSString stringWithFormat:@"分享失败(%d)", response.responseCode];
        [UIView showResultThenHideOnWindow:errorMessage];
    }
    if (self.completion) {
        self.completion(response);
    }
}


#pragma mark - Private Methods
+ (BOOL)IsOauthAndTokenNotExpired:(ShareType)shareType {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    return [UMSocialAccountManager isOauthAndTokenNotExpired:platformName];
}
//将本项目的分享类型转义成UMeng支持的分享类型
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
//将本项目的分享类型映射到UMeng的分享类型对象
+ (UMSocialSnsPlatform *)SocialSnsPlatform:(ShareType)shareType {
    NSString *platformName = [self PlatformTypeOfUMeng:shareType];
    ReturnNilWhenObjectIsEmpty(platformName);
    return [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
}

@end
