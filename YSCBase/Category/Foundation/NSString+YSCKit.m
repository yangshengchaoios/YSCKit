//
//  NSString+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSString+YSCKit.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


//==============================================================================
//
//  常用功能
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit)
+ (BOOL)ysc_isEmptyConsiderWhitespace:(NSString *)string {
    RETURN_YES_WHEN_OBJECT_IS_EMPTY(string)
    return ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}
+ (BOOL)ysc_isNotEmptyConsiderWhitespace:(NSString *)string {
    return ( ! [self ysc_isEmptyConsiderWhitespace:string]);
}
+ (BOOL)ysc_isContains:(NSString *)subString inString:(NSString *)string {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_isContains:subString];
}
- (BOOL)ysc_isContains:(NSString *)subString {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(subString)
    return [self rangeOfString:subString].location != NSNotFound;
}
+ (BOOL)ysc_isMatchRegex:(NSString*)pattern withString:(NSString *)string {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_isMatchRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (BOOL)ysc_isMatchRegex:(NSString*)pattern withString:(NSString *)string options:(NSRegularExpressionOptions)options {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_isMatchRegex:pattern options:options];
}
- (BOOL)ysc_isMatchRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(pattern)
    
    //方法一：缺点是无法兼容大小写的情况
    //	NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    //	return [identityCardPredicate evaluateWithObject:self];
    
    //方法二：
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:options
                                                                                  error:&error];
    if (error) {
        NSLog(@"Error by creating Regex: %@",[error description]);
        return NO;
    }
    
    return ([expression numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0);
}
+ (BOOL)ysc_isWebUrlByString:(NSString *)string {
    return [NSString ysc_isMatchRegex:YSCConfigManagerInstance.regexWebUrl withString:string];
}
+ (BOOL)ysc_isNotWebUrlByString:(NSString *)string {
    return ! [self ysc_isWebUrlByString:string];
}

// 字符串简单变换
+ (NSString *)ysc_trimString:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_trimString];
}
- (NSString *)ysc_trimString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
//将json字符串转换成dict
+ (NSObject *)ysc_jsonObjectOfString:(NSString *)string {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_jsonObjectOfString];
}
- (NSObject *)ysc_jsonObjectOfString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSObject *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return json;
}
//将id对象转换成json字符串
+ (NSString *)ysc_jsonStringWithObject:(id)object {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(object)
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0  || error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        return @"";
    }
}

+ (NSString *)ysc_replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_replaceByRegex:pattern to:toString options:NSRegularExpressionCaseInsensitive];
}
+ (NSString *)ysc_replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_replaceByRegex:pattern to:toString options:options];
}
- (NSString *)ysc_replaceByRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options{
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(pattern)
    //方法一：缺点是仅仅用于普通字符串，无法兼容正则表达式的情况
    //	return [self stringByReplacingOccurrencesOfString:pattern withString:toString];
    
    //方法二：
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:options
                                                                                  error:&error];
    if (error) {
        NSLog(@"Error by creating Regex: %@",[error description]);
        return @"";
    }
    return [[expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:toString] ysc_trimString];
}
//计算字符串的长度（1个英文字母为1个字节，1个汉字为2个字节）
+ (NSInteger)ysc_stringLength:(NSString *)string {
    RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_stringLength];
}
- (NSInteger)ysc_stringLength {
    //    //方法一：有的汉字长度为1，如 '开'
    //    int strlength = 0;
    //    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    //    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
    //        if (*p) {
    //            p++;
    //            strlength++;
    //        }
    //        else {
    //            p++;
    //        }
    //    }
    //    return strlength;
    //
    //    //方法二：有的汉字长度为1，如 '开'
    //    NSUInteger words = 0;
    //    NSScanner *scanner = [NSScanner scannerWithString:self];
    //    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    //    while ([scanner scanUpToCharactersFromSet:whiteSpace intoString:nil])
    //        words++;
    //    return words;
    
    //方法三：暂时没有发现汉字计算错误的情况
    int l = 0,a = 0,b = 0;
    unichar c;
    for(int i = 0; i < [self length]; i++){
        c = [self characterAtIndex:i];
        if(isblank(c)) {
            b++;
        }
        else if(isascii(c)) {
            a++;
        }
        else {
            l++;
        }
    }
    return 2 * l + (a + b);
}
//移除字符串最后一个字符
+ (NSString *)ysc_removeLastCharOfString:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_removeLastChar];
}
- (NSString *)ysc_removeLastChar {
    return [self substringToIndex:[self length] - 1];
}
+ (void)ysc_removeLastCharOfMutableString:(NSMutableString *)mutableString {
    RETURN_WHEN_OBJECT_IS_EMPTY(mutableString)
    [mutableString deleteCharactersInRange:NSMakeRange([mutableString length] - 1, 1)];
}
//获取末尾N个字符
+ (NSString *)ysc_substringFromEnding:(NSString *)string count:(NSInteger)count {
    return [string ysc_substringFromEnding:count];
}
- (NSString *)ysc_substringFromEnding:(NSInteger)count {
    NSString *str = TRIM_STRING(self);
    return [str substringFromIndex:MAX((int)[str length] - count, 0)];
}

// 汉字转拼音
+ (NSString *)ysc_toPinYin:(NSString *)hanzi {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(hanzi)
    return [hanzi ysc_toPinYin];
}
- (NSString *)ysc_toPinYin {
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [NSString stringWithString:mutableString];
}

// 头字母大小写转换
- (NSString *)ysc_firstCharUpper {
    if (self.length == 0) {
        return self;
    }
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].uppercaseString];
    if (self.length >= 2) {
        [string appendString:[self substringFromIndex:1]];
    }
    return string;
}
- (NSString *)ysc_firstCharLower {
    if (self.length == 0) {
        return self;
    }
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].lowercaseString];
    if (self.length >= 2) {
        [string appendString:[self substringFromIndex:1]];
    }
    return string;
}

// 字符串分解
+ (NSArray *)ysc_splitString:(NSString *)string byRegex:(NSString *)pattern {
    if (OBJECT_IS_EMPTY(string)) {
        return @[];
    }
    return [string ysc_splitByRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (NSArray *)ysc_splitString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options{
    if (OBJECT_IS_EMPTY(string)) {
        return @[];
    }
    return [string ysc_splitByRegex:pattern options:options];
}
- (NSArray *)ysc_splitByRegex:(NSString *)pattern {
    return [self ysc_splitByRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
- (NSArray *)ysc_splitByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if (OBJECT_IS_EMPTY(pattern)) {
        return @[];
    }
#define SpecialPlaceholderString @"_&&_"   //特殊占位符
    NSString *newString = [self ysc_replaceByRegex:pattern to:SpecialPlaceholderString options:options];
    NSArray *sourceArray = [newString componentsSeparatedByString:SpecialPlaceholderString];
    NSMutableArray *components = [NSMutableArray array];
    for (NSString *component in sourceArray) {
        if (![NSString ysc_isEmptyConsiderWhitespace:component]) {
            [components addObject:[component ysc_trimString]];
        }
    }
    return components;
}

+ (NSArray *)ysc_matchesInString:(NSString *)string byRegex:(NSString *)pattern {
    if (OBJECT_IS_EMPTY(string)) {
        return @[];
    }
    return [string ysc_matchesByRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (NSArray *)ysc_matchesInString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if (OBJECT_IS_EMPTY(string)) {
        return @[];
    }
    return [string ysc_matchesByRegex:pattern options:options];
}
- (NSArray *)ysc_matchesByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if (OBJECT_IS_EMPTY(pattern)) {
        return @[];
    }
    
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:options
                                                                                  error:&error];
    if (error) {
        NSLog(@"Error by creating Regex: %@",[error description]);
        return @[];
    }
    
    //方法一：
    //    NSArray *matchesRangeArray = [expression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    //    NSMutableArray *matchesArray = [NSMutableArray new];
    //    for (NSTextCheckingResult *match in matchesRangeArray) {
    //        NSString* substringForMatch = [self substringWithRange:match.range];
    //        //match.numberOfRanges 只有在pattern是分组的情况下，会大于1，通常这样的情况很少
    //        [matchesArray addObject:substringForMatch];
    //    }
    
    //方法二：
    __block NSMutableArray *matchesArray = [NSMutableArray array];
    [expression enumerateMatchesInString:self
                                 options:0
                                   range:NSMakeRange(0, [self length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  NSString* substringForMatch = [self substringWithRange:result.range];
                                  [matchesArray addObject:substringForMatch];
                              }];
    
    return matchesArray;
}
@end



//==============================================================================
//
//  针对NSString扩展——加密解密
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit_Security)
#define DEFAULT_KEY      @"&65Rfh'}00000000"                     //默认秘钥

// base64加密解密(标准的)
+ (NSString *)ysc_Base64Encrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_Base64EncryptString];
}
- (NSString *)ysc_Base64EncryptString {
    return [NSString ysc_EncodeBase64Data:[self dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (NSString *)ysc_EncodeBase64Data:(NSData *)data {
    NSData *encryptBase64Data = [data base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return [[NSString alloc] initWithData:encryptBase64Data encoding:NSUTF8StringEncoding];
}
+ (NSString *)ysc_Base64Decrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_Base64DecryptString];
}
- (NSString *)ysc_Base64DecryptString {
    return [NSString ysc_DecodeBase64Data:[self dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (NSString *)ysc_DecodeBase64Data:(NSData *)data {
    NSData *decryptData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}

// AES加密解密(标准的)
+ (NSString *)ysc_AESEncrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_AESEncryptString];
}
- (NSString *)ysc_AESEncryptString {
    return [NSString ysc_AESEncrypt:self byKey:DEFAULT_KEY];
}
+ (NSString *)ysc_AESEncrypt:(NSString *)string byKey:(NSString *)key {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(key)
    NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [self _ysc_AESEncryptData:sourceData byKey:key];
    return [NSString ysc_EncodeBase64Data:encryptData];
}
+ (NSData *)_ysc_AESEncryptData:(NSData *)data byKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
+ (NSString *)ysc_AESDecrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_AESDecryptString];
}
- (NSString *)ysc_AESDecryptString {
    return [NSString ysc_AESDecrypt:self byKey:DEFAULT_KEY];
}
+ (NSString *)ysc_AESDecrypt:(NSString *)string byKey:(NSString *)key {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(key)
    NSData *encryptData = [[NSData alloc] initWithBase64EncodedData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptData = [self _ysc_AESDecryptData:encryptData byKey:key];
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}
+ (NSData *)_ysc_AESDecryptData:(NSData *)data byKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

// DES加密解密
+ (NSString *)ysc_DESEncrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_DESEncryptString];
}
- (NSString *)ysc_DESEncryptString {
    return [NSString ysc_DESEncrypt:self byKey:DEFAULT_KEY];
}
+ (NSString *)ysc_DESEncrypt:(NSString *)string byKey:(NSString *)key {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(key)
    NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [self _ysc_DESEncryptData:sourceData byKey:key];
    return [NSString ysc_EncodeBase64Data:encryptData];
}
+ (NSData *)_ysc_DESEncryptData:(NSData *)data byKey:(NSString *)key {
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
+ (NSString *)ysc_DESDecrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_DESDecryptString];
}
- (NSString *)ysc_DESDecryptString {
    return [NSString ysc_DESDecrypt:self byKey:DEFAULT_KEY];
}
+ (NSString *)ysc_DESDecrypt:(NSString *)string byKey:(NSString *)key {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(key)
    NSData *encryptData = [[NSData alloc] initWithBase64EncodedData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptData = [self _ysc_DESDecryptData:encryptData byKey:key];
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}
+ (NSData *)_ysc_DESDecryptData:(NSData *)data byKey:(NSString *)key {
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

// MD5加密(标准的)
+ (NSString *)ysc_MD5Encrypt:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_MD5EncryptString];
}
- (NSString *)ysc_MD5EncryptString {
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([sourceData bytes], (unsigned int)[sourceData length], result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

// SHA1HASH加密
+ (NSString *)ysc_Sha1Hash:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_Sha1HashString];
}
- (NSString *)ysc_Sha1HashString {
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([sourceData bytes], (unsigned int)[sourceData length], result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}

// UTF8编码解码
+ (NSString *)ysc_UTF8Encoded:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_UTF8EncodedString];
}
- (NSString *)ysc_UTF8EncodedString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 CFSTR("!*'();@&=+$,?%#[]"),
                                                                                 kCFStringEncodingUTF8));
}
+ (NSString *)ysc_UTF8Decoded:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_UTF8DecodedString];
}
- (NSString *)ysc_UTF8DecodedString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                 (CFStringRef)self,
                                                                                                 CFSTR(""),
                                                                                                 kCFStringEncodingUTF8));
}

// URL编码解码=UTF8
+ (NSString *)ysc_URLEncode:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_URLEncodeString];
}
- (NSString *)ysc_URLEncodeString {
    return  [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
+ (NSString *)ysc_URLDecode:(NSString *)string {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(string)
    return [string ysc_URLDecodeString];
}
- (NSString *)ysc_URLDecodeString {
    return [self ysc_UTF8DecodedString];
}
@end



//==============================================================================
//
//  NSString扩展——常用目录
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit_Directory)
+ (NSString *)ysc_directoryPathOfBundle {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        path = [[NSBundle mainBundle] resourcePath];
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfHome {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        path = NSHomeDirectory();
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfDocuments {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            path = [NSString stringWithFormat:@"%@", paths[0]];
        }
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfLibrary {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            path = [NSString stringWithFormat:@"%@", paths[0]];
        }
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfLibraryCaches {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            path = [NSString stringWithFormat:@"%@", paths[0]];
        }
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfLibraryCachesBundleIdentifier {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        NSString *appBundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        path = [[self ysc_directoryPathOfLibraryCaches] stringByAppendingPathComponent:appBundleId];
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfLibraryPreferences {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        path = [[self ysc_directoryPathOfLibrary] stringByAppendingPathComponent:@"Preferences"];
    });
    return path;
}
+ (NSString *)ysc_directoryPathOfTmp {
    static dispatch_once_t pred = 0;
    __strong static NSString *path = @"";
    dispatch_once(&pred, ^{
        path = NSTemporaryDirectory();
    });
    return path;
}
@end



//==============================================================================
//
//  针对NSString扩展——动态大小
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit_DynamicSize)
+ (CGFloat)ysc_heightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font {
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName : font}
                                       context:nil].size;
    return size.height;
}
+ (CGFloat)ysc_widthOfNormalString:(NSString*)string maxHeight:(CGFloat)height withFont:(UIFont*)font {
    CGSize size = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName : font}
                                       context:nil].size;
    return size.width;
}
+ (CGFloat)ysc_heightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font lineSpace:(CGFloat)lineSpace {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle}
                                       context:nil].size;
    return size.height;
}
+ (BOOL)ysc_isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}
@end



//==============================================================================
//
//  针对NSString扩展——显示html文本
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit_Html)
+ (void)ysc_layoutHtmlString:(NSString *)htmlString onView:(UIView *)view {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                                                   options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                        documentAttributes:nil
                                                                     error:nil];
    if ([view respondsToSelector:@selector(setAttributedText:)]) {
        [view performSelector:@selector(setAttributedText:) withObject:attrStr];
    }
}
+ (void)ysc_fillMutableAttributedString:(NSMutableAttributedString *)attributedString byRegular:(NSRegularExpression *)regular attributes:(NSDictionary *)attributes {
    RETURN_WHEN_OBJECT_IS_EMPTY(attributedString)
    RETURN_WHEN_OBJECT_IS_EMPTY(attributedString.string)
    RETURN_WHEN_OBJECT_IS_EMPTY(regular)
    
    NSRange stringRange = NSMakeRange(0, [attributedString.string length]);
    [regular enumerateMatchesInString:attributedString.string
                              options:0
                                range:stringRange
                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                               //0. 获取到匹配的范围
                               NSRange matchRange = [result range];
                               //1. 设置通用的attribute
                               if (attributes) {
                                   [attributedString addAttributes:attributes range:matchRange];
                               }
                               //2. 分别设置匹配项目的attribute
                               if ([result resultType] == NSTextCheckingTypeLink) {
                                   NSURL *url = [result URL];
                                   [attributedString addAttribute:NSLinkAttributeName value:url range:matchRange];
                               }
                               else if ([result resultType] == NSTextCheckingTypePhoneNumber) {
                                   NSString *phoneNumber = [result phoneNumber];
                                   [attributedString addAttribute:NSLinkAttributeName value:phoneNumber range:matchRange];
                               }
                               else {
                                   //其它特殊内容
                               }
                           }];
    
}
/**
 *  将富文本转换成HTML
 *  added by dwk
 */
+ (NSString *)ysc_converRichTextToHTML:(NSAttributedString *)attributedString {
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:exportParams error:nil];
    return [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
}
@end



//==============================================================================
//
//  各种证件号码(身份证、警官证、军官证)合法性判断
//  @Author: Builder
//
//==============================================================================
@implementation NSString (YSCKit_IdentityNumber)
+ (BOOL)ysc_verifyIDCardNumber:(NSString *)value {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(value);
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([value length] != 18) {
        return NO;
    }
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ( ! [regexTest evaluateWithObject:value]) {
        return NO;
    }
    int summary = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7
    + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9
    + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10
    + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5
    + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8
    + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4
    + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2
    + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6
    + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
    NSInteger remainder = summary % 11;
    NSString *checkBit = @"";
    NSString *checkString = @"10X98765432";
    checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
    return [checkBit isEqualToString:[[value substringWithRange:NSMakeRange(17,1)] uppercaseString]];
}
+ (BOOL)ysc_verifyCardNumberWithSoldier:(NSString *)value {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(value);
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *s1 = @"^\\d*$";
    NSString *s2 = @"^.{1,}字第\\d{4,}$";
    if ([NSString ysc_isMatchRegex:s1 withString:value]) {
        return [NSString ysc_isMatchRegex:@"^\\d{4,20}$" withString:value];
    }
    else if ([NSString ysc_lengthUsingChineseCharacterCountByTwo:value] >= 10
             && [NSString ysc_lengthUsingChineseCharacterCountByTwo:value] <= 20) {
        return [NSString ysc_isMatchRegex:s2 withString:value];
    }
    return NO;
}
+ (NSUInteger)ysc_lengthUsingChineseCharacterCountByTwo:(NSString *)string{
    NSUInteger count = 0;
    for (NSUInteger i = 0; i< string.length; ++i) {
        if ([string characterAtIndex:i] < 256) {
            count++;
        } else {
            count += 2;
        }
    }
    return count;
}
+ (NSString *)ysc_getBirthdayByIDCardNumber:(NSString *)IDCardNumber {
    IDCardNumber = [IDCardNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([IDCardNumber length] != 18) {
        return nil;
    }
    NSString *birthady = [NSString stringWithFormat:@"%@年%@月%@日",
                          [IDCardNumber substringWithRange:NSMakeRange(6,4)],
                          [IDCardNumber substringWithRange:NSMakeRange(10,2)],
                          [IDCardNumber substringWithRange:NSMakeRange(12,2)]];
    return birthady;
}
+ (NSInteger)ysc_getGenderByIDCardNumber:(NSString *)IDCardNumber {
    IDCardNumber = [IDCardNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger defaultValue = 0;
    if ([IDCardNumber length] != 18) {
        return defaultValue;
    }
    NSInteger number = [[IDCardNumber substringWithRange:NSMakeRange(16,1)] integerValue];
    if (number % 2 == 0) {  //偶数为女
        return 0;
    } else {
        return 1;
    }
}
@end
