//
//  YSCTextField.h
//  YSCKit
//
//  Created by Builder on 16/6/29.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSCTextType) {
    //特殊内容
    YSCTextTypePhone            = 10,   //电话号码(包括座机、手机号)
    YSCTextTypeMobilePhone      = 11,   //手机号
    YSCTextTypeIdentityNum      = 12,   //身份证号码
    YSCTextTypeEmail            = 13,   //email地址
    YSCTextTypeUrl              = 14,   //超链接
    YSCTextTypeDecimal          = 15,   //带小数点的数字
    
    //自定义
    YSCTextTypeProperty         = 99,   //完全根据property的设置来校验
};

@interface YSCTextField : UITextField

@property (nonatomic, assign) YSCTextType textType;                     //default YSCTextTypeProperty
//控制内容
@property (nonatomic, assign) IBInspectable NSInteger minLength;        //default 0 means no limit
@property (nonatomic, assign) IBInspectable NSInteger maxLength;        //default 20, -1 means no limit
@property (nonatomic, strong) IBInspectable NSString *customRegex;      //default nil
@property (nonatomic, strong) IBInspectable NSString *chineseRegex;     //default nil 汉字正则表达式
@property (nonatomic, strong) IBInspectable NSString *punctuationRegex; //default nil 标点符号正则表达式
@property (nonatomic, strong) IBInspectable NSString *emojiRegex;       //default nil emoji正则表达式
@property (nonatomic, assign) IBInspectable BOOL allowsEmpty;           //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsEmoji;           //default NO 所有的emoji
@property (nonatomic, assign) IBInspectable BOOL allowsChinese;         //default NO
@property (nonatomic, assign) IBInspectable BOOL allowsPunctuation;     //default NO 标点符号(全)
@property (nonatomic, assign) IBInspectable BOOL allowsKeyboardDismiss; //default YES 点击done 键盘是否隐藏
@property (nonatomic, assign) IBInspectable BOOL allowsLetter;          //default YES
@property (nonatomic, assign) IBInspectable BOOL allowsNumber;          //default YES
@property (nonatomic, assign) IBInspectable BOOL stringLengthType;      //YES-string.length NO-char length default YES
//控制UI样式
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;       //圆角弧度
@property (nonatomic, strong) IBInspectable UIColor *borderColor;       //边框颜色
@property (nonatomic, strong) IBInspectable UIColor *placeholderColor;  //默认字体颜色
@property (nonatomic, assign) IBInspectable CGFloat textHorMargin;      //文字水平方向的间隙
@property (nonatomic, assign) IBInspectable CGFloat textVerMargin;      //文字垂直方向的间隙

//blocks
@property (nonatomic, copy) void (^beginEditingBlock)(NSString *text);
@property (nonatomic, copy) void (^didChangedBlock)(NSString *text);
@property (nonatomic, copy) void (^keyboardReturnBlock)(NSString *text);

/** 最终检测输入内容是否有效 */
- (BOOL)isValid;
/** 返回去掉首位空格后的字符串 */
- (NSString *)textString;
/** 返回去掉首位空格后的字符串的长度 */
- (NSInteger)textLength;
/** 处理self.text的变化是否需要触发通知 */
- (void)setText:(NSString *)text notify:(BOOL)isNotify;
@end
