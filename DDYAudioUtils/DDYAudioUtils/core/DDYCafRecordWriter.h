//
//  DDYCafRecordWriter.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDYAudioRecorder.h"

@interface DDYCafRecordWriter : NSObject<DDYFileWriterForAudioRecorder>

@property (nonatomic, copy) NSString *filePath;

@end
