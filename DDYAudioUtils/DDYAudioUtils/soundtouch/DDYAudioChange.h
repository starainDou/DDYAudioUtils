//
//  DDYAudioChange.h
//  DDYProject
//
//  Created by Megan on 17/11/28.
//  Copyright © 2017 Starain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct ACConfig {
    /// 采样率 <8K-48K 人能听到的频率一般 20-20000Hz>
    int sampleRate;
    /// 速度 <变速不变调> [-50, 100]
    int tempoChange;
    /// 音调 <男:-8 女:8> [-12, 12]
    int pitch;
    /// 声音速率 [-50, 100]
    int rate;
    /// 声道数
    int channels;
} DDYACConfig;

CG_INLINE DDYACConfig
DDYACMake(int sampleRate, int tempoChange, int pitch, int rate, int channels)
{
    DDYACConfig config;
    config.sampleRate = sampleRate;
    config.tempoChange = tempoChange;
    config.pitch = pitch;
    config.rate = rate;
    config.channels = channels;
    return config;
}

@interface DDYAudioChange : NSObject
{
    id target;
    SEL action;
    NSData *data;
    DDYACConfig config;
}

+ (NSData *)change:(NSData *)data withConfig:(DDYACConfig)config;

@end
// http://www.surina.net/soundtouch/download.html
