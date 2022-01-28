//
//  DDYMp3RecordWriter.m
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYMp3RecordWriter.h"
#import <lame/lame.h>

@interface DDYMp3RecordWriter() {
    FILE *_file;
    lame_t _lame;
}

@property (nonatomic, assign) unsigned long recordedFileSize;
@property (nonatomic, assign) double recordedSecondCount;

@end

@implementation DDYMp3RecordWriter


- (BOOL)createFileWithRecorder:(DDYAudioRecorder*)recoder {

    _lame = lame_init();
	lame_set_num_channels(_lame, 1);
	lame_set_in_samplerate(_lame, 8000);
    lame_set_out_samplerate(_lame, 8000);
	lame_set_brate(_lame, 16); // 128
	lame_set_mode(_lame, 3);
	lame_set_quality(_lame, 7); // 2=high 5 = medium 7=low 音质
	lame_init_params(_lame);
    
    //建立mp3文件
    _file = fopen([self.filePath cStringUsingEncoding: 1], "wb+"); // _file = fopen((const char *)[self.filePath UTF8String], "wb+");
    if (_file == 0) {
        NSLog(@"建立文件失败:%s", __FUNCTION__);
        return NO;
    }
    self.recordedFileSize = 0;
    self.recordedSecondCount = 0;
    return YES;
}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(DDYAudioRecorder*)recoder inAQ:(AudioQueueRef) inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc {
    if (self.maxSecondCount > 0) {
        if (self.recordedSecondCount + recoder.bufferDurationSeconds > self.maxSecondCount) {
            // NSLog(@"录音超时");
            dispatch_async(dispatch_get_main_queue(), ^{
                [recoder stopRecording];
            });
            return YES;
        }
        self.recordedSecondCount += recoder.bufferDurationSeconds;
    }
    
    // 编码
    short *recordingData = (short*)data.bytes;
    int pcmLen = data.length;
    
    if (pcmLen < 2) {
        return YES;
    }
    
    int nsamples = pcmLen / 2;
    
    unsigned char buffer[pcmLen];
    // mp3 encode
    int recvLen = lame_encode_buffer(_lame, recordingData, recordingData, nsamples, buffer, pcmLen);
    // add NSMutable
    if (recvLen > 0) {
        if (self.maxFileSize > 0) {
            if (self.recordedFileSize + recvLen > self.maxFileSize) {
                // NSLog(@"录音文件过大");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [recoder stopRecording];
                });
                return YES; // 超过了最大文件大小就直接返回
            }
        }
        
        if (fwrite(buffer, 1, recvLen, _file) == 0) {
            return NO;
        }
        self.recordedFileSize += recvLen;
    }
    return YES;
}

- (void)closeFile {
    if (_file) {
        fclose(_file);
        _file = 0;
    }
    if (_lame) {
        lame_close(_lame);
        _lame = 0;
    }
}

- (BOOL)completeWriteWithRecorder:(DDYAudioRecorder*)recoder withIsError:(BOOL)isError {
    // 关闭就关闭吧。管他关闭成功与否
    [self closeFile];
    return YES;
}

- (void)dealloc {
    [self closeFile];
}

@end
