//
//  PlayAudioManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-8-29.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "PlayAudioManager.h"

@interface PlayAudioManager ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation PlayAudioManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (void)playWithAudioType:(AudioType)type repeatCount:(NSInteger)count {
    [self stopPlaying];
    NSString *soundFileName = [self soundFileNameWithType:type];
    NSString *filePath = AppProgramPath(soundFileName);
    
	if ([YSCFileUtils isExistsAtPath:filePath]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
		NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:filePath];
		self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
		[self.audioPlayer prepareToPlay];
		[self.audioPlayer setNumberOfLoops:count];
		[self.audioPlayer setDelegate:self];
		[self.audioPlayer play];
	}
}

- (void)playWithAudioFile:(NSString *)filePath {
    if ([YSCFileUtils isExistsAtPath:filePath]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
        NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:filePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer setNumberOfLoops:0];
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer play];
    }
}

- (void)stopPlaying {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

- (NSString *)soundFileNameWithType:(AudioType)type {
    NSString *fileName = nil;
	switch (type) {
		case AudioTypeStart:
			fileName = @"进入程序声音.aif";
			break;
            
		case AudioTypeMoreItem:
			fileName = @"详情功能选中item.aif";
			break;
            
		case AudioTypePanicSuccess:
			fileName = @"抢购成功.aif";
			break;
            
		case AudioTypeMore:
			fileName = @"详情功能按钮.aif";
			break;
            
		case AudioTypeMenuOpen:
			fileName = @"主页按钮打开.aif";
			break;
            
		case AudioTypeMenuClose:
			fileName = @"主页按钮收起.aif";
			break;
            
		case AudioTypeShare:
			fileName = @"分享按钮点击.aif";
			break;
            
		case AudioTypeHeartbeat:
			fileName = @"抢购心跳.mp3";
			break;
            
		case AudioTypePush:
			fileName = @"推送.mp3";
			break;
            
		case AudioTypeAddAlert:
			fileName = @"零元抢购添加闹铃.aif";
			break;
            
		default:
			break;
	}
	return fileName;
}

@end
