//
//  DDYAudioUtils.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 定义结果闭包[state 状态 -1出错 0准备 1进行中 2完成]
typedef void (^DDYAudioResult) (NSInteger state);

@interface DDYAudioUtils : NSObject

+ (instancetype)shared;
//+ (instancetype)new NS_UNAVAILABLE;
//- (instancetype)init NS_UNAVAILABLE;
//- (id)copy NS_UNAVAILABLE;
//- (id)mutableCopy NS_UNAVAILABLE;

// MARK: - 录制
/// 录音设置
@property (nonatomic, strong) NSDictionary *recordSetting;

/// 开始录音
- (void)startRecordWith:(NSString *)path result:(DDYAudioResult)result;
/// 停止录音
- (void)stopRecord;
/// 删除录音
- (void)deleteRecord;
/// 获取录制分贝值
- (float)recordLevels;

// MARK: - 播放
/// 播放模式 默认扬声器AVAudioSessionCategoryPlayback
@property (nonatomic, strong) NSString *audioCategory;
/// 播放进度
@property (nonatomic, assign, readonly) float palyProgress;
/// 播放音量 0-1
@property (nonatomic, assign) CGFloat volume;
/// 播放本地音频
- (void)playWith:(NSString *)path result:(DDYAudioResult)result;
/// 暂停播放
- (void)pausePlay;
/// 停止播放
- (void)stopPlay;
/// 恢复播放
- (void)resumePlay;
/// 获取播放分贝值
- (float)playLevels;

// MARK: - 工具
+ (float)audioDuration:(NSString *)path;

+ (void)permission;

@end
