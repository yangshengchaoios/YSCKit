//
//  Downloader.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager ()

@property (nonatomic, strong) NSString *homePath;
@property (nonatomic, strong) NSMutableArray *downloadingUrls;

@end

@implementation DownloadManager

+ (DownloadManager *)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (id)init {
    self = [super init];
    if (self) {
        self.downloadingUrls = [NSMutableArray array];
        self.homePath = NSHomeDirectory();
    }
    return self;
}


- (void)downloadFile:(NSString *)fileUrl toLocalPath:(NSString *)localFilePath useCache:(BOOL)useCache withDelegate:(id<DownloaderDelegate>)delegate {
    
    if (useCache) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
            [delegate downloader:self finishedDownloadingFile:fileUrl];
            return;
        }
    }
    
    if([fileUrl rangeOfString:self.homePath].length) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileUrl]) {
            [[NSFileManager defaultManager] copyItemAtPath:fileUrl toPath:localFilePath error:NULL];
            [delegate downloader:self finishedDownloadingFile:fileUrl];
        }
        else {
            [delegate downloader:self failedDownloadingFile:fileUrl];
        }
        return;
    }
    
    BOOL isUrlDownloading = NO;
    for (NSString *url in self.downloadingUrls) {
        if ([url isEqualToString:fileUrl]) {
            isUrlDownloading = YES;
            break;
        }
    }
    if (isUrlDownloading) {
        return;
    }
    else {
        [self.downloadingUrls addObject:[fileUrl copy]];
    }
    
    NSString *tempFilePath = [localFilePath stringByAppendingPathExtension:@"temp"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempFilePath append:NO];
    
    WeakSelfType blockSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:localFilePath error:NULL];
        for (NSString *url in blockSelf.downloadingUrls) {
            if ([url isEqualToString:fileUrl]) {
                [blockSelf.downloadingUrls removeObject:url];
                break;
            }
        }
        NSLog(@"downloaded file : %@", fileUrl);
    }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         for (NSString *url in blockSelf.downloadingUrls) {
                                             if ([url isEqualToString:fileUrl]) {
                                                 [blockSelf.downloadingUrls removeObject:url];
                                                 break;
                                             }
                                         }
                                         NSLog(@"downloaded file failed : %@, error: %@", fileUrl, error);
                                     }];
    
    [operation start];
}

- (void)downloadFile:(NSString *)fileUrl toLocalPath:(NSString *)localFilePath useCache:(BOOL)useCache withCallback:(DownloadCallback)callback {
    if (useCache) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
            if (callback) {
                callback(YES, fileUrl, YES);
            }
            return;
        }
    }
    
    if([fileUrl rangeOfString:self.homePath].length) {  //从本地路径下载
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileUrl]) {
            [[NSFileManager defaultManager] copyItemAtPath:fileUrl toPath:localFilePath error:NULL];
            if (callback) {
                callback(YES, fileUrl, YES);
            }
        }
        else {
            if (callback) {
                callback(NO, fileUrl, YES);
            }
        }
        return;
    }
    
    BOOL isUrlDownloading = NO;
    for (NSString *url in self.downloadingUrls) {
        if ([url isEqualToString:fileUrl]) {
            isUrlDownloading = YES;
            break;
        }
    }
    if (isUrlDownloading) {
        return;
    }
    else {
        [self.downloadingUrls addObject:[fileUrl copy]];
    }
    
    NSString *tempFilePath = [localFilePath stringByAppendingPathExtension:@"temp"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempFilePath append:NO];
    
    WeakSelfType blockSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:localFilePath error:NULL];
        for (NSString *url in blockSelf.downloadingUrls) {
            if ([url isEqualToString:fileUrl]) {
                [blockSelf.downloadingUrls removeObject:url];
                break;
            }
        }
        NSLog(@"downloaded file : %@", fileUrl);
        callback(YES, fileUrl, NO);
    }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         for (NSString *url in blockSelf.downloadingUrls) {
                                             if ([url isEqualToString:fileUrl]) {
                                                 [blockSelf.downloadingUrls removeObject:url];
                                                 break;
                                             }
                                         }
                                         NSLog(@"downloaded file failed : %@, error: %@", fileUrl, error);
                                         callback(NO, fileUrl, YES);
                                     }];
    
    [operation start];
}

- (void)downloadAudio:(NSString *)fileUrl withDelegate:(id<DownloaderDelegate>)delegate {
    [self downloadFile:fileUrl toLocalPath:[DownloadManager localPathForAudioUrl:fileUrl] useCache:YES withDelegate:delegate];
}

//+ (NSString *)localPathForAudioUrl:(NSString *)audioUrl {
//    // http://serviceapi.51obo.com/assets/upload/aud/aud_20000211_1369038602190362-5.amr
//    /*
//    [audioUrl enumerateStringsMatchedByRegex:RegexPatternAmrUrl
//                                  usingBlock:^ (NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
//        
//                                      if (captureCount >= 4) {
//                                          NSString *dateString = capturedStrings[1];
//                                          NSString *timestampString = capturedStrings[2];
//                                          NSString *audioLength = capturedStrings[3];
//                                          NSLog(@"%@ : %@ : %@", dateString, timestampString, audioLength);
//                                      }
//    }];
//     */
//    NSString *md5String = [StringUtils md5FromString:[audioUrl lastPathComponent]];
//    NSString *extension = [audioUrl pathExtension];
//    NSString *shortName = [NSString stringWithFormat:@"%@.%@", md5String, extension];
//    return [[[StorageManager sharedInstance] audioDirectoryPath] stringByAppendingPathComponent:shortName];
//}
//
//+ (NSString *)localPathForVideoUrl:(NSString *)videoUrl {
//    NSString *md5String = [StringUtils md5FromString:[videoUrl lastPathComponent]];
//    NSString *extension = [videoUrl pathExtension];
//    NSString *shortName = [NSString stringWithFormat:@"%@.%@", md5String, extension];
//    return [[[StorageManager sharedInstance] videoDirectoryPath] stringByAppendingPathComponent:shortName];
//}

@end
