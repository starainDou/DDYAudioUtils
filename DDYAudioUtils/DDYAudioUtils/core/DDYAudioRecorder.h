//
//  DDYAudioRecorder.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

/// 使用audioqueque来实时录音，边录音边转码，可以设置自己的转码方式。从PCM数据转

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/// 录音停止事件的block回调，作用参考DDYAudioRecorderDelegate的recordStopped和recordError:
typedef void (^DDYAudioRecorderReceiveStoppedBlock)(void);
typedef void (^DDYAudioRecorderReceiveErrorBlock)(NSError *error);

/// 错误标识
typedef NS_OPTIONS(NSUInteger, DDYAudioRecorderErrorCode) {
    /// 关于文件操作的错误
    DDYAudioRecorderErrorCodeAboutFile = 0,
    /// 关于音频输入队列的错误
    DDYAudioRecorderErrorCodeAboutQueue,
    /// 关于audio session的错误
    DDYAudioRecorderErrorCodeAboutSession,
    /// 关于其他的错误
    DDYAudioRecorderErrorCodeAboutOther,
};

@class DDYAudioRecorder;

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 *  当然如果是实时语音的需求的话，就可以在此处理编码后发送语音数据到对方
 *  PS:这里的三个方法是在后台线程中处理的
 */
@protocol DDYFileWriterForAudioRecorder <NSObject>

@optional
- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile;

@required
/// 在录音开始时候建立文件和写入文件头信息等操作
- (BOOL)createFileWithRecorder:(DDYAudioRecorder*)recoder;

/// 写入音频输入数据，内部处理转码等其他逻辑
- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(DDYAudioRecorder*)recoder inAQ:(AudioQueueRef)						inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc;

/// 文件写入完成之后的操作，例如文件句柄关闭等,isError表示是否是因为错误才调用的
- (BOOL)completeWriteWithRecorder:(DDYAudioRecorder*)recoder withIsError:(BOOL)isError;

@end

@protocol DDYAudioRecorderDelegate <NSObject>

@required
/// 录音遇到了错误，例如创建文件失败、写入失败、关闭文件失败等等
- (void)recordError:(NSError *)error;

@optional
/// 录音被停止，一般是在writer delegate中因为一些状况意外停止录音获得此事件时候使用，参考DDYAmrRecordWriter里实现
- (void)recordStopped;

@end

@interface DDYAudioRecorder : NSObject
{
    @public
    // 音频输入队列
    AudioQueueRef _audioQueue;
    // 音频输入数据format
    AudioStreamBasicDescription	_recordFormat;
}

/// 是否正在录音
@property (atomic, assign,readonly) BOOL isRecording;
/// 采样率[必须在startRecording之前才有效，随意设置会引发异常]
@property (atomic, assign) NSUInteger sampleRate;
/// 缓冲区采集秒数[必须在startRecording之前才有效，随意设置会引发异常]
@property (atomic, assign) double bufferDurationSeconds;
/// 处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
@property (nonatomic, weak) id<DDYFileWriterForAudioRecorder> fileWriterDelegate;
/// 音频输入队列
@property (nonatomic, readonly) AudioQueueRef audioQueue;
@property (nonatomic, copy) DDYAudioRecorderReceiveStoppedBlock receiveStoppedBlock;
@property (nonatomic, copy) DDYAudioRecorderReceiveErrorBlock receiveErrorBlock;
@property (nonatomic, assign) id<DDYAudioRecorderDelegate> delegate;

/// 开始录音
- (void)startRecording;
/// 结束录音
- (void)stopRecording;

@end
