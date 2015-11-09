//
//  XHMessageAvatorFactory.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-25.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XHMessageAvatorType) {
    XHMessageAvatorTypeNormal = 0,
    XHMessageAvatorTypeSquare,
    XHMessageAvatorTypeCircle
};

@interface XHMessageAvatorFactory : NSObject

+ (UIImage *)avatarImageNamed:(UIImage *)originImage
            messageAvatorType:(XHMessageAvatorType)type;

@end
