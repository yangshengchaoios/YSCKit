//
//  YSCTextField.h
//  EZGoal
//
//  Created by yangshengchao on 15/7/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
//NOTE:
//  1. 输入内容一般包括：字母、数字、汉字、表情符号、标点符号、其它特殊符号
//  2. 正则表达式只判断内容合法性，不判断长度
//  3. IBInspectable暂时只支持的类型为：Int、CGFloat、Double、String、Bool、CGPoint、CGSize、CGRect、UIColor、UIImage

//符号的正则表达式特殊表示
//大写 P 表示 Unicode 字符集七个字符属性之一：标点字符。
//其他六个是
//L：字母；
//M：标记符号（一般不会单独出现）；
//Z：分隔符（比如空格、换行等）；
//S：符号（比如数学符号、货币符号等）；
//N：数字（比如阿拉伯数字、罗马数字等）；
//C：其他字符
typedef NS_ENUM(NSInteger, YSCTextType) {
    //常规内容(通过property组合设置来实现)
//    YSCTextTypeLetterAndNumber  = 0,    //只能是字母和数字(如用户名、密码)  ^[A-Za-z0-9]+$
//    YSCTextTypeNumberAndChinese = 1,    //只能是数字、汉字(如姓名)
//    YSCTextTypeLetterNumberChinese  = 2,//只能是字母、数字、汉字(如昵称、姓名)
//    YSCTextTypeLetter           = 3,    //只能是字母
//    YSCTextTypeNumber           = 4,    //只能是数字
//    YSCTextTypeChinese          = 5,    //只能是汉字

    //特殊内容
    YSCTextTypePhone            = 10,   //电话号码(包括座机、手机号)
    YSCTextTypeMobilePhone      = 11,   //手机号
    YSCTextTypeIdentityNum      = 12,   //身份证号码
    YSCTextTypeEmail            = 13,   //email地址
    YSCTextTypeCarNumber        = 14,   //车牌号至少一位数字
    YSCTextTypeVehicleNumber    = 15,   //车架号后6位
    YSCTextTypeUrl              = 16,   //超链接
    
    //自定义
    YSCTextTypeProperty         = 98,   //完全根据property的设置来校验
    YSCTextTypeCustom           = 99,   //自定义正则表达式
};

@interface YSCTextField : UITextField

@property (nonatomic, assign) IBInspectable YSCTextType textType;       //default YSCTextTypeProperty

@property (nonatomic, assign) IBInspectable NSInteger minLength;        //default 0
@property (nonatomic, assign) IBInspectable NSInteger maxLength;        //default 20, -1 means no limit
@property (nonatomic, strong) IBInspectable NSString *customRegex;      //default nil means no limit
@property (nonatomic, assign) IBInspectable BOOL allowsEmpty;           //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsEmoji;           //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsChinese;         //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsPunctuation;     //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsLetter;          //default YES
@property (nonatomic, assign) IBInspectable BOOL allowsNumber;          //default YES

- (NSString *)textString;   //返回去掉首位空格后的字符串
- (NSInteger)textLength;    //返回去掉首位空格后的字符串的长度
- (BOOL)isValid;            //检测输入内容是否有效

@end
