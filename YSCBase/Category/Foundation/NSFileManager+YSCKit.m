//
//  NSFileManager+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/7/4.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSFileManager+YSCKit.h"

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation NSFileManager (YSCKit)
+ (BOOL)ysc_fileExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (BOOL)ysc_ensureDirectory:(NSString *)directoryPath {
    BOOL isDirectory;
    BOOL isSucces = YES;
    if (( ! [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory]) ||
        ( ! isDirectory)) {
        [self _ysc_ensureParentDirectory:directoryPath];
        isSucces = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return isSucces;
}
+ (BOOL)ysc_copyFileFromPath:(NSString *)sourceFilePath toPath:(NSString *)targetFilePath {
    BOOL isSucces = NO;
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return NO;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetFilePath]) {
        isSucces = [self ysc_deleteFileOrDirectory:targetFilePath]; //if not delete it, error will happen!
    }
    return [[NSFileManager defaultManager] copyItemAtPath:sourceFilePath toPath:targetFilePath error:NULL];
}
+ (BOOL)ysc_deleteFileOrDirectory:(NSString *)deletePath {
    if ( ! [self ysc_fileExistsAtPath:deletePath]) {
        return YES;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:deletePath error:NULL];
}
+ (void)ysc_deleteFileOrDirectory:(NSString *)deletePath nameRegex:(NSString *)pattern {
    NSArray *array = [self ysc_allNamesInDirectoryPath:deletePath];
    for (NSString *name in array) {
        NSString *path = [deletePath stringByAppendingPathComponent:name];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if ( ! isDir && [NSString ysc_isMatchRegex:pattern withString:name]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
    }
}
+ (NSArray *)ysc_allNamesInDirectoryPath:(NSString *)directoryPath {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
}
+ (NSArray *)ysc_recursiveNamesInDirectoryPath:(NSString *)directoryPath {
    NSMutableArray *array = [NSMutableArray array];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    for (NSString *fileName in fileEnumerator) {
        [array addObject:fileName];
    }
    return array;
}
+ (NSArray *)ysc_attributesOfAllFilesInDirectoryPath:(NSString *)directoryPath {
    NSArray *filesName = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    NSMutableArray *fileAttributes = [NSMutableArray new];
    for (NSString *fileName in filesName) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        if (![fileName.lowercaseString hasSuffix:@"ds_store"] && isExists && !isDir) { //filer directory and index file .DS_Store
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
            NSString *fileSize = [NSString stringWithFormat:@"%llu", [attributes fileSize]];
            [fileAttributes addObject:@{@"fileName" : fileName, @"fileSize" : fileSize}];
        }
    }
    return fileAttributes;
}
+ (long long)ysc_getSizeOfDierctory:(NSString *)directoryPath {
    long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}
+ (BOOL)ysc_clearDirectoryPath:(NSString *)directoryPath {
    if ([self ysc_deleteFileOrDirectory:directoryPath]) {
        [self ysc_ensureDirectory:directoryPath];
        return YES;
    }
    else {
        return NO;
    }
}
+ (NSString *)_ysc_ensureParentDirectory:(NSString *)filepath {
    NSString *parentDirectory = [filepath stringByDeletingLastPathComponent];
    BOOL isDirectory;
    if (( ! [[NSFileManager defaultManager] fileExistsAtPath:parentDirectory isDirectory:&isDirectory]) ||
        ( ! isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return filepath;
}
@end
