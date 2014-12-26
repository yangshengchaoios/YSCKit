//
//  AFSoundManager.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFSoundManager.h"

@interface AFSoundManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int type;
@property (nonatomic) int status;

@end

@implementation AFSoundManager

+(instancetype)sharedManager {
    static AFSoundManager *soundManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundManager = [[self alloc]init];
    });
    
    return soundManager;
}

-(void)startPlayingLocalFileWithPath:(NSString *)filePath withBlock:(progressBlock)block {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self stop];
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    if (error == nil) {
        [_audioPlayer play];
        self.audioPlayStatus = AudioPlayStatusPlaying;
        
        WeakSelfType blockSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
            float totalTime = blockSelf.audioPlayer.duration;
            float elapsedTime = blockSelf.audioPlayer.currentTime;
            if (block) {
                block(totalTime, elapsedTime,nil);
            }
            
            //更新监控属性
            blockSelf.audioTotalTime = ceilf(totalTime);
            blockSelf.audioElapsedTime = ceilf(elapsedTime);
            if (blockSelf.audioTotalTime > 0) {
                blockSelf.audioPlayProgress = blockSelf.audioElapsedTime / blockSelf.audioTotalTime;
            }
            else {
                blockSelf.audioPlayProgress = 0;
            }
        } repeats:YES];
    }
    else {
        if (block) {
            block(0, 0,error);
        }
    }
}

//用来播放临时在线文件
-(void)startStreamingRemoteAudioFromURL:(NSString *)url withBlock:(progressBlock)block {
    NSURL *streamingURL = [NSURL URLWithString:url];
    [self stop];
    _player = [[AVPlayer alloc]initWithURL:streamingURL];
    [_player play];
    self.audioPlayStatus = AudioPlayStatusPlaying;
    
    WeakSelfType blockSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
        float totalTime = CMTimeGetSeconds(blockSelf.player.currentItem.duration);
        float elapsedTime = CMTimeGetSeconds(blockSelf.player.currentItem.currentTime);
        if (block) {
            block(totalTime, elapsedTime,nil);
        }
        
        //更新监控属性
        blockSelf.audioTotalTime = ceilf(totalTime);
        blockSelf.audioElapsedTime = ceilf(elapsedTime);
        if (blockSelf.audioTotalTime > 0 && blockSelf.audioElapsedTime > 0) {
            blockSelf.audioPlayProgress = blockSelf.audioElapsedTime / blockSelf.audioTotalTime;
        }
        else {
            blockSelf.audioPlayProgress = 0;
        }
    } repeats:YES];
}

-(void)startPlayingBook:(BookModel *)bookModel withIndex:(NSInteger)audioIndex {
    self.currentPlayingBook = bookModel;
    [self playAudioAtIndex:audioIndex];
}

-(void)playAudioAtIndex:(NSInteger)playIndex {
    if (playIndex >= 0 && playIndex < [self.currentPlayingBook.chapters count]) {
        self.audioPlayIndex = playIndex;
        ChapterModel *playRecord = self.currentPlayingBook.chapters[self.audioPlayIndex];
        if ([FileUtils isExistsAtPath:playRecord.audioLocalPath]) {//如果是本地文件
            [self startPlayingLocalFileWithPath:playRecord.audioLocalPath withBlock:nil];
        }
        else if ([NSString isUrl:playRecord.audioUrl]) {//如果是网络文件
            [self startStreamingRemoteAudioFromURL:playRecord.audioUrl withBlock:nil];
        }
        else {
//            [self playNextAudio];
        }
    }
}
-(ChapterModel *)currentPlayingChapter {
    if (self.audioPlayIndex >= 0 && self.audioPlayIndex < [self.currentPlayingBook.chapters count]) {
        return self.currentPlayingBook.chapters[self.audioPlayIndex];
    }
    else {
        return nil;
    }
}

- (void)setAudioPlayProgress:(CGFloat)audioPlayProgress {
    NSLog(@"afs play progress = %f", audioPlayProgress);
    _audioPlayProgress = audioPlayProgress;
    if (audioPlayProgress >= 1.0f) {
        [self stop];// OR [self playNextAudio]
        //TODO:保存结束信息
    }
    else if (audioPlayProgress == 0) {
        self.audioPlayStatus = AudioPlayStatusReadyToPlay;
        self.audioElapsedTime = 0;
    }
    else {
        self.audioPlayStatus = AudioPlayStatusPlaying;
    }
}

-(void)pause {
    [_audioPlayer pause];
    [_player pause];
    [_timer pauseTimer];
    self.audioPlayStatus = AudioPlayStatusPause;
    
    //TODO:保存暂停信息
}

-(void)resume {
    [_audioPlayer play];
    [_player play];
    [_timer resumeTimer];
    self.audioPlayStatus = AudioPlayStatusPlaying;
}

-(void)stop {
    [_audioPlayer stop];
    _player = nil;
    [_timer pauseTimer];
    
    self.audioPlayProgress = 0;
}

-(void)restart {
    [_audioPlayer setCurrentTime:0];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMake(0.000000, timeScale)];
    self.audioPlayStatus = AudioPlayStatusPlaying;
}
-(void)reset {
    [self stop];
    self.audioPlayIndex = -1;
    self.currentPlayingBook = nil;
}

-(void)playNextAudio {
    NSInteger newPlayIndex = self.audioPlayIndex + 1;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kParamIsPlayCycle]) {
        newPlayIndex = newPlayIndex % [self.currentPlayingBook.chapters count];
    }
    if (newPlayIndex < [self.currentPlayingBook.chapters count]) {
        [self playAudioAtIndex:newPlayIndex];
    }
}

-(void)playPreviousAudio {
    NSInteger newPlayIndex = self.audioPlayIndex - 1;
    if (newPlayIndex >= 0 && newPlayIndex < [self.currentPlayingBook.chapters count]) {
        [self playAudioAtIndex:newPlayIndex];
    }
}

-(void)moveToSecond:(int)second {
    [_audioPlayer setCurrentTime:second];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMakeWithSeconds((Float64)second, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)moveToSection:(CGFloat)section {
    int audioPlayerSection = _audioPlayer.duration * section;
    [_audioPlayer setCurrentTime:audioPlayerSection];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    Float64 playerSection = CMTimeGetSeconds(_player.currentItem.duration) * section;
    [_player seekToTime:CMTimeMakeWithSeconds(playerSection, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)changeSpeedToRate:(CGFloat)rate {
    _audioPlayer.rate = rate;
    _player.rate = rate;
}

-(void)changeVolumeToValue:(CGFloat)volume {
    _audioPlayer.volume = volume;
    _player.volume = volume;
}

-(void)startRecordingAudioWithFileName:(NSString *)name andExtension:(NSString *)extension shouldStopAtSecond:(NSTimeInterval)second {
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@", [NSHomeDirectory() stringByAppendingString:@"/Documents"], name, extension]] settings:nil error:nil];
    
    if (second == 0 && !second) {
        [_recorder record];
    } else {
        [_recorder recordForDuration:second];
    }
}

-(void)pauseRecording {
    
    if ([_recorder isRecording]) {
        [_recorder pause];
    }
}

-(void)resumeRecording {
    
    if (![_recorder isRecording]) {
        [_recorder record];
    }
}

-(void)stopAndSaveRecording {
    [_recorder stop];
}

-(void)deleteRecording {
    [_recorder deleteRecording];
}

-(NSInteger)timeRecorded {
    return [_recorder currentTime];
}

-(BOOL)areHeadphonesConnected {
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
    BOOL headphonesLocated = NO;
    for (AVAudioSessionPortDescription *portDescription in route.outputs) {
        headphonesLocated |= ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]);
    }
    return headphonesLocated;
}

-(void)forceOutputToDefaultDevice {
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter switchToDefaultHardware];
}

-(void)forceOutputToBuiltInSpeakers {
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter forceOutputToBuiltInSpeakers];
}

@end

@implementation NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    void (^block)() = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    void (^block)() = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(void)executeSimpleBlock:(NSTimer *)inTimer {
    if ([inTimer userInfo]) {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}

@end

@implementation NSTimer (Control)

static NSString *const NSTimerPauseDate = @"NSTimerPauseDate";
static NSString *const NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

-(void)pauseTimer {
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPreviousFireDate), self.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.fireDate = [NSDate distantFuture];
}

-(void)resumeTimer {
    NSDate *pauseDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPreviousFireDate);
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    self.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
}

@end
