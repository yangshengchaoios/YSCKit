//
//  AFSoundManager.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#import "AFAudioRouter.h"
typedef void (^progressBlock)(CGFloat totalTime, CGFloat elapsedTime, NSError *error);


@interface AFSoundManager : NSObject

+(instancetype)sharedManager;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, strong) NSMutableArray *audioArray;   //<PlayRecordModel>
@property (nonatomic, assign) NSInteger audioPlayIndex;     //当前播放的下标
@property (nonatomic, assign) CGFloat audioPlayProgress;    //当前播放的进度百分比
@property (nonatomic, assign) CGFloat audioTotalTime;       //音频总时长(s)
@property (nonatomic, assign) CGFloat audioElapsedTime;     //已经播放的时长(s)
@property (nonatomic, assign) BOOL isAudioPlaying;          //当前的音频是否正在播放

-(void)startPlayingLocalFileWithName:(NSString *)name andBlock:(progressBlock)block;
-(void)startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block;
-(void)startPlayingAudio:(NSArray *)audioArray withIndex:(NSInteger)audioIndex;

-(void)pause;
-(void)resume;
-(void)stop;
-(void)restart;

-(void)playNextAudio;
-(void)playPreviousAudio;

-(void)changeVolumeToValue:(CGFloat)volume;
-(void)changeSpeedToRate:(CGFloat)rate;
-(void)moveToSecond:(int)second;
-(void)moveToSection:(CGFloat)section;

-(void)startRecordingAudioWithFileName:(NSString *)name andExtension:(NSString *)extension shouldStopAtSecond:(NSTimeInterval)second;
-(void)pauseRecording;
-(void)resumeRecording;
-(void)stopAndSaveRecording;
-(void)deleteRecording;
-(NSInteger)timeRecorded;

-(BOOL)areHeadphonesConnected;
-(void)forceOutputToDefaultDevice;
-(void)forceOutputToBuiltInSpeakers;

@end


@interface NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end

@interface NSTimer (Control)

-(void)pauseTimer;
-(void)resumeTimer;

@end