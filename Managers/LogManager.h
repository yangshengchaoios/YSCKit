//
//  LogManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-4-24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

//记录APP的crash日志
void uncaughtExceptionHandler(NSException *exception);

+ (void)saveLogError:(NSError *)error;
+ (void)saveLog:(NSString *)logString;
+ (void)saveTempLog:(NSString *)logString;
+ (void)saveLog:(NSString *)logString intoFileName:(NSString *)fileName;
+ (void)saveLog:(NSString *)logString intoFilePath:(NSString *)logFilePath overWrite:(BOOL)overwrite;

@end
