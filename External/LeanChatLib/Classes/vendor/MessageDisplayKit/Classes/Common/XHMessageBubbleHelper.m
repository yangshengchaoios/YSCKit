//
//  XHMessageBubbleHelper.m
//  MessageDisplayExample
//
//  Created by 曾 宪华 on 14-6-2.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageBubbleHelper.h"

@interface XHMessageBubbleHelper () {
    NSCache *_attributedStringCache;
}

@end

@implementation XHMessageBubbleHelper

+ (instancetype)sharedMessageBubbleHelper {
    static XHMessageBubbleHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XHMessageBubbleHelper alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _attributedStringCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)setDataDetectorsAttributedAttributedString:(NSMutableAttributedString *)attributedString
                                            atText:(NSString *)text
                             withRegularExpression:(NSRegularExpression *)expression
                                        attributes:(NSDictionary *)attributesDict {
    [expression enumerateMatchesInString:text
                                 options:0
                                   range:NSMakeRange(0, [text length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  NSRange matchRange = [result range];
                                  if (attributesDict) {
                                      [attributedString addAttributes:attributesDict range:matchRange];
                                  }
                                  if ([result resultType] == NSTextCheckingTypeLink) {
                                      NSURL *url = [result URL];
                                      [attributedString addAttribute:NSLinkAttributeName value:url range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypePhoneNumber) {
                                      NSString *phoneNumber = [result phoneNumber];
                                      [attributedString addAttribute:NSLinkAttributeName value:phoneNumber range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypeDate) {
//                                      NSDate *date = [result date];
                                  }
                              }];
}

- (NSAttributedString *)bubbleAttributtedStringWithText:(NSString *)text {
    if (!text) {
        return [[NSAttributedString alloc] init];
    }
    if ([_attributedStringCache objectForKey:text]) {
        return [_attributedStringCache objectForKey:text];
    }
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.185 green:0.583 blue:1.000 alpha:1.000]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSDataDetector *detector = nil;//[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate error:nil];//取消内容检测，TODO:测试该类的用法！
    [self setDataDetectorsAttributedAttributedString:attributedString atText:text withRegularExpression:detector attributes:textAttributes];
    [_attributedStringCache setObject:attributedString forKey:text];
    return attributedString;
}

@end
