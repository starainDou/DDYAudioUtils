//
//  DDYCafRecordWriter.m
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYCafRecordWriter.h"

@interface DDYCafRecordWriter() {
    AudioFileID mRecordFile;
    SInt64 recordPacketCount;
}

@end

@implementation DDYCafRecordWriter


- (BOOL)createFileWithRecorder:(DDYAudioRecorder*)recoder {
    // 建立文件
    recordPacketCount = 0;
    
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)self.filePath, NULL);
    OSStatus err = AudioFileCreateWithURL(url, kAudioFileCAFType, (const AudioStreamBasicDescription	*)(&(recoder->_recordFormat)), kAudioFileFlags_EraseFile, &mRecordFile);
    CFRelease(url);
    
    return err == noErr;
}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(DDYAudioRecorder*)recoder inAQ:(AudioQueueRef)						inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc {
    OSStatus err = AudioFileWritePackets(mRecordFile, FALSE, data.length,
                                         inPacketDesc, recordPacketCount, &inNumPackets, data.bytes);
    if (err != noErr) {
        return NO;
    }
    recordPacketCount += inNumPackets;
    
    return YES;
}

- (BOOL)completeWriteWithRecorder:(DDYAudioRecorder*)recoder withIsError:(BOOL)isError {
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
    //    NSData *data = [[NSData alloc]initWithContentsOfFile:self.filePath];
    //    NSLog(@"文件长度%ld",data.length);
    return YES;
}

-(void)dealloc {
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
}
@end
