//
//  DDYAudioMeterObserver.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class DDYAudioMeterObserver;

typedef void (^DDYAudioMeterObserverActionBlock)(NSArray *levelMeterStates, DDYAudioMeterObserver *meterObserver);
typedef void (^DDYAudioMeterObserverErrorBlock)(NSError *error, DDYAudioMeterObserver *meterObserver);

/// 错误标识
typedef NS_OPTIONS(NSUInteger, DDYAudioMeterObserverErrorCode) {
    /// 关于音频输入队列的错误
    DDYAudioMeterObserverErrorCodeAboutQueue,
};



@interface LevelMeterState : NSObject

@property (nonatomic, assign) Float32 mAveragePower;
@property (nonatomic, assign) Float32 mPeakPower;

@end

@interface DDYAudioMeterObserver : NSObject
{
    AudioQueueRef _audioQueue;
	AudioQueueLevelMeterState *_levelMeterStates;
}

@property AudioQueueRef audioQueue;

@property (nonatomic, copy) DDYAudioMeterObserverActionBlock actionBlock;

@property (nonatomic, copy) DDYAudioMeterObserverErrorBlock errorBlock;
/// 刷新间隔，默认0.1
@property (nonatomic, assign) NSTimeInterval refreshInterval;

/// 根据meterStates计算出音量，音量为 0-1
+ (Float32)volumeForLevelMeterStates:(NSArray*)levelMeterStates;

@end
