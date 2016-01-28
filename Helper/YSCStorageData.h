//
//  YSCStorageData.h
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//


/**
 *  缓存单例类
 *  作用：封装缓存目录的管理业务
 */

#define YSCStorageInstance                          [YSCStorageData SharedInstance]
#define SaveObject(obj,key)                         [YSCSTORAGEDATA saveObject:obj forKey:key fileName:nil subFolder:nil]
#define SaveObjectByFile(obj,key,file)              [YSCSTORAGEDATA saveObject:obj forKey:key fileName:file subFolder:nil]
#define SaveCacheObject(obj,key)                    [YSCSTORAGEDATA saveCacheObject:obj forKey:key fileName:nil subFolder:nil]
#define SaveCacheObjectByFile(obj,key,file)         [YSCSTORAGEDATA saveCacheObject:obj forKey:key fileName:file subFolder:nil]

#define GetObject(key)                              [YSCSTORAGEDATA getObjectForKey:key fileName:nil subFolder:nil]
#define GetObjectByFile(key,file)                   [YSCSTORAGEDATA getObjectForKey:key fileName:file subFolder:nil]
#define GetCacheObject(key)                         [YSCSTORAGEDATA getCacheObjectForKey:key fileName:nil subFolder:nil]
#define GetCacheObjectByFile(key,file)              [YSCSTORAGEDATA getCacheObjectForKey:key fileName:file subFolder:nil]


//--------------------------------------
//  定义各种文件的缓存路径
//--------------------------------------
@interface YSCStorageData : NSObject
@property (nonatomic, copy) NSString *directoryPathOfHome;
@property (nonatomic, copy) NSString *directoryPathOfDocuments;
@property (nonatomic, copy) NSString *directoryPathOfLibrary;
@property (nonatomic, copy) NSString *directoryPathOfLibraryCaches;
@property (nonatomic, copy) NSString *directoryPathOfLibraryPreferences;
@property (nonatomic, copy) NSString *directoryPathOfTmp;

+ (instancetype)SharedInstance;

// 设置用户目录
- (void)setUserId:(NSString *)userId;
// Documents/YSCKit_Storage 目录下的文件和目录路径
- (NSString *)directoryPathOfDocumentsByUserId;     // Documents/YSCKit_Storage/UserId/
- (NSString *)filePathOfUserSettings;               // Documents/YSCKit_Storage/UserId/UserSettings.archive
- (NSString *)directoryPathOfDocumentsCommon;       // Documents/YSCKit_Storage/
- (NSString *)filePathOfCommonSettings;             // Documents/YSCKit_Storage/CommonSettings.archive

// Library/Caches/YSCKit_Storage 目录下的文件和目录路径
- (NSString *)directoryPathOfLibraryCachesByUserId; // Library/Caches/YSCKit_Storage/UserId/
- (NSString *)directoryPathOfLibraryCachesBundleIdentifier; // Library/Caches/com.xxx.yyy
- (NSString *)directoryPathOfPicByUserId;           // Library/Caches/YSCKit_Storage/UserId/Pics/
- (NSString *)directoryPathOfAudioByUserId;         // Library/Caches/YSCKit_Storage/UserId/Audioes/
- (NSString *)directoryPathOfVideoByUserId;         // Library/Caches/YSCKit_Storage/UserId/Videoes/
- (NSString *)directoryPathOfLibraryCachesCommon;   // Library/Caches/YSCKit_Storage/
- (NSString *)directoryPathOfDocumentsLog;          // Library/Caches/YSCKit_Storage/YSCLog/
@end


//--------------------------------------
//  管理缓存数据的序列化和反序列化
//--------------------------------------
@interface YSCStorageData (Archive)
// 公共配置文件存取
- (void)setConfigValue:(NSObject *)value forKey:(NSString *)key;
- (id)configValueForKey:(NSString *)key;

// 用户配置文件存取
- (void)setUserConfigValue:(NSObject *)value forKey:(NSString *)key;
- (id)userConfigValueForKey:(NSString *)key;

// 序列化
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath;
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite;
- (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath;

// 删除Documents和Caches目录中的缓存数据，并确保所有缓存目录都存在
- (void)clearLibraryCaches;
@end


//--------------------------------------
//  处理缓存数据
//--------------------------------------
@interface YSCStorageData (Cache)
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
- (BOOL)saveCacheObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;

- (id)getObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
- (id)getCacheObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
@end