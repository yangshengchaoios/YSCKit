//
//  EZGMessageModel.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/6.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageModel.h"

@implementation EZGSceneMessage
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeScene;
}
@end

@implementation EZGCarMessage
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeCar;
}
@end

@implementation EZGServiceMessage
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeService;
}
@end

@implementation EZGServiceCancelMessage
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceCancel;
}
@end

@implementation EZGServiceCommentMessage
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceComment;
}
@end