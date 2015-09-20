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

+ (void)saveLog:(NSString *)logString {
    NSString *logDirectory = [STORAGEMANAGER directoryPathOfDocumentsLog];
    NSString *fileName =  [[NSDate date] stringWithFormat:@"yyyy-MM-dd"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [[NSDate date] stringWithFormat:@"HH:mm:ss SSS"], logString];
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
