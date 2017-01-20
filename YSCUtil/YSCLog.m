//
//  YSCLog.m
//  YSCKit
//
//  Created by Builder on 16/7/4.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCLog.h"
#import "YSCStorage.h"

@interface YSCLog ()
@property (nonatomic, strong) dispatch_queue_t saveLogQueue;
@end

@implementation YSCLog
+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[YSCLog alloc] init];
    });
    return _sharedObject;
}
- (id)init {
    self = [super init];
    if (self) {
        self.saveLogQueue = dispatch_queue_create("com.YSCKit.saveLogQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (void)saveLogError:(NSError *)error {
    NSString *errMsg = [NSString stringWithFormat:@"%@", error];
    [self saveLog:errMsg];
}
+ (void)saveLog:(NSString *)logString {
    NSString *fileName =  [CURRENT_DATE ysc_stringWithFormat:@"yyyy-MM-dd"];
    [self saveLog:logString fileName:fileName];
}
+ (void)saveLog:(NSString *)logString fileName:(NSString *)fileName {
    NSString *logFilePath = [[YSCStorage directoryPathOfLog] stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [CURRENT_DATE ysc_stringWithFormat:@"HH:mm:ss SSS"], logString];
    [self saveLog:logStringWithTime filePath:logFilePath overWrite:NO];
}
+ (void)saveLog:(NSString *)logString filePath:(NSString *)filePath overWrite:(BOOL)overwrite {
    RETURN_WHEN_OBJECT_IS_EMPTY(logString);
    if (overwrite) {
        [NSFileManager ysc_deleteFileOrDirectory:filePath];
    }
    
    dispatch_async([YSCLog sharedInstance].saveLogQueue , ^{
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if ( ! fh ) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
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
    });
}

+ (void)deleteLogFilesExceptLastDays:(NSInteger)days {
    NSArray *fileNames = [NSFileManager ysc_allNamesInDirectoryPath:[YSCStorage directoryPathOfLog]];
    NSArray *tempArray = [fileNames sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = [NSDate ysc_dateFromString:(NSString *)obj1 withFormat:kDateFormat3];
        NSDate *date2 = [NSDate ysc_dateFromString:(NSString *)obj2 withFormat:kDateFormat3];
        return [date1 ysc_isEarlierThanDate:date2];
    }];
    NSInteger index = 0;
    for (NSString *fileName in tempArray) {
        NSDate *tempDate = [NSDate ysc_dateFromString:fileName withFormat:kDateFormat3];
        if (tempDate) {
            index++;
            if (index > days) {
                NSString *filePath = [[YSCStorage directoryPathOfLog] stringByAppendingPathComponent:fileName];
                [NSFileManager ysc_deleteFileOrDirectory:filePath];
            }
        }
    }
}
@end
