//
//  NSString+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

//==============================================================================
//
//  常用功能
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit)
/**
 *  除了三个条件(1-是否为nil 2-是否为NSNull 3-长度是否为0)外，还考虑了是否全部是空格的情况
 *  @return YES/NO
 */
+ (BOOL)ysc_isEmptyConsiderWhitespace:(NSString *)string;
+ (BOOL)ysc_isNotEmptyConsiderWhitespace:(NSString *)string;

// 字符串合法性判断
+ (BOOL)ysc_isContains:(NSString *)subString inString:(NSString *)string;
- (BOOL)ysc_isContains:(NSString *)subString;
+ (BOOL)ysc_isMatchRegex:(NSString*)pattern withString:(NSString *)string;
+ (BOOL)ysc_isMatchRegex:(NSString*)pattern withString:(NSString *)string options:(NSRegularExpressionOptions)options;
- (BOOL)ysc_isMatchRegex:(NSString*)pattern options:(NSRegularExpressionOptions)options;
+ (BOOL)ysc_isWebUrlByString:(NSString *)string;
+ (BOOL)ysc_isNotWebUrlByString:(NSString *)string;

// 字符串简单变换
+ (NSString *)ysc_trimString:(NSString *)string;
- (NSString *)ysc_trimString;
// 将json字符串转换成dict
+ (NSObject *)ysc_jsonObjectOfString:(NSString *)string;
- (NSObject *)ysc_jsonObjectOfString;
// 将id对象转换成json字符串
+ (NSString *)ysc_jsonStringWithObject:(id)object;
// 把符合pattern正则表达式的字符串替换成toString (默认是大小写敏感的)
+ (NSString *)ysc_replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString;
+ (NSString *)ysc_replaceString:(NSString *)string byRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options;
- (NSString *)ysc_replaceByRegex:(NSString *)pattern to:(NSString *)toString options:(NSRegularExpressionOptions)options;
// 计算字符串的长度（1个英文字母为1个字节，1个汉字为2个字节）
+ (NSInteger)ysc_stringLength:(NSString *)string;
- (NSInteger)ysc_stringLength;
// 移除字符串最后一个字符
+ (NSString *)ysc_removeLastCharOfString:(NSString *)string;
- (NSString *)ysc_removeLastChar;
+ (void)ysc_removeLastCharOfMutableString:(NSMutableString *)mutableString;
//获取末尾N个字符
+ (NSString *)ysc_substringFromEnding:(NSString *)string count:(NSInteger)count;
- (NSString *)ysc_substringFromEnding:(NSInteger)count;
// 汉字转拼音
+ (NSString *)ysc_toPinYin:(NSString *)hanzi;
- (NSString *)ysc_toPinYin;
// 头字母大小写转换
- (NSString *)ysc_firstCharUpper;
- (NSString *)ysc_firstCharLower;

// 根据分隔符切分字符串为数组 (默认是大小写敏感的)
+ (NSArray *)ysc_splitString:(NSString *)string byRegex:(NSString *)pattern;
+ (NSArray *)ysc_splitString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSArray *)ysc_splitByRegex:(NSString *)pattern;
- (NSArray *)ysc_splitByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
// 返回匹配regex的数组 (默认是大小写敏感的)
+ (NSArray *)ysc_matchesInString:(NSString *)string byRegex:(NSString *)pattern;
+ (NSArray *)ysc_matchesInString:(NSString *)string byRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSArray *)ysc_matchesByRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;
@end


//==============================================================================
//
//  NSString扩展——加密解密
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit_Security)
/** base64加密解密(标准的) */
+ (NSString *)ysc_Base64Encrypt:(NSString *)string;
- (NSString *)ysc_Base64EncryptString;
+ (NSString *)ysc_EncodeBase64Data:(NSData *)data;
+ (NSString *)ysc_Base64Decrypt:(NSString *)string;
- (NSString *)ysc_Base64DecryptString;
+ (NSString *)ysc_DecodeBase64Data:(NSData *)data;

/** AES加密解密(标准的) */
+ (NSString *)ysc_AESEncrypt:(NSString *)string;
- (NSString *)ysc_AESEncryptString;
+ (NSString *)ysc_AESEncrypt:(NSString *)string byKey:(NSString *)key;
+ (NSString *)ysc_AESDecrypt:(NSString *)string;
- (NSString *)ysc_AESDecryptString;
+ (NSString *)ysc_AESDecrypt:(NSString *)string byKey:(NSString *)key;

/** DES加密解密 */
+ (NSString *)ysc_DESEncrypt:(NSString *)string;
- (NSString *)ysc_DESEncryptString;
+ (NSString *)ysc_DESEncrypt:(NSString *)string byKey:(NSString *)key;
+ (NSString *)ysc_DESDecrypt:(NSString *)string;
- (NSString *)ysc_DESDecryptString;
+ (NSString *)ysc_DESDecrypt:(NSString *)string byKey:(NSString *)key;

/** MD5加密(标准的) */
+ (NSString *)ysc_MD5Encrypt:(NSString*)string;
- (NSString *)ysc_MD5EncryptString;

/** SHA1HASH加密 */
+ (NSString *)ysc_Sha1Hash:(NSString *)string;
- (NSString *)ysc_Sha1HashString;

/** UTF8编码解码 */
+ (NSString *)ysc_UTF8Encoded:(NSString *)string;
- (NSString *)ysc_UTF8EncodedString;
+ (NSString *)ysc_UTF8Decoded:(NSString *)string;
- (NSString *)ysc_UTF8DecodedString;

/** URL编码解码=UTF8 */
+ (NSString *)ysc_URLEncode:(NSString *)string;
- (NSString *)ysc_URLEncodeString;
+ (NSString *)ysc_URLDecode:(NSString *)string;
- (NSString *)ysc_URLDecodeString;
@end


//==============================================================================
//
//  NSString扩展——常用目录
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit_Directory)
/** APP打包文件运行的目录 */
+ (NSString *)ysc_directoryPathOfBundle;
/** 沙盒根目录 */
+ (NSString *)ysc_directoryPathOfHome;
/**
 *  /Documents
 *  itunes备份该目录
 *  存放内容：数据库、个性化配置
 */
+ (NSString *)ysc_directoryPathOfDocuments;
/**
 *  /Library
 *  itunes备份该目录除了Caches文件夹
 *  存放内容：数据库、个性化配置
 */
+ (NSString *)ysc_directoryPathOfLibrary;
/**
 *  /Library/Caches
 *  itunes不备份该目录，退出app不被清除
 *  存放内容：页面缓存数据
 */
+ (NSString *)ysc_directoryPathOfLibraryCaches;
/**
 *  /Library/Caches/BOUNLD_ID
 *  itunes不备份该目录
 *  存放内容：APP临时缓存
 */
+ (NSString *)ysc_directoryPathOfLibraryCachesBundleIdentifier;
/**
 *  /Library/Preferences
 *  itunes备份该目录
 *  存放内容：NSUserDefaults（BOUNLD_ID.plist）
 */
+ (NSString *)ysc_directoryPathOfLibraryPreferences;
/**
 *  /tmp
 *  iTunes不备份该目录
 *  当内存吃紧时，被ios系统判断是否需要清空该目录
 *  存放内容：不印象业务逻辑的临时数据，比如要上传的图片；下载的临时文件等。
 */
+ (NSString *)ysc_directoryPathOfTmp;
@end



//==============================================================================
//
//  NSString扩展——动态大小
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit_DynamicSize)
+ (CGFloat)ysc_heightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font;
+ (CGFloat)ysc_widthOfNormalString:(NSString*)string maxHeight:(CGFloat)height withFont:(UIFont*)font;
+ (CGFloat)ysc_heightOfNormalString:(NSString*)string maxWidth:(CGFloat)width withFont:(UIFont*)font lineSpace:(CGFloat)lineSpace;
/** 判断是否包含表情符号(表情范围不够完善) */
+ (BOOL)ysc_isContainsEmoji:(NSString *)string;
@end



//==============================================================================
//
//  NSString扩展——显示html文本
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit_Html)
// UIView(UILabel、UITextField、UITextView)上显示HTML
// 只能显示HTML内容，但不能点击链接
+ (void)ysc_layoutHtmlString:(NSString *)htmlString onView:(UIView *)view;
// 根据正则表达式设置attributedString的各项参数
//  regular: 正则表达式
//  attributes: 每个满足ragular的attri
+ (void)ysc_fillMutableAttributedString:(NSMutableAttributedString *)attributedString
                              byRegular:(NSRegularExpression *)regular
                             attributes:(NSDictionary *)attributes;
/**
 *  将富文本转换成HTML
 *  added by dwk
 */
+ (NSString *)ysc_converRichTextToHTML:(NSAttributedString *)attributedString;
@end

//==============================================================================
//
//  NSString扩展——各种证件号码(身份证、警官证、军官证)合法性判断
//  参考：http://blog.sina.com.cn/s/blog_c409c8cf0102vfx7.html
//  @Author: Builder
//
//==============================================================================
@interface NSString (YSCKit_IdentityNumber)
//验证身份证
//必须满足以下规则
//1. 长度必须是18位，前17位必须是数字，第十八位可以是数字或X
//2. 前两位必须是以下情形中的一种：11,12,13,14,15,21,22,23,31,32,33,34,35,36,37,41,42,43,44,45,46,50,51,52,53,54,61,62,63,64,65,71,81,82,91
//3. 第7到第14位出生年月日。第7到第10位为出生年份；11到12位表示月份，范围为01-12；13到14位为合法的日期
//4. 第17位表示性别，双数表示女，单数表示男
//5. 第18位为前17位的校验位
//算法如下：
//（1）校验和 = (n1 + n11) * 7 + (n2 + n12) * 9 + (n3 + n13) * 10 + (n4 + n14) * 5 + (n5 + n15) * 8 + (n6 + n16) * 4 + (n7 + n17) * 2 + n8 + n9 * 6 + n10 * 3，其中n数值，表示第几位的数字
//（2）余数 ＝ 校验和 % 11
//（3）如果余数为0，校验位应为1，余数为1到10校验位应为字符串“0X98765432”(不包括分号)的第余数位的值（比如余数等于3，校验位应为9）
//6. 出生年份的前两位必须是19或20
+ (BOOL)ysc_verifyIDCardNumber:(NSString *)value; //验证身份证
//验证军官证或警官证
//必须是下面两种格式中的一种
//格式一：4到20位数字
//格式二：大于或等于10位并且小于等于20位（中文按两位），并满足以下规则
//1）必须有“字第”两字
//2）“字第”前面有至少一个字符
//3）“字第”后是4位以上数字
+ (BOOL)ysc_verifyCardNumberWithSoldier:(NSString *)value;
/** 得到身份证的生日****这个方法中不做身份证校验，请确保传入的是正确身份证 */
+ (NSString *)ysc_getBirthdayByIDCardNumber:(NSString *)IDCard;
/** 得到身份证的性别（1男0女）****这个方法中不做身份证校验，请确保传入的是正确身份证 */
+ (NSInteger)ysc_getGenderByIDCardNumber:(NSString *)IDCard;
@end
