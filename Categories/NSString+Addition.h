//
//  NSString+Addition.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-2.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>

#define RegexEmail          @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
#define RegexMobilePhone    @"(^(01|1))\\d{10}$"
#define RegexUserName       @"^[A-Za-z0-9]{6,20}+$"
#define RegexPassword       @"^[a-zA-Z0-9]{6,20}+$"
#define RegexNickName       @"^[\u4e00-\u9fa5]{4,8}$"
#define RegexIdentityCard   @"^(\\d{14}|\\d{17})(\\d|[xX])$"
#define RegexAllNumbers     @"^[0-9]\\d*$"
#define RegexUrl            @"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"


/*
 *
 * 注意：本类所有的实例方法都有其对应的静态方法
 * 原因：静态方法有判空处理，实例方法没有，所以使用实例方法有一定的风险，必须自己判空；
 *
 */


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展——常用方法
//
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSString (Addition)

/**
 *  除了三个条件(1-是否为nil 2-是否为NSNull 3-长度是否为0)外，还考虑了是否全部是空格的情况
 *
 *  @param string 要判断的字符串
 *
 *  @return YES/NO
 */
+ (BOOL)isEmptyConsiderWhitespace:(NSString *)string;
+ (BOOL)isNotEmptyConsiderWhitespace:(NSString *)string;


#pragma mark - 字符串合法性判断
+ (BOOL)isContains:(NSString *)subString inString:(NSString *)string;
- (BOOL)isContains:(NSString *)subString;
+ (BOOL)isMatchRegexType:(RegexType)regexType withString:(NSString *)string;
- (BOOL)isMatchRegexType:(RegexType)regexType;

+ (BOOL)isMatchRegex:(NSString*)pattern withString:(NSString *)string;
+ (BOOL)isMatchRegex:(NSString*)pattern withString:(NSString *)string options:(NSRegularExpressionOptions)options;
- (BOOL)isMatchRegex:(NSString*)pattern options:(NSRegularExpressionOptions)options;

+ (BOOL)isUrl:(NSString *)string;
- (BOOL)isUrl;
+ (BOOL)isNotUrl:(NSString *)string;

#pragma mark - 字符串比较
/**
 *  比较两个版本号的大小
 *
 *  @param versionString1 1.2.1
 *  @param versionString2 1.2.2
 *
 *  @return -1:version1小  0:两者相等  1:version1大
 */
+ (VersionCompareResult)compareBetweenVersion:(NSString *)version1 withVersion:(NSString *)version2;
- (VersionCompareResult)compareWithVersion:(NSString *)version2;


#pragma mark - 字符串简单变换
+ (NSString *)trimString:(NSString *)string;
- (NSString *)trimString;
//将json字符串转换成dict
+ (NSDictionary *)dictOfString:(NSString *)string;
- (NSDictionary *)dictOfString;
/**
 *  把符合pattern正则表达式的字符串替换成toString (默认是大小写敏感的)
 *
 *  @param string   原始字符串
 *  @param pattern  正则表达式
 *  @param toString 用来替换的新字符串
 *
 *  @return 变化后的新字符串
 */
+ (NSString *)replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString;
+ (NSString *)replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options;
- (NSString *)replaceByRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options;

/**
 * 移除字符串最后一个字符
 */
+ (NSString *)removeLastCharOfString:(NSString *)string;
- (NSString *)removeLastChar;
+ (void)removeLastCharOfMutableString:(NSMutableString *)mutableString;

#pragma mark - 汉字转拼音
+ (NSString *)toPinYin:(NSString *)hanzi;
- (NSString *)toPinYin;

#pragma mark - 字符串分解
/**
 *  根据分隔符切分字符串为数组 (默认是大小写敏感的)
 *
 *  @param string    待分解的字符串
 *  @param separator 分隔符
 *
 *  @return 分隔后的数组
 */
+ (NSArray *)splitString:(NSString *)string byRegex:(NSString *)pattern;
+ (NSArray *)splitString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSArray *)splitByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
/**
 *  返回匹配regex的数组 (默认是大小写敏感的)
 *
 *  @param string  要匹配的字符串
 *  @param pattern regex表达式
 *
 *  @return 结果数组
 */
+ (NSArray *)matchesInString:(NSString *)string byRegex:(NSString *)pattern;
+ (NSArray *)matchesInString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSArray *)matchesByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展——加密解密
//
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSString (Security)

#pragma mark - base64加密解密(标准的)
+ (NSString *)Base64Encrypt:(NSString *)string;
- (NSString *)Base64EncryptString;
+ (NSString *)EncodeBase64Data:(NSData *)data;
+ (NSString *)Base64Decrypt:(NSString *)string;
- (NSString *)Base64DecryptString;
+ (NSString *)DecodeBase64Data:(NSData *)data;

#pragma mark - AES加密解密(标准的)
+ (NSString *)AESEncrypt:(NSString *)string;
- (NSString *)AESEncryptString;
+ (NSString *)AESEncrypt:(NSString *)string useKey:(NSString *)key;

+ (NSString *)AESDecrypt:(NSString *)string;
- (NSString *)AESDecryptString;
+ (NSString *)AESDecrypt:(NSString *)string useKey:(NSString *)key;

#pragma mark - DES加密解密
+ (NSString *)DESEncrypt:(NSString *)string;
- (NSString *)DESEncryptString;
+ (NSString *)DESEncrypt:(NSString *)string useKey:(NSString *)key;

+ (NSString *)DESDecrypt:(NSString *)string;
- (NSString *)DESDecryptString;
+ (NSString *)DESDecrypt:(NSString *)string useKey:(NSString *)key;


#pragma mark - RSA加密解密
//TODO:需要调用openssl标准函数实现

#pragma mark - MD5加密(标准的)
+ (NSString*)MD5Encrypt:(NSString*)string;
- (NSString*)MD5EncryptString;

#pragma mark - SHA1HASH加密
+ (NSString *)Sha1Hash:(NSString *)string;
- (NSString *)Sha1HashString;

#pragma mark - UTF8编码解码
+ (NSString *)UTF8Encoded:(NSString *)string;
- (NSString *)UTF8EncodedString;
+ (NSString *)UTF8Decoded:(NSString *)string;
- (NSString *)UTF8DecodedString;

#pragma mark - URL编码解码
+ (NSString *)URLEncode:(NSString *)string;
- (NSString *)URLEncodeString;
+ (NSString *)URLDecode:(NSString *)string;
- (NSString *)URLDecodeString;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展——带emoji表情的富文本显示
//  Created by Joey on 14-9-17.
//  Copyright (c) 2014年 JoeytatEmojiText. All rights reserved.
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSString (EmojiAttributedString)

+ (NSAttributedString *)emojiAttributedString:(NSString *)string withFont:(UIFont *)font;
+ (CGFloat)HeightOfEmojiString:(NSString *)string maxWidth:(CGFloat)width withFont:(UIFont *)font;
+ (CGFloat)WidthOfEmojiString:(NSString *)string maxHeight:(CGFloat)height withFont:(UIFont *)font;
+ (CGFloat)HeightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font;
+ (CGFloat)WidthOfNormalString:(NSString*)string maxHeight:(CGFloat)height withFont:(UIFont*)font;

@end



