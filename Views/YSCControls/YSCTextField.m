//
//  YSCTextField.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCTextField.h"

#define isEmpty(object) (object == nil \
|| [object isKindOfClass:[NSNull class]] \
|| ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0) \
|| ([object respondsToSelector:@selector(count)]  && [(NSArray *)object count] == 0))

@implementation YSCTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextField];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTextField];
    }
    return self;
}

//初始化配置参数
- (void)setupTextField {
    //设置参数默认值
    self.textType = YSCTextTypeProperty;
    self.minLength = 0;
    self.maxLength = 20;
    self.allowsEmpty = NO;
    self.allowsEmoji = NO;
    self.allowsChinese = NO;
    self.allowsPunctuation = NO;
    self.allowsLetter = YES;
    self.allowsNumber = YES;
    
    //TODO:定义弹出键盘类型
}

//返回去掉首位空格后的字符串
- (NSString *)textString {
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
//返回去掉首位空格后的字符串的长度
- (NSInteger)textLength {
    return [[self textString] length];
}
//检测输入内容是否有效
- (BOOL)isValid {
    //0. 暂存输入的字符串
    NSString *tempString = [self textString];
    
    //1. 根据property设置来校验
    if (YSCTextTypeProperty == self.textType) {
        //1.1 判空
        if ([tempString length] == 0) {
            return self.allowsEmpty;
        }
        //1.2 判断长度(只有当maxLength > minLength时才有效)
        if (self.maxLength > self.minLength) {
            if (self.textLength < self.minLength) {
                return NO;
            }
            if (self.maxLength > 0 && self.textLength > self.maxLength) {
                return NO;
            }
        }
        //1.3 判断emoji
        if (NO == self.allowsEmoji) {
            //TODO:
        }
        if (NO == self.allowsChinese) {
            return ( ! [self checkString:tempString isMatchRegex:@"^[\u4E00-\u9FA5]+$"]);
        }
        if (NO == self.allowsPunctuation) {
            return ( ! [self checkString:tempString isMatchRegex:@"^[]$"]);//TODO:
        }
        if (NO == self.allowsLetter) {
            return ( ! [self checkString:tempString isMatchRegex:@"^[a-zA-Z]$"]);
        }
        if (NO == self.allowsNumber) {
            return ( ! [self checkString:tempString isMatchRegex:@"^[0-9]$"]);
        }
    }
    //2. 根据自定义正则表达式来校验
    else if (YSCTextTypeCustom == self.textType) {
        return [self checkString:tempString isMatchRegex:self.customRegex];
    }
    //3. 根据内置正则表达式来校验
    else {
//        #define RegexSimpleChinese  @"^[\u4E00-\u9FA5]+"  //匹配汉字
        if (YSCTextTypePhone == self.textType) {
            return [self checkString:tempString isMatchRegex:@"^\\d{3,15}$"];
        }
        else if (YSCTextTypeMobilePhone == self.textType) {
            return [self checkString:tempString isMatchRegex:@"^(01|1)\\d{10}$"];
        }
        else if (YSCTextTypeIdentityNum == self.textType) {
            return [NSString verifyIDCardNumber:tempString];//NOTE:严格校验身份证号
        }
        else if (YSCTextTypeEmail == self.textType) {
            return [self checkString:tempString isMatchRegex:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"];
        }
        else if (YSCTextTypeCarNumber == self.textType) {
            return [self checkString:tempString isMatchRegex:@"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z0-9]{0,5}[0-9]{1,5}[A-Z0-9]{0,5}$"];
        }
        else if (YSCTextTypeVehicleNumber == self.textType) {
            return [self checkString:tempString isMatchRegex:@"^[a-zA-Z0-9]{6}+$"];
        }
        else if (YSCTextTypeUrl == self.textType) {
            return [self checkString:tempString isMatchRegex:@"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"];
        }
    }

    return YES;
}
//判断内容是否符合正则表达式
- (BOOL)checkString:(NSString *)string isMatchRegex:(NSString *)regex {
    if (isEmpty(string)) {
        return NO;
    }
    if (isEmpty(string)) {
        return NO;
    }
    
    //方法一：缺点是无法兼容大小写的情况
    //	NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    //	return [identityCardPredicate evaluateWithObject:self];
    
    //方法二：
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
    if (error) {
        return NO;
    }
    
    return ([expression numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0);
}

@end
