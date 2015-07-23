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

//.              匹配除换行符以外的任意字符
//\d             与[0-9]相同
//\D             与[^0-9]相同
//\w             与[A-Za-z0-9\u4E00-\u9FA5_]相同
//\W             与[^A-Za-z0-9\u4E00-\u9FA5_]相同
//\s             匹配任何空白字符，与[ \n\t\r\v\f]相同
//\S             与[^ \n\t\r\v\f]相同
//\| \. \\ \* \^ \$ \+ \? \[ \] \- \( \) \{ \}    取消字符的特殊含义，按字面匹配
typedef NS_ENUM(NSInteger, YSCTextType) {
    //特殊内容
    YSCTextTypePhone            = 10,   //电话号码(包括座机、手机号)
    YSCTextTypeMobilePhone      = 11,   //手机号
    YSCTextTypeIdentityNum      = 12,   //身份证号码
    YSCTextTypeEmail            = 13,   //email地址
    YSCTextTypeCarNumber        = 14,   //车牌号至少一位数字
    YSCTextTypeVehicleNumber    = 15,   //车架号后6位
    YSCTextTypeUrl              = 16,   //超链接
    
    //自定义
    YSCTextTypeProperty         = 99,   //完全根据property的设置来校验
};


//三个难点：
//1. 校验不通过有文字提示
//2. err - >ok 必须延迟校验；ok -> err 可以实时校验
//3. 智能化设置键盘类型
@interface YSCTextField : UITextField

@property (nonatomic, assign) IBInspectable YSCTextType textType;       //default YSCTextTypeProperty

@property (nonatomic, assign) IBInspectable NSInteger maxLength;        //default 20, -1 means no limit
@property (nonatomic, strong) IBInspectable NSString *customRegex;      //default nil
@property (nonatomic, assign) IBInspectable BOOL allowsEmoji;           //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsPunctuation;     //default NO 标点符号
@property (nonatomic, assign) IBInspectable BOOL allowsEmpty;           //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsChinese;         //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsKeyboardDone;    //default YES 是否响应键盘的done按钮
@property (nonatomic, assign) IBInspectable BOOL allowsLetter;          //default YES
@property (nonatomic, assign) IBInspectable BOOL allowsNumber;          //default YES

@property (nonatomic, strong) NSString *errorString;//校验出错的提示语

- (BOOL)isValid;            //检测输入内容是否有效
- (NSString *)textString;   //返回去掉首位空格后的字符串
- (NSInteger)textLength;    //返回去掉首位空格后的字符串的长度
- (void)filterText:(NSString *)text;//TODO:输入text的时候过滤非法内容

@end
