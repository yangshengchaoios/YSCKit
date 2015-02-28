//
//  StorageManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

/**
 * 用来根据不同用户管理文件的存储
 */

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

@property (nonatomic, copy) NSString *directoryPathOfHome;
@property (nonatomic, copy) NSString *directoryPathOfDocuments;
@property (nonatomic, copy) NSString *directoryPathOfLibrary;
@property (nonatomic, copy) NSString *directoryPathOfLibraryCaches;
@property (nonatomic, copy) NSString *directoryPathOfLibraryPreferences;
@property (nonatomic, copy) NSString *directoryPathOfTmp;

+ (instancetype)sharedInstance;

/**
 *	设置用户目录对应的id
 *
 *	@param	userId	用户的id
 */
- (void)setUserId:(NSString *)userId;


#pragma mark - Documents目录下的文件和目录路径
/**
 *  /Documents/UserId/
 *
 *  @return 用户目录
 */
- (NSString *)directoryPathOfDocumentsByUserId;

/**
 *  /Documents/UserId/UserSettings.archive
 *
 *  @return 用户配置信息文件路径
 */
- (NSString *)filePathOfUserSettings;

/**
 *  /Documents/Common/
 *
 *  @return 公共根目录
 */
- (NSString *)directoryPathOfDocumentsCommon;

/**
 *  /Documents/Common/CommonSettings.archive
 *
 *  @return 公共配置信息文件路径
 */
- (NSString *)filePathOfCommonSettings;

/**
 *  /Documents/Log/
 *
 *  @return 公共日志文件目录
 */
- (NSString *)directoryPathOfDocumentsLog;



#pragma mark - Library目录下的文件和目录路径
/**
 *  /Library/Caches/UserId/
 *
 *  @return 用户的缓存目录
 */
- (NSString *)directoryPathOfLibraryCachesByUserId;

/**
 *  /Library/Caches/com.xxx.yyy
 *
 *  @return
 */
- (NSString *)directoryPathOfLibraryCachesBundleIdentifier;

/**
 *  /Library/Caches/UserId/Pics/
 *
 *  @return 用户图片目录
 */
- (NSString *)directoryPathOfPicByUserId;

/**
 *  /Library/Caches/UserId/Audioes/
 *
 *  @return 用户音频目录
 */
- (NSString *)directoryPathOfAudioByUserId;

/**
 *  /Library/Caches/UserId/Videoes/
 *
 *  @return 用户视频目录
 */
- (NSString *)directoryPathOfVideoByUserId;

/**
 *  /Library/Caches/Common/
 *
 *  @return 公共缓存目录
 */
- (NSString *)directoryPathOfLibraryCachesCommon;


#pragma mark - 公共配置文件存取
/**
 *  设置config某个key对应的value
 *
 *  @param value
 *  @param key
 */
- (void)setConfigValue:(NSObject *)value forKey:(NSString *)key;
/**
 *  获取config中key对应的value
 *
 *  @param key
 *
 *  @return value
 */
- (id)configValueForKey:(NSString *)key;


#pragma mark - 用户配置文件存取
/**
 *  设置user的某个key对应的value
 *
 *  @param value
 *  @param key
 */
- (void)setUserConfigValue:(NSObject *)value forKey:(NSString *)key;
/**
 *  获取user的某个key
 *
 *  @param key
 *
 *  @return
 */
- (id)userConfigValueForKey:(NSString *)key;


#pragma mark - 序列化和反序列化归档文件
/**
 *  序列化dict
 *  overwrite = no
 *
 *  @param dicionary 需要缓存的对象
 *  @param filePath 缓存文件的路径
 *
 *  @return
 */
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath;
/**
 *  序列化通用方法
 *
 *  @param dicionary 需要缓存的对象
 *  @param filePath 缓存文件的路径
 *  @param overwrite YES-会把相同filePath的dict替换成新的 NO-相同的filePath合并（里面相同key的值会被新的value代替）
 *
 *  @return
 */
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite;
/**
 *  反序列化
 *
 *  @param filePath 缓存文件的对象
 *
 *  @return
 */
- (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath;



#pragma mark - 缓存清除
/**
 *  删除整个目录/Library/Caches下所有的内容，并确保所有缓存目录都存在
 */
- (void)clearLibraryCaches;


@end
