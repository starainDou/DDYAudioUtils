//
//  DDYAudioPlayer.m
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYAudioUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface DDYAudioUtils()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
/// 录音器
@property (nonatomic, strong) AVAudioRecorder *recorder;
/// 播放器
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, copy) DDYAudioResult result;

@end

@implementation DDYAudioUtils

+ (instancetype)shared {
    static DDYAudioUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DDYAudioUtils alloc] init];
    });
    return instance;
}

// MARK: - 录制
/// 录音设置
- (NSDictionary *)recordSetting {
    if (!_recordSetting) {
        _recordSetting = @{AVSampleRateKey:@(8000),
                           AVFormatIDKey:@(kAudioFormatLinearPCM),
                           AVLinearPCMBitDepthKey:@(16),
                           AVNumberOfChannelsKey:@(2),
                           AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMedium] };
    }
    return _recordSetting;
}

- (void)startRecordWith:(NSString *)path result:(DDYAudioResult)result {
    [self stopPlay];
    [self stopRecord];
    self.result = result;
    if (result) result(0);
    if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                mode:AVAudioSessionModeDefault
                                             options:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error: &error];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:self.recordSetting error: &error];
        if (error) {
            if (result) result(-1);
            return;
        }
        _recorder.meteringEnabled = YES;
        _recorder.delegate = self;
        if ([_recorder prepareToRecord]) {
            [_recorder record];
            if (result) result(1);
        } else {
            if (result) result(-1);
        }
    } else {
        if (result) result(-1);
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_result) _result(2);
}

/// 停止录音
- (void)stopRecord {
    if (_recorder && _recorder.isRecording) {
        [_recorder stop];
    }
}

/// 删除录音
- (void)deleteRecord {
    if (_recorder) {
        [self stopRecord];
        [_recorder deleteRecording];
    }
}

/// 获取录制分贝值
- (float)recordLevels {
    if (_recorder) {
        [_recorder updateMeters];
        float alpha = 0.02f;  // 音频振幅调解相对值 (越小振幅就越高)
        double aveChannel = pow(10, (alpha * [_recorder averagePowerForChannel:0]));
        if (aveChannel <= 0.05f) aveChannel = 0.05f;
        if (aveChannel >= 1.0f)  aveChannel = 1.0f;
        return aveChannel;
    } else {
        return 0;
    }
}

// MARK: - 播放
/// 播放本地音频
- (void)playWith:(NSString *)path result:(DDYAudioResult)result {
    [self stopPlay];
    [self stopRecord];
    self.result = result;
    if (result) result(0);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        _player.numberOfLoops = 0;
        _player.delegate = self;
        _player.meteringEnabled = YES;
        if ([_player prepareToPlay]) {
            [_player play];
            if (result) result(1);
        } else {
            if (result) result(-1);
        }
    } else {
        if (result) result(-1);
    }
}
/// 暂停播放
- (void)pausePlay {
    if (_player && _player.isPlaying) {
        [_player pause];
    }
}

/// 停止播放
- (void)stopPlay {
    if (_player) {
        [_player stop];
    }
}

/// 恢复播放
- (void)resumePlay {
    if(_player) {
        [_player play];
    }
}

/// 获取播放分贝值
- (float)playLevels {
    if (_player) {
        [_player updateMeters];
        float alpha = 0.02f;  // 音频振幅调解相对值 (越小振幅就越高)
        double aveChannel = pow(10, (alpha * [_player averagePowerForChannel:0]));
        if (aveChannel <= 0.05f) aveChannel = 0.05f;
        if (aveChannel >= 1.0f)  aveChannel = 1.0f;
        return aveChannel;
    } else {
        return 0;
    }
}

/// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (_result) _result(2);
}

+ (float)audioDuration:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = audioAsset.duration;
    return CMTimeGetSeconds(audioDuration);
}

+ (void)permission {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
    }];
}

@end
