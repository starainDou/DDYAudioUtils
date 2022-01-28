//
//  DDYAmrRecordWriter.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDYAudioRecorder.h"

@interface DDYAmrRecordWriter : NSObject<DDYFileWriterForAudioRecorder>

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;

@end
