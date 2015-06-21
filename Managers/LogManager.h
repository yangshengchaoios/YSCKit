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

+ (void)saveLog:(NSString *)logString;
+ (void)saveTempLog:(NSString *)logString;
+ (void)saveLog:(NSString *)logString intoFileName:(NSString *)fileName;
+ (void)saveLog:(NSString *)logString intoFilePath:(NSString *)logFilePath overWrite:(BOOL)overwrite;

@end
