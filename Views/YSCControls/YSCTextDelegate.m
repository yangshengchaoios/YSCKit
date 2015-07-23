//
//  YSCTextDelegate.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/23.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCTextDelegate.h"

@implementation YSCTextDelegate

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;//NOTE:主要是为了放开删除按钮
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(((YSCTextField *)textField).allowsKeyboardDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {
        //1. 判断是否表情键盘
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            return ((YSCTextField *)textView).allowsEmoji;
        }
        //2. 点击回车隐藏键盘
        if(((YSCTextField *)textView).allowsKeyboardDone && [text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

@end
