//
//  EZGMessageModel.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/6.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageModel.h"

@implementation EZGSceneMessage
@dynamic sceneType;
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeScene;
}
@end

@implementation EZGCarMessage
@dynamic carInfo;
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeCar;
}
@end

@implementation EZGServiceMessage
@dynamic detailInfo;
@dynamic serviceType;
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeService;
}
@end

@implementation EZGServiceCancelMessage
@dynamic detailInfo;
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceCancel;
}
@end

@implementation EZGServiceCommentMessage
@dynamic rateScore;
+ (void)load {
    [self registerSubclass];
}
+ (AVIMMessageMediaType)classMediaType {
    return EZGMessageTypeServiceComment;
}
@end