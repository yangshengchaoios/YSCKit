//
//  YSCStorage.h
//  YSCKit
//
//  Created by Builder on 16/7/4.
//  Copyright © 2016年 Builder. All rights reserved.
//


#define YSCSaveObject(obj,key)                      [YSCStorage saveObject:obj forKey:key fileName:nil subFolder:nil]
#define YSCSaveObjectByFile(obj,key,file)           [YSCStorage saveObject:obj forKey:key fileName:file subFolder:nil]
#define YSCSaveCacheObject(obj,key)                 [YSCStorage saveCacheObject:obj forKey:key fileName:nil subFolder:nil]
#define YSCSaveCacheObjectByFile(obj,key,file)      [YSCStorage saveCacheObject:obj forKey:key fileName:file subFolder:nil]
#define YSCGetObject(key)                           [YSCStorage getObjectForKey:key fileName:nil subFolder:nil]
#define YSCGetObjectByFile(key,file)                [YSCStorage getObjectForKey:key fileName:file subFolder:nil]
#define YSCGetCacheObject(key)                      [YSCStorage getCacheObjectForKey:key fileName:nil subFolder:nil]
#define YSCGetCacheObjectByFile(key,file)           [YSCStorage getCacheObjectForKey:key fileName:file subFolder:nil]

//====================================
//
// 本地缓存常用目录
//
//====================================
@interface YSCStorage : NSObject
/**
 *  设置用户ID
 */
+ (void)setUserId:(NSString *)userId;

/**
 *  /Documents/YSCKitStorage
 */
+ (NSString *)directoryPathOfDocumentsStorage;
/**
 *  没有userId: /Documents/YSCKitStorage
 *  存在userId: /Documents/YSCKitStorage/userId
 */
+ (NSString *)directoryPathOfDocumentsUserStorage;

/**
 *  /Library/Caches/YSCKitStorage
 */
+ (NSString *)directoryPathOfLibraryCachesStorage;
/**
 *  没有userId: /Library/Caches/YSCKitStorage
 *  存在userId: /Library/Caches/YSCKitStorage/userId
 */
+ (NSString *)directoryPathOfLibraryCachesUserStorage;

/**
 *  返回保存日志的目录
 */
+ (NSString *)directoryPathOfLog;
/**
 *  删除以下目录中的所有数据
 *  1. /Library/Caches/YSCKitStorage
 *  2. /Library/Caches/BOUNLD_ID
 */
+ (void)clearLibraryCaches;
@end



//====================================
//
// 采用对象的序列化进行本地缓存
//
//====================================
@interface YSCStorage (Archive)
/**
 *  /Document/YSCKitStorage
 *  该目录下的数据与业务逻辑相关
 *  overwrite = NO
 */
+ (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
+ (id)getObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;

/**
 *  /Library/Caches/YSCKitStorage
 *  该目录下的数据与业务逻辑无关，随时都可以清除
 *  overwrite = NO
 */
+ (BOOL)saveCacheObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
+ (id)getCacheObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;

/**
 *  对象的序列化与反序列化
 */
+ (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath;
+ (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite;
+ (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath;
@end



//====================================
//
// 管理keychain中的数据
//
//====================================
@interface YSCStorage (KeyChain)
/** 新增&&更新 */
+ (BOOL)saveObject:(id)anObject inKeyChainForKey:(NSString *)key;
/** 获取 */
+ (id)objectInKeyChainForKey:(NSString *)key;
/** 移除 */
+ (BOOL)removeObjectInKeyChainForKey:(NSString *)key;
@end


