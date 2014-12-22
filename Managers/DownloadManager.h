//
//  Downloader.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

typedef void (^DownloadCallback)(BOOL success, NSString *fileUrl, BOOL usedCache);

@class DownloadManager;

@protocol DownloaderDelegate <NSObject>

- (void)downloader:(DownloadManager *)downloader finishedDownloadingFile:(NSString *)fileUrl;
- (void)downloader:(DownloadManager *)downloader failedDownloadingFile:(NSString *)fileUrl;

@end

@interface DownloadManager : NSObject {
    
}

+ (DownloadManager *)sharedInstance;

+ (NSString *)localPathForAudioUrl:(NSString *)audioUrl;
+ (NSString *)localPathForVideoUrl:(NSString *)videoUrl;

- (void)downloadFile:(NSString *)fileUrl toLocalPath:(NSString *)localFilePath useCache:(BOOL)useCache withDelegate:(id<DownloaderDelegate>)delegate;

- (void)downloadFile:(NSString *)fileUrl toLocalPath:(NSString *)localFilePath useCache:(BOOL)useCache withCallback:(DownloadCallback)callback;

- (void)downloadAudio:(NSString *)fileUrl withDelegate:(id<DownloaderDelegate>)delegate;

@end
