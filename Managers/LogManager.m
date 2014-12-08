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
    ReturnWhenObjectIsEmpty(logString);
    NSString *logDirectory = [[StorageManager sharedInstance] directoryPathOfDocumentsLog];
    NSString *fileName =  [[NSDate date] stringWithFormat:@"yyyy-MM-dd"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [[NSDate date] stringWithFormat:@"HH:mm:ss SSS"], logString];
    
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if ( ! fh ) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    }
    
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[logStringWithTime dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [fh closeFile];
}

@end
