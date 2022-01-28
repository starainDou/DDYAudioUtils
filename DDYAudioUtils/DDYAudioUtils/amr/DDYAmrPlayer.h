//
//  DDYConvertToAmr.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

// 使用AudioQueue来实现音频播放功能时最主要的步骤:
//
// 1. 打开播放音频文件
// 2. 取得或设置播放音频文件的数据格式
// 3. 建立播放用的队列
// 4. 将缓冲中的数据填充到队列中
// 5. 开始播放
// 6. 在回调函数中进行队列处理

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 3

@interface DDYAmrPlayer : NSObject
{
    // 播放音频文件ID
    AudioFileID audioFile;

    // 音频流描述对象
    AudioStreamBasicDescription dataFormat;

    // 音频队列
    AudioQueueRef queue;

    SInt64 packetIndex;

    UInt32 numPacketsToRead;

    UInt32 bufferByteSize;

    AudioStreamPacketDescription *packetDescs;

    AudioQueueBufferRef buffers[NUM_BUFFERS];
    int *_destate;
    int _hasReadSize;
    int _bufferFinishCounter;
    FILE *_amrFile;
    UInt32 mIsRunning;
    NSDate *playStartTime;
}

@property(readonly, getter = isPlaying) BOOL playing;
@property(readonly) NSTimeInterval currentTime;
@property(readwrite, copy) void (^onAudioPlayerDidFinishPlaying)(BOOL successfully);

- (id)initWithFileName:(NSString *)path;

- (BOOL)play;

- (void)stop;

- (void)pause;

/// 定义缓存数据读取方法
- (void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;

/// 定义回调（Callback）函数
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);
/// 定义包数据的读取方法
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

static void isRunningProc(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);

@end

//@protocol DDYAMRPlayerDelegate<NSObject>
//@optional
//-(void)amrPlayerDidFinishPlaying:(DDYAMRPlayer *) player;
//@end
