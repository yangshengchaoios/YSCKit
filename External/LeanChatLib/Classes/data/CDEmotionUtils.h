//
//  CDEmotionUtils.h
//  LeanChat
//
//  Created by lzw on 14/11/25.
//  Copyright (c) 2014年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDEmotionUtils : NSObject

+ (NSArray *)emotionManagers;

+ (NSString *)emojiStringFromString:(NSString *)text;

+ (NSString *)plainStringFromEmojiString:(NSString *)emojiText;

@end
