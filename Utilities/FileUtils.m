//
//  FileUtils.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

#pragma mark - APP打包文件运行的目录

+ (NSString *)DirectoryPathOfBundle {
    return [[NSBundle mainBundle] resourcePath];
}

#pragma mark - 常用沙盒里的目录
+ (NSString *)DirectoryPathOfHome {
	return NSHomeDirectory();
}

+ (NSString *)DirectoryPathOfDocuments {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		return paths[0];
	}
	else {
		return nil;
	}
}

+ (NSString *)DirectoryPathOfLibrary {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		return paths[0];
	}
	else {
		return nil;
	}
}

+ (NSString *)DirectoryPathOfLibraryCaches {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		return paths[0];
	}
	else {
		return nil;
	}
}

+ (NSString *)DirectoryPathOfLibraryPreferences {
	NSString *libraryPath = [self DirectoryPathOfLibrary];
	if (libraryPath) {
		return [libraryPath stringByAppendingPathComponent:@"Preferences"];
	}
	else {
		return nil;
	}
}

+ (NSString *)DirectoryPathOfTmp {
	return NSTemporaryDirectory();
}

+ (NSString *)ensureParentDirectory:(NSString *)filepath {
	NSString *parentDirectory = [filepath stringByDeletingLastPathComponent];
	BOOL isDirectory;
	if ((![FileDefaultManager fileExistsAtPath:parentDirectory isDirectory:&isDirectory]) || (!isDirectory)) {
		[FileDefaultManager createDirectoryAtPath:parentDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return filepath;
}

#pragma mark - 文件和目录操作常用方法
+ (BOOL)isExistsAtPath:(NSString *)path {
	return [FileDefaultManager fileExistsAtPath:path];
}

+ (NSString *)ensureDirectory:(NSString *)directoryPath {
	BOOL isDirectory;
	if ((![FileDefaultManager fileExistsAtPath:directoryPath isDirectory:&isDirectory]) || (!isDirectory)) {
		[self ensureParentDirectory:directoryPath];
		[FileDefaultManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return directoryPath;
}

+ (BOOL)copyFileFromPath:(NSString *)sourceFilePath toPath:(NSString *)targetFilePath {
	NSError *error = nil;
	BOOL isSucces = NO;
	if (![FileDefaultManager fileExistsAtPath:sourceFilePath]) {
		NSLog(@"The source file is not exists!sourceFilePath=%@", sourceFilePath);
		return NO;
	}
	if ([FileDefaultManager fileExistsAtPath:targetFilePath]) {
		NSLog(@"The target file is exists!deleting ...%@", targetFilePath);
		isSucces = [self deleteFileOrDirectory:targetFilePath]; //if not delete it, error will happen!
	}

	isSucces = [FileDefaultManager copyItemAtPath:sourceFilePath toPath:targetFilePath error:&error];
	if (error != nil) {
		NSLog(@"copy error:%@", [error localizedDescription]);
	}
	else {
		NSLog(@"copy successed!");
	}
	return isSucces;
}

+ (BOOL)deleteFileOrDirectory:(NSString *)deletePath {
	NSError *error = nil;
	BOOL isSucces = NO;
	if (![FileDefaultManager fileExistsAtPath:deletePath]) {
		NSLog(@"The delete path is not exists!!!deletePath=%@", deletePath);
		return NO;
	}

	isSucces = [FileDefaultManager removeItemAtPath:deletePath error:&error];
	if (error != nil) {
		NSLog(@"delete error:%@", [error localizedDescription]);
	}
	else {
		NSLog(@"delete successed!");
	}
	return isSucces;
}

+ (NSArray *)allPathsInDirectoryPath:(NSString *)directoryPath {
	return [FileDefaultManager contentsOfDirectoryAtPath:directoryPath error:nil];
}

+ (NSArray *)attributesOfAllFilesInDirectoryPath:(NSString *)directoryPath {
	NSArray *filesName = [FileDefaultManager contentsOfDirectoryAtPath:directoryPath error:nil];
	NSMutableArray *fileAttributes = [NSMutableArray new];
	for (NSString *fileName in filesName) {
		NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
		BOOL isDir;
		BOOL isExists = [FileDefaultManager fileExistsAtPath:filePath isDirectory:&isDir];
		if (![fileName.lowercaseString hasSuffix:@"ds_store"] && isExists && !isDir) { //filer directory and index file .DS_Store
			NSDictionary *attributes = [FileDefaultManager attributesOfItemAtPath:filePath error:NULL];
			NSString *fileSize = [NSString stringWithFormat:@"%llu", [attributes fileSize]];
			[fileAttributes addObject:@{kFileName : fileName, kFileSize : fileSize}];
		}
	}
	return fileAttributes;
}

+ (BOOL)clearDirectoryPath:(NSString *)directoryPath {
    if ([self deleteFileOrDirectory:directoryPath]) {
        [self ensureDirectory:directoryPath];
        return YES;
    }
    else {
        return NO;
    }
}

@end
