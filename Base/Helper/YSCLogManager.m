//
//  YSCLogManager.m
//  YSCKit
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCLogManager.h"

//记录APP的crash日志
void _uncaughtExceptionHandler(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];// 异常的堆栈信息
    NSString *reason = [exception reason];// 出现异常的原因
    NSString *name = [exception name];// 异常名称
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\rException name：%@\rException stack：%@",name, reason, stackArray];
    
    NSMutableString *errMsg = [NSMutableString stringWithString:@"\r>>>>>>>>>>>>>>>>>>>>CrashLog>>>>>>>>>>>>>>>>>>>>\r"];//错误标记开始
    [errMsg appendFormat:@"%@\r", exceptionInfo];
    [errMsg appendString:@"<<<<<<<<<<<<<<<<<<<<CrashLog<<<<<<<<<<<<<<<<<<<<\r\n"];//错误标记结束
    [YSCLogManager saveLog:errMsg];
}
@implementation YSCLogManager

+ (void)setUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler(&_uncaughtExceptionHandler);
}
+ (void)saveLogError:(NSError *)error {
    NSString *errMsg = [NSString stringWithFormat:@"%@", error];
    [YSCLogManager saveLog:errMsg];
}

+ (void)saveLog:(NSString *)logString {
    NSString *logDirectory = [YSCStorageInstance directoryPathOfDocumentsLog];
    NSString *fileName =  [CURRENT_DATE stringWithFormat:@"yyyy-MM-dd"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [CURRENT_DATE stringWithFormat:@"HH:mm:ss SSS"], logString];
    [self saveLog:logStringWithTime intoFilePath:logFilePath overWrite:NO];
}
+ (void)saveLog:(NSString *)logString intoFileName:(NSString *)fileName {
    NSString *logDirectory = [YSCStorageInstance directoryPathOfDocumentsLog];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    [self saveLog:logString intoFilePath:logFilePath overWrite:YES];
}
+ (void)saveLog:(NSString *)logString intoFilePath:(NSString *)logFilePath overWrite:(BOOL)overwrite {
    if ( ! DEBUG_MODEL) {
        return; //如果不是测试环境就不写日志
    }
    
    RETURN_WHEN_OBJECT_IS_EMPTY(logString);
    if (overwrite && [YSCFileManager fileExistsAtPath:logFilePath]) {
        [YSCFileManager deleteFileOrDirectory:logFilePath];
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

+ (void)deleteLogFilesExceptLastDays:(NSInteger)days {
    NSArray *fileNames = [YSCFileManager allPathsInDirectoryPath:[YSCStorageInstance directoryPathOfDocumentsLog]];
    NSArray *tempArray = [fileNames sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = [NSDate dateFromString:(NSString *)obj1 withFormat:kDateFormat3];
        NSDate *date2 = [NSDate dateFromString:(NSString *)obj2 withFormat:kDateFormat3];
        return [date1 isEarlierThanDate:date2];
    }];
    NSInteger index = 0;
    for (NSString *fileName in tempArray) {
        NSDate *tempDate = [NSDate dateFromString:fileName withFormat:kDateFormat3];
        if (tempDate) {
            index++;
            if (index > days) {
                NSString *filePath = [[YSCStorageInstance directoryPathOfDocumentsLog] stringByAppendingPathComponent:fileName];
                [YSCFileManager deleteFileOrDirectory:filePath];
            }
        }
    }
}
@end
