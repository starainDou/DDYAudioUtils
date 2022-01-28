//
//  DDYMp3RecordWriter.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDYAudioRecorder.h"

/// 一般使用采样率 8000 缓冲区秒数为0.5 [如果Lame出现64位兼容问题，工程里设置arch为$(ARCHS_STANDARD_32_BIT)]
@interface DDYMp3RecordWriter : NSObject<DDYFileWriterForAudioRecorder>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;

@end
