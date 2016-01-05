//
//  LogManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-4-24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "LogManager.h"
#import "StorageManager.h"
#import "NSDate+Additions.h"

@implementation LogManager

//记录APP的crash日志
void uncaughtExceptionHandler(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];// 异常的堆栈信息
    NSString *reason = [exception reason];// 出现异常的原因
    NSString *name = [exception name];// 异常名称
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\rException name：%@\rException stack：%@",name, reason, stackArray];
    
    NSMutableString *errMsg = [NSMutableString stringWithString:@"\r>>>>>>>>>>>>>>>>>>>>CrashLog>>>>>>>>>>>>>>>>>>>>\r"];//错误标记开始
    [errMsg appendFormat:@"%@\r", exceptionInfo];
    [errMsg appendString:@"<<<<<<<<<<<<<<<<<<<<CrashLog<<<<<<<<<<<<<<<<<<<<\r\n"];//错误标记结束
    [LogManager saveLog:errMsg];
}

+ (void)saveLogError:(NSError *)error {
    NSString *errMsg = [NSString stringWithFormat:@"%@", error];
    [self saveLog:errMsg];
}
+ (void)saveLog:(NSString *)logString {
    NSString *logDirectory = [STORAGEMANAGER directoryPathOfDocumentsLog];
    NSString *fileName =  [CURRENTDATE stringWithFormat:@"yyyy-MM-dd"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [CURRENTDATE stringWithFormat:@"HH:mm:ss SSS"], logString];
    [self saveLog:logStringWithTime intoFilePath:logFilePath overWrite:NO];
}

+ (void)saveTempLog:(NSString *)logString {
    NSString *logDirectory = [STORAGEMANAGER directoryPathOfDocumentsLog];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"temp"];
    [self saveLog:logString intoFilePath:logFilePath overWrite:YES];
}

+ (void)saveLog:(NSString *)logString intoFileName:(NSString *)fileName {
    NSString *logDirectory = [STORAGEMANAGER directoryPathOfDocumentsLog];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    [self saveLog:logString intoFilePath:logFilePath overWrite:YES];
}

+ (void)saveLog:(NSString *)logString intoFilePath:(NSString *)logFilePath overWrite:(BOOL)overwrite {
    ReturnWhenObjectIsEmpty(logString);
    if (overwrite && [YSCFileUtils isExistsAtPath:logFilePath]) {
        [YSCFileUtils deleteFileOrDirectory:logFilePath];
    }
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if ( ! fh ) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    }
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [fh closeFile];
}

@end
