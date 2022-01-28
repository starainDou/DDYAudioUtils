//
//  DDYConvertToAmr.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYAmrPlayer.h"
#include "interf_dec.h"

const unsigned int PACKETNUM = 25; // 20ms * 25 = 0.5s, 每个包25帧,可以播放0.5秒
const float KSECONDSPERBUFFER = 0.2; // 每秒播放0.2个缓冲
const unsigned int AMRFRAMELEN = 32; // 帧长
const unsigned int PERREADFRAME = 10; // 每次读取帧数
static unsigned int gBufferSizeBytes = 0x10000;

@implementation DDYAmrPlayer

@synthesize playing;
@synthesize currentTime;
@synthesize onAudioPlayerDidFinishPlaying;

/// 回调（Callback）函数的实现
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    DDYAmrPlayer *player = (__bridge DDYAmrPlayer *) inUserData;
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

static void isRunningProc(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    id obj = (__bridge DDYAmrPlayer *) inUserData;
    if (![obj isKindOfClass:[DDYAmrPlayer class]]) {
        return;
    }
    DDYAmrPlayer *player = (DDYAmrPlayer *) obj;
    UInt32 size = sizeof(player->mIsRunning);
    OSStatus result = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &player->mIsRunning, &size);

    if ((result == noErr) && (!player->mIsRunning)) {
        if (player.onAudioPlayerDidFinishPlaying) {
            player.onAudioPlayerDidFinishPlaying((player->_bufferFinishCounter > 0)?YES:NO);
        }        //[player stop];
        //[[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
    }
}


// 初始化方法（为NSObject中定义的初始化方法）
- (id)init {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped) name:@"playbackQueueStopped" object:nil];
    if (self = [super init]) {
        _destate = Decoder_Interface_init();
        mIsRunning = NO;
        playing = NO;
    }
    return self;
}

- (id)initWithFileName:(NSString *)fileName {
    if (self = [self init]) {
        [self initFile:fileName];
    }
    return self;
}

- (void)initFile:(NSString *)amrFileName {

#ifdef IF2
    // short block_size[16]={ 12, 13, 15, 17, 18, 20, 25, 30, 5, 0, 0, 0, 0, 0, 0, 0 };
#else
    char magic[8];
    // short block_size[16]={ 12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0 };
#endif
    _hasReadSize = 0;

    _amrFile = fopen([amrFileName UTF8String], "rb");

    int rCout = fread(magic, sizeof( char ), strlen("#!AMR\n"), _amrFile);
    _hasReadSize = rCout;
    if (strncmp(magic, "#!AMR\n", strlen("#!AMR\n"))) {

        fclose(_amrFile);
    }
}

/// 缓存数据读取方法的实现
- (void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue queueBuffer:(AudioQueueBufferRef)audioQueueBuffer {
    
    short pcmBuf[1600] = {0}; // KSECONDSPERBUFFER * 160 * 50;

    int readAMRFrame = 0;
    const short block_size[16] = {12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0};
    char analysis[32] = {0};
    int rCout = 0;

    while (playing != NO && readAMRFrame < PERREADFRAME && (rCout = fread(analysis, sizeof (unsigned char), 1, _amrFile))) {
        int dec_mode = (analysis[0] >> 3) & 0x000F;

        int read_size = block_size[dec_mode];
        _hasReadSize += rCout;
        rCout = fread(&analysis[1], sizeof (char), read_size, _amrFile);

        _hasReadSize += rCout;
        Decoder_Interface_Decode(_destate, (unsigned char *) analysis, &pcmBuf[readAMRFrame * 160], 0);
        readAMRFrame++;
    }
    // DDYLogVerbose(@"currentTime:%f",self.currentTime);

    if (readAMRFrame > 0) {
        audioQueueBuffer ->mAudioDataByteSize = readAMRFrame * 2 * 160;
        audioQueueBuffer ->mPacketDescriptionCount = readAMRFrame * 160;
        memcpy(audioQueueBuffer ->mAudioData, pcmBuf, readAMRFrame * 160 * 2);
        AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, 0, NULL);
    } else {
        // DDYLogVerbose(@"readCount:%d  readAMRFrame:%d", _hasReadSize, readAMRFrame);
        if (playing != NO && _hasReadSize > 1286) {
            _bufferFinishCounter++;
            if (_bufferFinishCounter >= NUM_BUFFERS) {
                [self stopQueue];
            }
        }
    }
}


//音频播放方法的实现

- (BOOL)play {
    _bufferFinishCounter = 0;

    if (playStartTime) {
        playStartTime = nil;
    }
    playStartTime = [NSDate date];

    // 设置音频数据格式
    memset(&dataFormat, 0, sizeof(dataFormat));
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mSampleRate = 8000.0;
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mFramesPerPacket = 1;

    dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel / 8) * dataFormat.mChannelsPerFrame;
    dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame;
    // 创建播放用的音频队列(nil:audio队列的间隙线程)
    AudioQueueNewOutput(&dataFormat, BufferCallback, (__bridge void *)self, nil, nil, 0, &queue);

    // 创建并分配缓存空间
    packetIndex = 0;
    gBufferSizeBytes = KSECONDSPERBUFFER * 2 * 160 * 50 * 2; //MR122 size * 2

    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);// &mBuffers[i]
    }
    
    // 设置监听
    AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, isRunningProc, (__bridge void*)self),
    // 设置音量
    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, 1.0);
    return [self startQueue] == noErr;
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer {
    
    short pcmBuf[1600] = {0};; // KSECONDSPERBUFFER * 160 * 50

    int readAMRFrame = 0;
    const short block_size[16] = {12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0};
    char analysis[32] = {0};

    int rCout = 0;
    while (playing != NO && readAMRFrame < PERREADFRAME && (rCout = fread(analysis, sizeof (unsigned char), 1, _amrFile))) {
        _hasReadSize += rCout;

        int dec_mode = (analysis[0] >> 3) & 0x000F;

        int read_size = block_size[dec_mode];
        rCout = fread(&analysis[1], sizeof (char), read_size, _amrFile);

        _hasReadSize += rCout;

        Decoder_Interface_Decode(_destate, (unsigned char *) analysis, &pcmBuf[readAMRFrame * 160], 0);
        readAMRFrame++;
    }

    if (readAMRFrame > 0) {
        buffer ->mAudioDataByteSize = readAMRFrame * 2 * 160;
        buffer ->mPacketDescriptionCount = readAMRFrame * 160;
        memcpy(buffer ->mAudioData, pcmBuf, readAMRFrame * 160 * 2);
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }

    return readAMRFrame;
}

- (void)dealloc {
    if (playStartTime) {
        playStartTime = nil;
    }
    //取消监听
    AudioQueueRemovePropertyListener(queue, kAudioQueueProperty_IsRunning, isRunningProc, (__bridge void *)self);
    AudioQueueDispose(queue, TRUE);
    
    Decoder_Interface_exit(_destate);
    if (_amrFile) {
        fclose(_amrFile);
    }
    onAudioPlayerDidFinishPlaying = nil;
}

- (void)stop {
    [self stopQueue];
}

- (void)pause {
    [self pauseQueue];
}

- (OSStatus)startQueue {
    playing = YES;
    // prime the queue with some data before starting
    for (int i = 0; i < NUM_BUFFERS; ++i) {
        //读取包数据
        if ([self readPacketsIntoBuffer:buffers[i]] == 0) {
            break;
        }
    }
    return AudioQueueStart(queue, NULL);
}

- (OSStatus)stopQueue {
    playing = NO;
    if (playStartTime) {
        playStartTime = nil;
    }

    OSStatus result = AudioQueueStop(queue, TRUE);
    if (result)
        printf("ERROR STOPPING QUEUE!\n");
    return result;
}

- (OSStatus)pauseQueue {
    playing = NO;
    OSStatus result = AudioQueuePause(queue);
    return result;
}

- (NSTimeInterval)currentTime {
    if (playStartTime != nil) {
        return [[NSDate date] timeIntervalSinceDate:playStartTime];
    } else {
        return 0;
    }
}
@end
