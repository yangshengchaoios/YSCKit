//
//  YSCTextField.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCTextField.h"
#import "YSCTextDelegate.h"

@interface YSCTextField () <UITextFieldDelegate>
@property (nonatomic, copy) NSString *oldString;
@end

@implementation YSCTextField

- (void)dealloc {
    self.delegate = nil;
    removeAllObservers(self);
}
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
    self.maxLength = 20;
    self.allowsEmpty = NO;
    self.allowsEmoji = NO;
    self.allowsChinese = NO;
    self.allowsPunctuation = NO;
    self.allowsKeyboardDone = YES;
    self.allowsLetter = YES;
    self.allowsNumber = YES;
    self.delegate = [YSCTextDelegate sharedInstance];
    self.oldString = @"";
    addNObserverWithObj(@selector(textFieldChanged:), UITextFieldTextDidChangeNotification, self);
}

//当输入框内容改变时触发
//NOTE:彻底解决中文输入高亮超过限制会crash的问题！
- (void)textFieldChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (textField != self) {
        return;
    }
    
    NSString *inputMode = [self.textInputMode primaryLanguage];
    if (nil == inputMode) {//ios8 默认会返回nil bug???
        inputMode = [[UITextInputMode currentInputMode] primaryLanguage];
    }
    if ([@"zh-Hans" isEqualToString:inputMode]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];//获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if ( ! position) {
            if ([self isValidByProperty]) {
                self.oldString = self.textString;
            }
            else {
                textField.text = self.oldString;
            }
        }
        else {
            //NOTE: 有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }
    if ([@"emoji" isEqualToString:inputMode]) {//针对emoji键盘控制是否可以输入
        if (NO == self.allowsEmoji) {
            self.text = self.oldString;
        }
    }
    else {// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if ([self isValidByProperty]) {
            self.oldString = self.textString;
        }
        else {
            textField.text = self.oldString;
        }
    }
}

//只检测配置属性 ok -> err
- (BOOL)isValidByProperty {
    if (self.textLength > self.maxLength) {
        return NO;
    }
    //NOTE:这种方法没有找到一个完整的库，只有在delegate中通过回调检查键盘类型是否emoji
//    //1.2 判断emoji
//    if (NO == self.allowsEmoji && NO) {//TODO:如果不允许有emoji而且又输入的话就返回NO
//        return NO;
//    }
    NSString *tempString = [self textString];
    NSMutableString *tempRegex = [NSMutableString stringWithString:@"^["];
    //TODO:标点符号判断
    if (self.allowsPunctuation) {//iphone上能输入的标点符号
//        [tempRegex appendString:@"@&%\\?,=\\[\\]_:-\\+\\./\\*$#!'^~;\\(\\)"];//en
        [tempRegex appendString:@"\u3000-\u301e\ufe10-\ufe19\ufe30-\ufe44\ufe50-\ufe6b\uff01-\uffee"];//cn
    }
    if (self.allowsChinese) {
        [tempRegex appendString:@"\u4E00-\u9FA5"];
    }
    if (self.allowsLetter) {
        [tempRegex appendString:@"a-zA-Z"];
    }
    if (self.allowsNumber) {
        [tempRegex appendString:@"0-9"];
    }
    [tempRegex appendString:@"]+$"];
    NSLog(@"string=%@,regex=%@", tempString,tempRegex);
    return [self checkString:tempString isMatchRegex:tempRegex];
}

//检测输入内容是否有效 ok <-> err
- (BOOL)isValid {
    //0. 暂存输入的字符串
    NSString *tempString = [self textString];
    
    //1. 根据property设置来校验
    if (YSCTextTypeProperty == self.textType) {
        //1.0 根据自定义的正则表达式来校验
        if (NO == isEmpty(self.customRegex)) {
            return [self checkString:tempString isMatchRegex:self.customRegex];
        }
        //1.1 判空
        if (isEmpty(tempString)) {
            return self.allowsEmpty;
        }
        //1.3 根据property属性校验
        return [self isValidByProperty];
    }
    //3. 根据内置正则表达式来校验
    else {
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
            return [self checkString:tempString isMatchRegex:@"^[a-zA-Z0-9]{6}$"];
        }
        else if (YSCTextTypeUrl == self.textType) {
            return [self checkString:tempString isMatchRegex:@"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"];
        }
    }

    return YES;
}

//TODO:定义弹出键盘类型
- (void)setTextType:(YSCTextType)textType {
    _textType = textType;
    //    self.keyboardType = UIKeyboardTypeASCIICapable;
    //    if (YSCTextTypePhone == textType || YSCTextTypeMobilePhone == textType) {
    //        self.keyboardType = UIKeyboardTypeNumberPad;
    //    }
    //    else if (YSCTextTypeIdentityNum == textType) {
    //        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //    }
    //    else {
    //        
    //    }
}
//返回去掉首位空格后的字符串
- (NSString *)textString {
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
//返回去掉首位空格后的字符串的长度
- (NSInteger)textLength {
    return [[self textString] length];
}
//输入text的时候过滤非法内容
- (void)filterText:(NSString *)text {
    //TODO:
}
//判断内容是否符合正则表达式
- (BOOL)checkString:(NSString *)string isMatchRegex:(NSString *)regex {
    if (isEmpty(string)) {
        return NO;
    }
    if (isEmpty(regex)) {
        return NO;
    }
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                options:NSRegularExpressionAnchorsMatchLines
                                                                                  error:&error];
    if (error) {
        return NO;
    }
    return ([expression numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0);
}

@end
