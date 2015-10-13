//
//  CDUserModel.h
//  LeanChatLib
//
//  Created by lzw on 15/4/3.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CDUserModel <NSObject>

@required

- (NSString *)userId;

- (NSString *)avatarUrl;

- (NSString *)username;

@end
