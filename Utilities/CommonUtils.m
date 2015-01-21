//
//  CommonUtils.m
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

/**
 *  检查是否有新版本需要更新
 */
+ (void)checkNewVersion {
//    return;
    //TODO:远程开关
    
    [AFNManager getDataWithAPI:kResPathAppUpdateNewVersion
                  andDictParam:nil
                     modelName:ClassOfObject(NewVersionModel)
              requestSuccessed: ^(id responseObject) {
                  NewVersionModel * versionModel = (NewVersionModel *)responseObject;
                  if ([NSObject isNotEmpty:versionModel]) {
                      BOOL isSkipTheVersion = [[NSUserDefaults standardUserDefaults] boolForKey:SkipVersion];
                      if ((! isSkipTheVersion)
                          && (VersionCompareResultAscending == [AppVersion compareWithVersion:versionModel.versionCode])
                          && ([NSString isNotEmpty:versionModel.downloadUrl])) {
                          NSString *title = [NSString stringWithFormat:@"有版本%@需要更新", versionModel.versionCode];
                          NSString *message = [NSString trimString:versionModel.description];
                          
                          UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
                          [alertView bk_addButtonWithTitle:@"立刻升级" handler:^{
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionModel.downloadUrl]];
                              exit(0);
                          }];
                          if ( ! versionModel.isForced ) {   //非强制更新的话才显示更多选项
                              [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SkipVersion];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                              }];
                              [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];//下次启动再次检测
                          }
                          [alertView show];
                      }
                  }
              }
                requestFailure: ^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"errorMessage = %@", errorMessage);
                }];
}

/**
 *  配置Umeng参数
 */
+ (void)configUmeng {
    
    //TODO:远程开关
    NSLog(@"DEBUGMODEL = %d, kUMAppKey = %@", DEBUGMODEL, kUMAppKey);
#pragma mark - 设置UMeng应用的key
    [MobClick setAppVersion:AppVersion];
    if (APPSTORE) {
        [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelAppStore];
    }
    else {
        if (DEBUGMODEL) {
            [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelDebug];
        }
        else {
            [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelOfficialWebsite];
        }
    }
    
    //统计相关
    
#pragma mark - 分享相关
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
//    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:kUMAppKey];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:AppKeyWeiXin appSecret:AppSecretWeiXin url:AppRedirectUrlOfWeibo];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:AppRedirectUrlOfWeibo];
    
    //打开腾讯微博SSO开关，设置回调地址
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:AppRedirectUrlOfWeibo];
    
    //设置支持没有客户端情况下是否支持单独授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    
#pragma mark - 反馈相关
    [UMFeedback setLogEnabled:YES];
    [UMFeedback checkWithAppkey:kUMAppKey];
}

/**
 *  创建搜索栏
 *
 *  @return
 */
+ (UIView *)createSearchBar:(NSInteger)textFieldTag {
    UIView *searchBoxContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AUTOLAYOUT_LENGTH(412), AUTOLAYOUT_LENGTH(56))];
    //1. 设置搜索框背景图片
    UIImageView *searchBoxImageView = [[UIImageView alloc] initWithFrame:searchBoxContainerView.bounds];
    searchBoxImageView.image = [UIImage imageNamed:@"bg_search"];
    searchBoxImageView.center = searchBoxContainerView.center;
    [searchBoxContainerView addSubview:searchBoxImageView];
    //2. 设置搜索图标icon
    UIImageView *searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    searchIconImageView.left = 10;
    searchIconImageView.centerY = searchBoxContainerView.height / 2;
    [searchBoxContainerView addSubview:searchIconImageView];
    //3. 设置关键词输入框
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    searchTextField.placeholder = @"搜索商品与店铺";
    searchTextField.font = AUTOLAYOUT_FONT(18);
    searchTextField.textColor = [UIColor whiteColor];
    [searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    searchTextField.tag = textFieldTag;
    searchTextField.height = 24;
    searchTextField.centerY = searchIconImageView.centerY;
    searchTextField.left = CGRectGetMaxX(searchIconImageView.frame) + 10;
    searchTextField.width = searchBoxContainerView.width - searchTextField.left - 10;
    [searchBoxContainerView addSubview:searchTextField];
    
    return searchBoxContainerView;
}


#pragma mark 格式化金额

/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点）
 *
 *  @param price 价格参数
 *
 *  @return
 */
+ (NSString *)formatPrice:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:NO];
}

/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点、显示元）
 *
 *  @param price
 *
 *  @return
 */
+ (NSString *)formatPriceWithUnit:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:YES];
}

/**
 *  格式化价格字符串输出
 *
 *  @param price     价格
 *  @param useTag    是否显示￥
 *  @param isDecimal 是否显示小数点
 *
 *  @return 组装好的字符串
 */
+ (NSString *)formatPrice:(NSNumber *)price showMoneyTag:(BOOL)isTagUsed showDecimalPoint:(BOOL) isDecimal useUnit:(BOOL)isUnitUsed {
    NSString *formatedPrice = @"";
    //是否保留2位小数
    if (isDecimal) {
        formatedPrice = [NSString stringWithFormat:@"%0.2f", [price doubleValue]];
    }
    else {
        formatedPrice = [NSString stringWithFormat:@"%ld", [price integerValue]];
    }
    
    //是否添加前缀 ￥
    if (isTagUsed) {
        formatedPrice = [NSString stringWithFormat:@"￥%@", formatedPrice];
    }
    
    //是否添加后缀 元
    if(isUnitUsed) {
        formatedPrice = [NSString stringWithFormat:@"%@元", formatedPrice];
    }
    
    return formatedPrice;
}


#pragma mark 打电话

+ (void)MakeACall:(NSString *)phoneNumber {
    if ([self isEmpty:phoneNumber]) {
        return;
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];//去掉-
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[NSString trimString:phoneNumber]]];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"确定要拨打电话：%@？", phoneNumber]];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        [[UIApplication sharedApplication] openURL:phoneURL];
    }];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView show];
}

#pragma makr - Sqlite操作

+ (BOOL)SqliteUpdate:(NSString *)sql {
    return [self SqliteUpdate:sql dbPath:DBRealPath];
}

+ (BOOL)SqliteUpdate:(NSString *)sql dbPath:(NSString *)dbPath {
    BOOL isSuccess = NO;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        isSuccess = [db executeUpdate:sql];
    }
    [db close];
    return isSuccess;
}


#pragma mark - 过去了多长时间
/**
 *  1. 如果是1分钟以内  返回 'xx秒之前'
 *  2. 如果是60分钟以内 返回 'xx分钟之前'
 *  3. 如果是大于1小时且在当天  返回 'x小时之前'
 *  4. 如果是昨天      返回  '昨天hh:mm:ss'
 *  5. 如果是前天      返回  '前天hh:mm:ss'
 *  6. 今年以内        返回  'MM-dd'
 *  7. 其它           返回  'yyyy-MM-dd'
 *
 *  @param startTimeStamp 开始的时间戳
 *
 *  @return
 */
+ (NSString *)TimePassed:(NSString *)startTimeStamp {
    NSDate *startDateTime = [NSDate dateFromTimeStamp:startTimeStamp];
    NSDate *nowDate = [NSDate date];
    //其它
    if ([startDateTime isLastYear]) {
        return [startDateTime stringWithFormat:DateFormat3];
    }
    
    //当年以内
    if ([startDateTime isEarlierThanDate:[[NSDate dateBeforeYesterday] dateAtStartOfDay]]) {
        return [startDateTime stringWithFormat:@"MM-dd"];
    }
    
    //判断前天
    if ([startDateTime isBeforeYesterday]) {
        return [NSString stringWithFormat:@"前天%@",[startDateTime stringWithFormat:@"hh:mm:ss"]];
    }
    
    //判断昨天
    if ([startDateTime isYesterday]) {
        return [NSString stringWithFormat:@"昨天%@",[startDateTime stringWithFormat:@"hh:mm:ss"]];
    }
    
    NSInteger hoursPassed = [startDateTime hoursBeforeDate:nowDate];
    NSInteger minutesPassed = [startDateTime minutesBeforeDate:nowDate];
    NSInteger secondsPassed = (NSInteger)[nowDate timeIntervalSinceDate:startDateTime];
    if (hoursPassed > 0) {
        return [NSString stringWithFormat:@"%ld小时之前", hoursPassed];
    }
    if (minutesPassed > 0) {
        return [NSString stringWithFormat:@"%ld分钟之前", minutesPassed];
    }
    return [NSString stringWithFormat:@"%ld秒之前", secondsPassed];
}

@end
