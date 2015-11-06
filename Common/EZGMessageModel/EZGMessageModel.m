//
//  EZGMessageModel.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/6.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageModel.h"

@implementation EZGSceneMessage
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeScene;
}
@end

@implementation EZGCarMessage
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeCar;
}
@end

@implementation EZGServiceMessage
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeService;
}
@end

@implementation EZGServiceCancelMessage
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceCancel;
}
@end

@implementation EZGServiceCommentMessage
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceComment;
}
@end