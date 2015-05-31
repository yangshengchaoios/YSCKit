//
//  FileUtils.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//


#define kFileName   @"filename"
#define kFileSize   @"filesize"

/*
 * 数据库和账户信息，放在Documents目录
 * 程序长期使用的缓存，放在Library/Caches目录
 * 只在当次程序打开使用的，放在tmp目录
 */
@interface YSCFileUtils : NSObject

#pragma mark - APP打包文件运行的目录

+ (NSString *)DirectoryPathOfBundle;


#pragma mark - 常用沙盒里的目录
/**
 *  沙盒根目录
 */
+ (NSString *)DirectoryPathOfHome;
/**
 *  /Documents
 *  通常存放应用中建立的文件，如数据库文件，或程序中浏览到的文件数据
 *  itunes备份该目录
 */
+ (NSString *)DirectoryPathOfDocuments;
/**
 *  /Library
 *  itunes备份该目录除了Caches
 */
+ (NSString *)DirectoryPathOfLibrary;
/**
 *  /Library/Caches
 *  通常保存页面缓存数据
 *  退出app不被清除
 *  itunes不备份该目录
 */
+ (NSString *)DirectoryPathOfLibraryCaches;
/**
 *  /Library/Preferences
 *  保存NSUserDefaults（bounldId.plist）
 *  itunes备份该目录
 */
+ (NSString *)DirectoryPathOfLibraryPreferences;
/**
 *  /tmp
 *  通常保存临时数据，比如要上传的图片；下载的临时文件等
 *  当内存吃紧时，被ios系统判断是否需要清空该目录
 *  iTunes不备份该目录
 */
+ (NSString *)DirectoryPathOfTmp;



#pragma mark - 文件和目录操作常用方法
/**
 *  判断文件或目录是否存在
 *  Returns a Boolean value that indicates whether a file or directory exists at a specified path.
 *
 *  @param path 文件或目录的路径
 *
 *  @return YES/NO
 */
+ (BOOL)isExistsAtPath:(NSString *)path;
/**
 *  确保filepath目录存在，如果不存在就创建
 *
 *  @param directoryPath
 *
 *  @return 
 */
+ (NSString *)ensureDirectory:(NSString *)directoryPath;
/**
 *  文件拷贝
 *  只能拷贝文件，不能拷贝目录！
 *
 *  @param sourceFilePath 源文件路径
 *  @param targetFilePath 目标文件路径
 *
 *  @return YES/NO
 */
+ (BOOL)copyFileFromPath:(NSString *)sourceFilePath toPath:(NSString *)targetFilePath;
/**
 *  删除文件和文件夹
 *  如果是目录就删除整个目录包括其下的文件和文件夹；如果是文件就直接删除文件
 *
 *  @param deletePath 文件路径
 *
 *  @return YES/NO
 */
+ (BOOL)deleteFileOrDirectory:(NSString *)deletePath;
/**
 *  获取目录下所有文件和目录的路径
 *
 *  @param directoryPath 目录路径  TODO:need to test filepath
 *
 *  @return 目录数组
 */
+ (NSArray *)allPathsInDirectoryPath:(NSString *)directoryPath;
/**
 *  获取目录下所有文件的属性（filename + filesize）
 *
 *  @param directoryPath 目录路径
 *
 *  @return 文件属性数组
 */
+ (NSArray *)attributesOfAllFilesInDirectoryPath:(NSString *)directoryPath;
/**
 *  清空目录下所有文件和目录，但保持当前目录的存在
 *
 *  @param directoryPath 要清空的目录
 *  
 *  @return YES/NO
 */
+ (BOOL)clearDirectoryPath:(NSString *)directoryPath;

@end