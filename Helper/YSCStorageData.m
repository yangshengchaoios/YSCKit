//
//  YSCStorageData.m
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//

#import "YSCStorageData.h"
#define kCommonDirectoryName    @"YSCKit_Storage/"


//----------------------------------------------------------------------------
//  定义各种文件的缓存路径
//----------------------------------------------------------------------------
@interface YSCStorageData ()
@property (nonatomic, copy) NSString *userDirectory;//登陆用户的缓存目录
@end
@implementation YSCStorageData
+ (instancetype)SharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (void)setUserId:(NSString *)userId {
    if ([NSString isNotEmpty:userId]) {
        self.userDirectory = [userId stringByAppendingString:([userId hasSuffix:@"/"] ? @"" : @"/")];//确保最后一个字符是'/'
        self.userDirectory = [self.userDirectory stringByAppendingString:kCommonDirectoryName];//保证用户目录在公共目录下面
    }
    else {
        self.userDirectory = kCommonDirectoryName;
    }
    
    [self _ensureUserDirectories];
}

// Documents目录下的文件和目录路径
- (NSString *)directoryPathOfDocumentsByUserId {
    return [self.directoryPathOfDocuments stringByAppendingPathComponent:self.userDirectory];
}
- (NSString *)filePathOfUserSettings {
    return [[self directoryPathOfDocumentsByUserId] stringByAppendingPathComponent:@"UserSettings.archive"];
}
- (NSString *)directoryPathOfDocumentsCommon {
    return [self.directoryPathOfDocuments stringByAppendingPathComponent:kCommonDirectoryName];
}
- (NSString *)filePathOfCommonSettings {
    return [[self directoryPathOfDocumentsCommon] stringByAppendingPathComponent:@"CommonSettings.archive"];
}

// Library目录下的文件和目录路径
- (NSString *)directoryPathOfLibraryCachesByUserId {
    return [self.directoryPathOfLibraryCaches stringByAppendingPathComponent:self.userDirectory];
}
- (NSString *)directoryPathOfLibraryCachesBundleIdentifier {
    return [self.directoryPathOfLibraryCaches stringByAppendingPathComponent:BundleIdentifier];
}
- (NSString *)directoryPathOfPicByUserId {
    return [[self directoryPathOfLibraryCachesByUserId] stringByAppendingPathComponent:@"Pics/"];
}
- (NSString *)directoryPathOfAudioByUserId {
    return [[self directoryPathOfLibraryCachesByUserId] stringByAppendingPathComponent:@"Audioes"];
}
- (NSString *)directoryPathOfVideoByUserId {
    return [[self directoryPathOfLibraryCachesByUserId] stringByAppendingPathComponent:@"Videoes/"];
}
- (NSString *)directoryPathOfLibraryCachesCommon {
    return [self.directoryPathOfLibraryCaches stringByAppendingPathComponent:kCommonDirectoryName];
}
- (NSString *)directoryPathOfDocumentsLog {
    return [[self directoryPathOfLibraryCachesCommon] stringByAppendingPathComponent:@"YSCLog/"];
}

// 私有方法
- (void)_ensureCommonDirectories {
    [YSCFileUtils ensureDirectory:[self directoryPathOfDocumentsCommon]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfDocumentsLog]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfLibraryCachesCommon]];
}
- (void)_ensureUserDirectories {
    [YSCFileUtils ensureDirectory:[self directoryPathOfDocumentsByUserId]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfLibraryCachesByUserId]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfAudioByUserId]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfVideoByUserId]];
    [YSCFileUtils ensureDirectory:[self directoryPathOfPicByUserId]];
}
- (BOOL)_isEmpty:(NSString *)string {
    if ( ! string) {
        return YES;
    }
    return !([string length] && [[string stringByReplacingOccurrencesOfString:@" " withString:@""] length]);
}
@end


//----------------------------------------------------------------------------
//  管理缓存数据的序列化和反序列化
//----------------------------------------------------------------------------
@implementation YSCStorageData (Archive)
// 公共配置文件存取
- (void)setConfigValue:(NSObject *)value forKey:(NSString *)key {
    [self setConfigWithValuesAndKeys:value, key, nil];
}
- (void)setConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    va_list args;
    va_start(args, firstObject);
    for (id value = firstObject; value != nil; value = va_arg(args, id)) {
        id key = va_arg(args, id);
        [values addObject:value];
        [keys addObject:key];
    }
    va_end(args);
    
    int valueCount = [values count];
    if (valueCount != [keys count]) {
        NSLog(@"set config error : objects and keys don’t have the same number of elements.");
    }
    else {
        NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
        for(int index = 0; index < valueCount; index ++) {
            [configDictionary setObject:[values objectAtIndex:index] forKey:[keys objectAtIndex:index]];
        }
        [self archiveDictionary:configDictionary toFilePath:[self filePathOfCommonSettings] overwrite:NO];
    }
    
}
- (id)configValueForKey:(NSString *)key {
    if ([self _isEmpty:key]) {
        return nil;
    }
    
    NSDictionary *config = [self unarchiveDictionaryFromFilePath:[self filePathOfCommonSettings]];
    return config[key];
}

// 用户配置文件存取
- (void)setUserConfigValue:(NSObject *)value forKey:(NSString *)key {
    [self setUserConfigWithValuesAndKeys:value, key, nil];
}
- (void)setUserConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    va_list args;
    va_start(args, firstObject);
    for (id value = firstObject; value != nil; value = va_arg(args, id)) {
        id key = va_arg(args, id);
        [values addObject:value];
        [keys addObject:key];
    }
    va_end(args);
    
    int valueCount = [values count];
    if (valueCount != [keys count]) {
        NSLog(@"set config error : objects and keys don’t have the same number of elements.");
    }
    else {
        NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
        for(int index = 0; index < valueCount; index ++) {
            [configDictionary setObject:[values objectAtIndex:index] forKey:[keys objectAtIndex:index]];
        }
        [self archiveDictionary:configDictionary toFilePath:[self filePathOfUserSettings] overwrite:NO];
    }
}
- (id)userConfigValueForKey:(NSString *)key {
    if ([self _isEmpty:key]) {
        return nil;
    }
    
    NSDictionary *userConfig = [self unarchiveDictionaryFromFilePath:[self filePathOfUserSettings]];
    return userConfig[key];
}

// 序列化
- (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath {
    NSDictionary *dictionary;
    @try {
        dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    @catch(NSException *exception) {
        NSLog(@"unarchive error:%@", [exception debugDescription]);
    }
    @finally {
        
    }
    return dictionary;
}
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath {
    return [self archiveDictionary:dicionary toFilePath:filePath overwrite:NO];
}
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite {
    if (overwrite) {
        return [NSKeyedArchiver archiveRootObject:dicionary toFile:filePath];
    }
    else {
        NSMutableDictionary *allDictionary = [NSMutableDictionary dictionaryWithCapacity:[dicionary count]];
        [allDictionary addEntriesFromDictionary:[self unarchiveDictionaryFromFilePath:filePath]];
        [allDictionary addEntriesFromDictionary:dicionary];
        return [NSKeyedArchiver archiveRootObject:allDictionary toFile:filePath];
    }
}

// 删除Documents和Caches目录中的缓存数据，并确保所有缓存目录都存在
- (void)clearLibraryCaches {
    //Documents
    [YSCFileUtils clearDirectoryPath:self.directoryPathOfDocumentsLog];
    
    //Library/Caches
    [YSCFileUtils clearDirectoryPath:self.directoryPathOfLibraryCachesCommon];
    [YSCFileUtils clearDirectoryPath:self.directoryPathOfLibraryCachesBundleIdentifier];
    
    [self _ensureCommonDirectories];
    [self _ensureUserDirectories];
}
@end



//----------------------------------------------------------------------------
//  处理缓存数据
//----------------------------------------------------------------------------
@implementation YSCStorageData (Cache)
//------------------------------------
//Document/YSCKit_Storage
//该目录下的数据与业务逻辑相关，删除会影响逻辑
//overwrite = NO
//------------------------------------
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key {
    return [self saveObject:object forKey:key fileName:nil subFolder:nil];
}
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName {
    return [self saveObject:object forKey:key fileName:fileName subFolder:nil];
}
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self saveObject:object forKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfDocumentsCommon]];
}

//------------------------------------
//Library/Caches/YSCKit_Storage
//该目录下的数据随时都可以被清除，与用户无关
//overwrite = NO
//------------------------------------
- (BOOL)saveCacheObject:(NSObject *)object forKey:(NSString *)key {
    return [self saveCacheObject:object forKey:key fileName:nil subFolder:nil];
}
- (BOOL)saveCacheObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self saveObject:object forKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfLibraryCachesCommon]];
}


//------------------------------------
//
// Document/YSCKit_Storage
//
//------------------------------------
- (id)getObjectForKey:(NSString *)key {
    return [self getObjectForKey:key fileName:nil subFolder:nil];
}
- (id)getObjectForKey:(NSString *)key fileName:(NSString *)fileName {
    return [self getObjectForKey:key fileName:fileName subFolder:nil];
}
- (id)getObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self getObjectForKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfDocumentsCommon]];
}

//------------------------------------
//
// Library/Caches/YSCKit_Storage
//
//------------------------------------
- (id)getCacheObjectForKey:(NSString *)key {
    return [self getCacheObjectForKey:key fileName:nil subFolder:nil];
}
- (id)getCacheObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self getObjectForKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfLibraryCachesCommon]];
}

//------------------------------------
//
// 两个通用方法：存储数据、获取数据
//
//------------------------------------
//存数据的通用方法
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFolerName folder:(NSString *)folderPath {
    ReturnNOWhenObjectIsEmpty(key)
    ReturnNOWhenObjectIsEmpty(folderPath)
    if (nil == object) {
        object = [NSNull null];
    }
    
    if (isNotEmpty(subFolerName)) {
        folderPath = [folderPath stringByAppendingPathComponent:subFolerName];
    }
    if (isEmpty(fileName)) {
        fileName = @"CommonSettings";
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL isSuccess = NO;
    @try {
        isSuccess = [STORAGEMANAGER archiveDictionary:@{ key : object }
                                           toFilePath:filePath
                                            overwrite:NO];
    }
    @catch (NSException *exception){
        NSLog(@"将数组保存至本地缓存时出错！%@", exception); //可能是没有在对象里做序列号和反序列化！
        isSuccess = NO;
    }
    return isSuccess;
}
//获取缓存数据通用方法
- (id)getObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFolerName folder:(NSString *)folderPath {
    ReturnNilWhenObjectIsEmpty(key)
    ReturnNilWhenObjectIsEmpty(folderPath)
    
    if (isNotEmpty(subFolerName)) {
        folderPath = [folderPath stringByAppendingPathComponent:subFolerName];
    }
    if (isEmpty(fileName)) {
        fileName = @"CommonSettings";
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    NSDictionary *cacheInfo = [STORAGEMANAGER unarchiveDictionaryFromFilePath:filePath];
    NSObject *value = cacheInfo[key];
    if (nil != value && NO == [value isKindOfClass:[NSNull class]]) {
        return value;
    }
    else {
        return nil;
    }
}

@end