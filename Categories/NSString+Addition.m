//
//  NSString+Addition.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-2.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "NSString+Addition.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展
//
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (Addition)

#pragma mark - 静态方法

+ (BOOL)isEmptyConsiderWhitespace:(NSString *)string {
	if ([NSString isNotEmpty:string]) {
		return ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
	}
	else {
		return YES;
	}
}

+ (BOOL)isNotEmptyConsiderWhitespace:(NSString *)string {
    return ( ! [self isEmptyConsiderWhitespace:string]);
}


#pragma mark - 字符串合法性判断
+ (BOOL)isContains:(NSString *)subString inString:(NSString *)string {
    ReturnNOWhenObjectIsEmpty(string)
    return [string isContains:subString];
}

- (BOOL)isContains:(NSString *)subString {
	ReturnNOWhenObjectIsEmpty(subString)
	return [self rangeOfString:subString].location != NSNotFound;
}

+ (BOOL)isMatchRegexType:(RegexType)regexType withString:(NSString *)string {
    ReturnNOWhenObjectIsEmpty(string)
    return [string isMatchRegexType:regexType];
}

- (BOOL)isMatchRegexType:(RegexType)regexType {
	if (regexType == RegexTypeAllNumbers) {
		return [NSString isMatchRegex:RegexAllNumbers withString:self];
	}
	else if (regexType == RegexTypeEmail) {
		return [NSString isMatchRegex:RegexEmail withString:self];
	}
	else if (regexType == RegexTypeIdentityCard) {
		return [NSString isMatchRegex:RegexIdentityCard withString:self];
	}
	else if (regexType == RegexTypeMobilePhone) {
		return [NSString isMatchRegex:RegexMobilePhone withString:self];
	}
	else if (regexType == RegexTypeNickName) {
		return [NSString isMatchRegex:RegexNickName withString:self];
	}
	else if (regexType == RegexTypePassword) {
		return [NSString isMatchRegex:RegexPassword withString:self];
	}
	else if (regexType == RegexTypeUserName) {
		return [NSString isMatchRegex:RegexUserName withString:self];
	}
	return NO;
}

+ (BOOL)isMatchRegex:(NSString*)pattern withString:(NSString *)string {
    ReturnNOWhenObjectIsEmpty(string)
    return [string isMatchRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (BOOL)isMatchRegex:(NSString*)pattern withString:(NSString *)string options:(NSRegularExpressionOptions)options {
    ReturnNOWhenObjectIsEmpty(string)
    return [string isMatchRegex:pattern options:options];
}
- (BOOL)isMatchRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
	ReturnNOWhenObjectIsEmpty(pattern)
    
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

+ (BOOL)isUrl:(NSString *)string {
    ReturnNOWhenObjectIsEmpty(string)
    return [string isUrl];
}

- (BOOL)isUrl {
    return [NSString isMatchRegex:RegexUrl withString:self];
}

+ (BOOL)isNotUrl:(NSString *)string {
    return ![self isUrl:string];
}


#pragma mark - 字符串比较
+ (VersionCompareResult)compareBetweenVersion:(NSString *)version1 withVersion:(NSString *)version2 {
    if ([NSObject isEmpty:version1]) {
        return VersionCompareResultAscending;
    }
    return [version1 compareWithVersion:version2];
}

- (VersionCompareResult)compareWithVersion:(NSString *)version2 {
    if ([NSObject isEmpty:version2]) {
        return VersionCompareResultDescending;
    }
    
    //-----------把version按字符串'.'分解成数组------------------
    //TODO:暂时没有想到其它更好的算法
    VersionCompareResult compareResult = VersionCompareResultSame;
    NSArray *version1Array = [NSString splitString:self byRegex:@"\\."];//正则表达式中'.'是特殊字符
    NSArray *version2Array = [NSString splitString:version2 byRegex:@"\\."];//正则表达式中'.'是特殊字符
    for (int i = 0; i < MIN([version1Array count], [version2Array count]); i++) {
        NSInteger version1Value = [version1Array[i] integerValue];
        NSInteger version2Value = [version2Array[i] integerValue];
        if (version1Value > version2Value) {
            compareResult = VersionCompareResultDescending;
            break;
        }
        else if (version1Value < version2Value) {
            compareResult = VersionCompareResultAscending;
            break;
        }
    }
    if (compareResult == VersionCompareResultSame) {
        if ([version1Array count] > [version2Array count]) {
            compareResult = VersionCompareResultDescending;
        }
        else if ([version1Array count] < [version2Array count]) {
         compareResult = VersionCompareResultAscending;
        }
    }
    return compareResult;
    //--------------------------END-------------------------
}


#pragma mark - 字符串简单变换
+ (NSString *)trimString:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string trimString];
}

- (NSString *)trimString {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string replaceByRegex:pattern to:toString options:NSRegularExpressionCaseInsensitive];
}
+ (NSString *)replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string replaceByRegex:pattern to:toString options:options];
}

- (NSString *)replaceByRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options{
    ReturnEmptyWhenObjectIsEmpty(pattern)
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
    return [[expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:toString] trimString];
}

/**
 * 移除字符串最后一个字符
 */
+ (NSString *)removeLastCharOfString:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string removeLastChar];
}
- (NSString *)removeLastChar {
    return [self substringToIndex:[self length] - 1];
}
+ (void)removeLastCharOfMutableString:(NSMutableString *)mutableString {
    ReturnWhenObjectIsEmpty(mutableString)
    [mutableString deleteCharactersInRange:NSMakeRange([mutableString length] - 1, 1)];
}

#pragma mark - 汉字转拼音
+ (NSString *)toPinYin:(NSString *)hanzi {
    ReturnEmptyWhenObjectIsEmpty(hanzi)
    return [hanzi toPinYin];
}
- (NSString *)toPinYin {
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [NSString stringWithString:mutableString];
}

#pragma mark - 字符串分解
+ (NSArray *)splitString:(NSString *)string byRegex:(NSString *)pattern {
    if ([NSString isEmpty:string]) {
        return @[];
    }
    return [string splitByRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (NSArray *)splitString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options{
    if ([NSString isEmpty:string]) {
        return @[];
    }
    return [string splitByRegex:pattern options:options];
}
- (NSArray *)splitByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if ([NSString isEmpty:pattern]) {
        return @[];
    }
#define SpecialPlaceholderString @"_&&_"   //特殊占位符
    NSString *newString = [self replaceByRegex:pattern to:SpecialPlaceholderString options:options];
    NSArray *sourceArray = [newString componentsSeparatedByString:SpecialPlaceholderString];
	NSMutableArray *components = [NSMutableArray array];
	for (NSString *component in sourceArray) {
		if (![NSString isEmptyConsiderWhitespace:component]) {
			[components addObject:[component trimString]];
		}
	}
	return components;
}

+ (NSArray *)matchesInString:(NSString *)string byRegex:(NSString *)pattern {
    if ([NSString isEmpty:string]) {
        return @[];
    }
    return [string matchesByRegex:pattern options:NSRegularExpressionCaseInsensitive];
}
+ (NSArray *)matchesInString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if ([NSString isEmpty:string]) {
        return @[];
    }
    return [string matchesByRegex:pattern options:options];
}
- (NSArray *)matchesByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if ([NSString isEmpty:pattern]) {
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






///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展——加密解密
//
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (Security)

#define DEFAULTKEY      @"&*^YHGd5"                     //默认秘钥
#define DEFAULTIV       { 11, 17, 37, 43, 59, 61, 97, 83 }       //默认向量

#pragma mark - base64加密解密(标准的)
+ (NSString *)Base64Encrypt:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string Base64EncryptString];
}

- (NSString *)Base64EncryptString {
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptData = [sourceData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
	return [[NSString alloc] initWithData:encryptData encoding:NSUTF8StringEncoding];
}

+ (NSString *)Base64Decrypt:(NSString *)string {
	ReturnEmptyWhenObjectIsEmpty(string)
    return [string Base64DecryptString];
}

- (NSString *)Base64DecryptString {
    NSData *encryptData = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSData *decryptData = [[NSData alloc] initWithBase64EncodedData:encryptData options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}


#pragma mark - AES加密解密
+ (NSString *)AESEncrypt:(NSString *)string {
    if ([NSString isEmpty:string]) {
        return @"";
    }
    return [string AESEncryptString];
}

- (NSString *)AESEncryptString {
	return [NSString AESEncrypt:self useKey:DEFAULTKEY];
}

+ (NSString *)AESEncrypt:(NSString *)string useKey:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(string)
    ReturnEmptyWhenObjectIsEmpty(key)
	NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptData = [self AESEncryptData:sourceData useKey:key];
	return [self dataBytesToHexString:encryptData];
}
//私有方法
+ (NSData *)AESEncryptData:(NSData *)data useKey:(NSString *)key {
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

+ (NSString *)AESDecrypt:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
	return [string AESDecryptString];
}

- (NSString *)AESDecryptString {
    return [NSString AESDecrypt:self useKey:DEFAULTKEY];
}

+ (NSString *)AESDecrypt:(NSString *)string useKey:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(string)
    ReturnEmptyWhenObjectIsEmpty(key)
	NSData *encryptData = [self hexStringToDataBytes:string];
	NSData *decryptData = [self AESDecryptData:encryptData useKey:key];
	return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}
//私有方法
+ (NSData *)AESDecryptData:(NSData *)data useKey:(NSString *)key {
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



#pragma mark - DES加密解密
+ (NSString *)DESEncrypt:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
	return [string DESEncryptString];
}

- (NSString *)DESEncryptString {
    return [NSString DESEncrypt:self useKey:DEFAULTKEY];
}

+ (NSString *)DESEncrypt:(NSString *)string useKey:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(string)
    ReturnEmptyWhenObjectIsEmpty(key)
	NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptData = [self DESEncryptData:sourceData useKey:key];
	return [self dataBytesToHexString:encryptData];
}
//私有方法
+ (NSData *)DESEncryptData:(NSData *)data useKey:(NSString *)key {
	static Byte iv[] = DEFAULTIV;
    
	NSUInteger dataLength = [data length];
	size_t bufferSize = dataLength + kCCBlockSizeDES;
	void *buffer = malloc(bufferSize);
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
	                                      kCCAlgorithmDES,
	                                      kCCOptionPKCS7Padding | kCCOptionECBMode,
	                                      [key UTF8String],
	                                      kCCKeySizeDES,
	                                      iv,
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

+ (NSString *)DESDecrypt:(NSString *)string {
	ReturnEmptyWhenObjectIsEmpty(string)
	return [string DESDecryptString];
}

- (NSString *)DESDecryptString {
    return [NSString DESDecrypt:self useKey:DEFAULTKEY];
}

+ (NSString *)DESDecrypt:(NSString *)string useKey:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(string)
    ReturnEmptyWhenObjectIsEmpty(key)
	NSData *encryptData = [self hexStringToDataBytes:string];
	NSData *decryptData = [self DESDecryptData:encryptData useKey:key];
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}
//私有方法
+ (NSData *)DESDecryptData:(NSData *)data useKey:(NSString *)key {
	static Byte iv[] = DEFAULTIV;
    
	NSUInteger dataLength = [data length];
	size_t bufferSize = dataLength + kCCBlockSizeDES;
	void *buffer = malloc(bufferSize);
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
	                                      kCCAlgorithmDES,
	                                      kCCOptionPKCS7Padding | kCCOptionECBMode,
	                                      [key UTF8String],
	                                      kCCKeySizeDES,
	                                      iv,
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

#pragma mark - RSA加密解密
//TODO:需要调用openssl标准函数实现



#pragma mark - MD5加密(标准的)
+ (NSString *)MD5Encrypt:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string MD5EncryptString];
}

- (NSString*)MD5EncryptString {
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([sourceData bytes], [sourceData length], result);
    
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
	        result[0], result[1], result[2], result[3],
	        result[4], result[5], result[6], result[7],
	        result[8], result[9], result[10], result[11],
	        result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - SHA1HASH加密
+ (NSString *)Sha1Hash:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string Sha1HashString];
}

- (NSString *)Sha1HashString {
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([sourceData bytes], [sourceData length], result);
    
	return [NSString stringWithFormat:
	        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
	        result[0], result[1], result[2], result[3],
	        result[4], result[5], result[6], result[7],
	        result[8], result[9], result[10], result[11],
	        result[12], result[13], result[14], result[15],
	        result[16], result[17], result[18], result[19]
            ];
}

#pragma mark UTF8编码解码
+ (NSString *)UTF8Encoded:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string UTF8EncodedString];
}

- (NSString *)UTF8EncodedString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8));
}

+ (NSString *)UTF8Decoded:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string UTF8DecodedString];
}

- (NSString *)UTF8DecodedString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                 (CFStringRef)self,
                                                                                                 CFSTR(""),
                                                                                                 kCFStringEncodingUTF8));
}

#pragma mark - URL编码解码
+ (NSString *)URLEncode:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string URLEncodeString];
}
- (NSString *)URLEncodeString {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)URLDecode:(NSString *)string {
    ReturnEmptyWhenObjectIsEmpty(string)
    return [string URLDecodeString];
}

- (NSString *)URLDecodeString {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 私有方法
/**
 *  将NSData数组转换成十六进制字符串
 *
 */
+ (NSString *)dataBytesToHexString:(NSData *)data {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([data length] * 2)];
	const unsigned char *dataBuffer = [data bytes];
	int i;
	for (i = 0; i <= [data length]; ++i) {
		[stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
	}
	return [stringBuffer copy];
}

/**
 *  将十六进制字符串转化成NSData数组
 *
 */
+ (NSData *)hexStringToDataBytes:(NSString *)string {
	NSMutableData *data = [NSMutableData data];
	int idx;
	for (idx = 0; idx + 2 < string.length; idx += 2) {
		NSString *hexStr = [string substringWithRange:NSMakeRange(idx, 2)];
		NSScanner *scanner = [NSScanner scannerWithString:hexStr];
		unsigned int intValue;
		[scanner scanHexInt:&intValue];
		[data appendBytes:&intValue length:1];
	}
	return data;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSString扩展——带emoji表情的富文本显示
//  Created by Joey on 14-9-17.
//  Copyright (c) 2014年 JoeytatEmojiText. All rights reserved.
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (EmojiAttributedString)

+ (NSAttributedString *)emojiAttributedString:(NSString *)string withFont:(UIFont *)font {
    ReturnNilWhenObjectIsEmpty(string)
    ReturnNilWhenObjectIsEmpty(font);
    NSMutableAttributedString *parsedOutput = [[NSMutableAttributedString alloc]initWithString:string
                                                                                    attributes:@{NSFontAttributeName : font}];
    // 1. 获取本地表情 Dictionary
    NSDictionary *emojiPlistDic = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"]];
    
    // 2. 正则匹配获取 parsedOutput 中符合表情代码的 range，图片代码暂时使用 ![图片名称]
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\!\\[[A-Za-z0-9]*\\]" options:0 error:nil];
    NSArray* matches = [regex matchesInString:[parsedOutput string]
                                      options:NSMatchingWithoutAnchoringBounds
                                        range:NSMakeRange(0, parsedOutput.length)];
    
    // 3. 遍历 parsedOutput 中的属性以获取字体显示高度
    __block CGFloat emojiSize;
    [parsedOutput enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, parsedOutput.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if(value){
            emojiSize = ((UIFont *)value).lineHeight;
        }
    }];
    
    // 4. 倒序遍历 match 到的 range
    for (NSTextCheckingResult* result in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [result range];
        NSRange captureRange = [result rangeAtIndex:0];
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        // 5. 通过图片代码找到图片
        UIImage *emojiImage = [UIImage imageNamed:emojiPlistDic[[parsedOutput.string substringWithRange:captureRange]]];
        // 6. 将图片 Size 修改为符合字体的大小
        textAttachment.image = [YSCImageUtils resizeImage:emojiImage toSize:CGSizeMake(emojiSize,emojiSize)];
        // 7. 将之前 match 到的图片代码替换为含有 Emoji 表情的 NSAttributeString
        NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [parsedOutput replaceCharactersInRange:matchRange withAttributedString:rep];
    }
    
    return parsedOutput;
}

+ (CGFloat)HeightOfEmojiString:(NSString *)string maxWidth:(CGFloat)width withFont:(UIFont *)font {
    ReturnZeroWhenObjectIsEmpty(string)
    ReturnZeroWhenObjectIsEmpty(font)
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [textView.textStorage setAttributedString:[self emojiAttributedString:string withFont:font]];
    return [textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
}

+ (CGFloat)WidthOfEmojiString:(NSString *)string maxHeight:(CGFloat)height withFont:(UIFont *)font {
    ReturnZeroWhenObjectIsEmpty(string)
    ReturnZeroWhenObjectIsEmpty(font)
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [textView.textStorage setAttributedString:[self emojiAttributedString:string withFont:font]];
    return [textView sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)].width;
}


+ (CGFloat)HeightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font {
    CGSize size;
    #if IOS7_OR_LATER
            size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName : font}
                                      context:nil].size;
    #else
            size = [string sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    #endif
    NSLog(@"%@: W: %.f, H: %.f", self, size.width, size.height);
    return size.height;
}

+ (CGFloat)WidthOfNormalString:(NSString*)string maxHeight:(CGFloat)height withFont:(UIFont*)font {
    CGSize size;
#if IOS7_OR_LATER
    size = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height)
                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                             attributes:@{NSFontAttributeName : font}
                                context:nil].size;
#else
    size = [string sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    NSLog(@"%@: W: %.f, H: %.f", self, size.width, size.height);
    return size.width;
}

@end



