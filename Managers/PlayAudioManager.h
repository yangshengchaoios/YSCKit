//
//  PlayAudioManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayAudioManager : NSObject <AVAudioPlayerDelegate>

+ (instancetype)sharedInstance;

- (void)playWithAudioType:(AudioType)type repeatCount:(NSInteger)count;
- (void)playWithAudioFile:(NSString *)filePath;
- (void)stopPlaying;

@end
