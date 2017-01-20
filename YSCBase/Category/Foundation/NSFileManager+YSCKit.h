//
//  NSFileManager+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/7/4.
//  Copyright © 2016年 Builder. All rights reserved.
//


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface NSFileManager (YSCKit)
/**
 *  判断文件或目录是否存在
 */
+ (BOOL)ysc_fileExistsAtPath:(NSString *)path;
/**
 *  确保filepath目录存在
 *  如果不存在就(递归)创建
 */
+ (BOOL)ysc_ensureDirectory:(NSString *)directoryPath;
/**
 *  文件拷贝
 *  只能拷贝文件，不能拷贝目录！
 */
+ (BOOL)ysc_copyFileFromPath:(NSString *)sourceFilePath toPath:(NSString *)targetFilePath;
/**
 *  删除文件/夹
 *  如果是目录就删除整个目录包括其下的文件和文件夹；如果是文件就直接删除
 */
+ (BOOL)ysc_deleteFileOrDirectory:(NSString *)deletePath;
/**
 *  删除指定目录下的文件
 *  @param pattern 文件名名称的正则表达式
 */
+ (void)ysc_deleteFileOrDirectory:(NSString *)deletePath nameRegex:(NSString *)pattern;
/**
 *  获取目录下所有文件和目录的名称
 */
+ (NSArray *)ysc_allNamesInDirectoryPath:(NSString *)directoryPath;
/**
 *  递归获取目录下所有文件和目录的名称
 */
+ (NSArray *)ysc_recursiveNamesInDirectoryPath:(NSString *)directoryPath;
/**
 *  获取目录下所有文件的属性（没有递归）
 *  @[@{@"fileName":@"config.plist", @"fileSize":@"1234Byte"}]
 */
+ (NSArray *)ysc_attributesOfAllFilesInDirectoryPath:(NSString *)directoryPath;
/**
 *  计算目录占用磁盘空间大小 bytes
 *  递归遍历directoryPath下的所有目录和文件
 */
+ (long long)ysc_getSizeOfDierctory:(NSString *)directoryPath;
/**
 *  清空目录下所有文件和目录
 *  但保持当前目录的存在
 */
+ (BOOL)ysc_clearDirectoryPath:(NSString *)directoryPath;
@end
