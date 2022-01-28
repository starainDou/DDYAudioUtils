//
//  DDYAudioMeterObserver.m
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYAudioMeterObserver.h"

#define kDefaultRefreshInterval 0.1 // 默认0.1秒刷新一次
#define kTCAudioMeterObserverErrorDomain @"DDYAudioMeterObserverErrorDomain"

#define IfAudioQueueErrorPostAndReturn(operation,error) \
if(operation!=noErr) { \
[self postAErrorWithErrorCode:DDYAudioMeterObserverErrorCodeAboutQueue andDescription:error]; \
return; \
}   \

@implementation LevelMeterState
@end

@interface DDYAudioMeterObserver()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger channelCount;

@end


@implementation DDYAudioMeterObserver

- (instancetype)init {
    if (self = [super init]) {
        _refreshInterval = kDefaultRefreshInterval;
        _channelCount = 1;
        _levelMeterStates = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * self.channelCount);
    }
    return self;
}

#pragma mark - setter and getter
- (void)setRefreshInterval:(NSTimeInterval)refreshInterval {
    [self.timer invalidate]; // 重置timer
    if (refreshInterval >= 0) {
        _refreshInterval = refreshInterval;
        [self startRefreshTimer];
    }
}

- (void)startRefreshTimer {
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refresh];
    }];
}

- (void)stopTimer {
    if (_timer != nil && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (AudioQueueRef)audioQueue {
	return _audioQueue;
}

- (void)setAudioQueue:(AudioQueueRef)audioQueue {
    [self stopTimer];
    if (audioQueue == NULL || audioQueue == _audioQueue) return;
    _audioQueue = audioQueue;
    
    // 检测这玩意是否支持光谱图
    UInt32 val = 1;
    IfAudioQueueErrorPostAndReturn(AudioQueueSetProperty(audioQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), @"couldn't enable metering");
    if (!val) return; // 不支持光谱图
    
    AudioStreamBasicDescription queueFormat;
    UInt32 data_sz = sizeof(queueFormat);
    IfAudioQueueErrorPostAndReturn(AudioQueueGetProperty(audioQueue, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz), @"couldn't get stream description");
    
    self.channelCount = queueFormat.mChannelsPerFrame;
    // 重新初始化大小
    _levelMeterStates = (AudioQueueLevelMeterState*)realloc(_levelMeterStates, self.channelCount * sizeof(AudioQueueLevelMeterState));
    // 重新设置timer
    [self startRefreshTimer];
}

- (void)refresh {
    UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * self.channelCount;

    IfAudioQueueErrorPostAndReturn(AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_CurrentLevelMeterDB, _levelMeterStates, &data_sz),@"获取meter数据失败");
    
    // 转化成LevelMeterState数组传递到block
    NSMutableArray *meters = [NSMutableArray arrayWithCapacity: self.channelCount];
    
    for (int i = 0; i < self.channelCount; i++) {
        LevelMeterState *state = [[LevelMeterState alloc] init];
        state.mAveragePower = _levelMeterStates[i].mAveragePower;
        state.mPeakPower = _levelMeterStates[i].mPeakPower;
        [meters addObject:state];
    }
    if (self.actionBlock) {
        self.actionBlock(meters, self);
    }
}

/// 监控音频队列光谱发生错误
- (void)postAErrorWithErrorCode:(DDYAudioMeterObserverErrorCode)code andDescription:(NSString *)description {
    self.audioQueue = nil;
    NSError *error = [NSError errorWithDomain:kTCAudioMeterObserverErrorDomain code:code userInfo: @{NSLocalizedDescriptionKey: description}];
    if (self.errorBlock) {
        self.errorBlock(error,self);
    }
}

+ (Float32)volumeForLevelMeterStates:(NSArray *)levelMeterStates {
    Float32 averagePowerOfChannels = 0;
    for (int i = 0; i < levelMeterStates.count; i++) {
        averagePowerOfChannels+=((LevelMeterState*)levelMeterStates[i]).mAveragePower;
    }
    return pow(10, (0.05 * averagePowerOfChannels/levelMeterStates.count)); // 获取音量百分比
}

- (void)dealloc {
    [self stopTimer];
    free(_levelMeterStates);
    NSLog(@"DDYAudioMeterObserver dealloc");
}

@end
