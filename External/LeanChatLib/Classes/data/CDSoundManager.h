//
//  CDSoundManager.h
//  LeanChatLib
//
//  Created by lzw on 15/7/2.
//  Copyright (c) 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDSoundManager : NSObject

+ (CDSoundManager *)manager;

@property (nonatomic, assign) BOOL needVibrateWhenNotChatting;
@property (nonatomic, assign) BOOL needPlaySoundWhenNotChatting;
@property (nonatomic, assign) BOOL needPlaySoundWhenChatting;

- (void)playSendSoundIfNeed;
- (void)playReceiveSoundIfNeed;
- (void)playLoudReceiveSoundIfNeed;

- (void)vibrateIfNeed;

@end
