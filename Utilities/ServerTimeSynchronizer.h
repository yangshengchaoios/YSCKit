//
//  ServerTimeSynchronizer.h
//  YSCKit
//
//  Created by  YangShengchao on 14-9-19.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerTimeSynchronizer : NSObject

@property (strong, nonatomic) NSString *currentTimeInterval;    //服务器当前的时间戳

+ (instancetype)sharedInstance;

@end
