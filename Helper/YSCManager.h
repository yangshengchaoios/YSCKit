//
//  YSCManager.h
//  YSCKit
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 Builder. All rights reserved.
//


/**
 *  公共方法类
 *  作用：管理各种小方法(convenient methods)
 */

#import "YSCKitConstant.h"
//--------------------------------------
//  常用操作
//--------------------------------------
@interface YSCManager : NSObject
// 检测新版本
+ (void)checkNewVersion;
+ (void)checkNewVersionOnAppStore;

// 打电话
+ (void)makeCall:(NSString *)phoneNumber;
+ (void)makeCall:(NSString *)phoneNumber success:(YSCBlock)block;

// NSURL获取参数
+ (NSDictionary *)getParamsInNSURL:(NSURL *)url;
+ (NSDictionary *)getParamsInQueryString:(NSString *)queryString;

// 获取wifi的mac地址
+ (id)fetchSSIDInfo;
+ (NSString *)currentWifiBSSID;

// 添加cell
+ (void)insertTableViewCell:(UITableView *)tableView oldCount:(NSInteger)oldCount addCount:(NSInteger)addCount;
+ (void)insertCollectionViewCell:(UICollectionView *)collectionView oldCount:(NSInteger)oldCount addCount:(NSInteger)addCount;

// 保存错误日志
+ (void)saveNSError:(NSError *)error;
@end

