//
//  YSCSNSShareData.h
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//


/**
 *  第三方分享单例类
 *  作用：封装第三方分享业务逻辑
 *  TODO:这里应该只处理第三方分享的基类
 */

#define YSCSNSInstance          [YSCSNSShareData SharedInstance]

@interface YSCSNSShareData : NSObject
+ (instancetype)SharedInstance;
+ (BOOL)IsOauthAndTokenNotExpired:(ShareType)shareType;

// 分享到单个平台
- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController;
// 分享到多个平台
- (void)shareWithContent:(NSString *)content
                   image:(UIImage *)image
              shareTypes:(NSArray *)shareTypes
                     url:(NSString *)url
     presentedController:(UIViewController *)viewController
              completion:(YSCResultBlock)completion;
@end
