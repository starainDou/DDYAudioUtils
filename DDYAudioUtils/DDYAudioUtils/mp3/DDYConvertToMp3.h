//
//  DDYAudioUtils.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 定义格式转换结果闭包
typedef void (^DDYConvertResult) (BOOL success, NSString *path);

@interface DDYConvertToMp3 : NSObject

/// caf 格式转换 mp3 [录音必须双声道，samplerate要保持一致]
/// @param cafFilePath 原caf文件路径
/// @param result 转换结果
+ (void)cafToMP3:(NSString *)cafFilePath result:(DDYConvertResult)result;

@end
