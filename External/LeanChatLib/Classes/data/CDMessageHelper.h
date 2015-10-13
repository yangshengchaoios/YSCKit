//
//  CDMessageHelper.h
//  LeanChatLib
//
//  Created by lzw on 15/6/30.
//  Copyright (c) 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "AVIMConversation+Custom.h"

@interface CDMessageHelper : NSObject

+ (CDMessageHelper *)helper;

- (NSAttributedString *)attributedStringWithMessage:(AVIMTypedMessage *)message conversation:(AVIMConversation *)conversation;

@end
