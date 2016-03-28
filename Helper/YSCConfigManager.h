//
//  YSCConfigManager.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSCConfigManager : NSObject
+ (void)configNavigationBar:(UINavigationBar *)navigationBar;
+ (void)configPullToBack;
+ (void)registerForRemoteNotification;
@end
