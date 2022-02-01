//
//  DDYSoundChange.mm
//  DDYProject
//
//  Created by Megan on 17/11/28.
//  Copyright © 2017 Starain. All rights reserved.
//

#import "DDYSoundChange.h"
#import "SoundTouch.h"
#import "WaveHeader.h"

@implementation DDYSoundChange

+ (NSData *)change:(NSData *)data sampleRate:(int)sampleRate channels:(int)channels tempoChange:(int)tempoChange pitch:(int)pitch rate:(int)rate {
    soundtouch::SoundTouch mSoundTouch;
    mSoundTouch.setSampleRate(sampleRate);
    mSoundTouch.setChannels(channels);
    mSoundTouch.setTempoChange(tempoChange);
    mSoundTouch.setPitchSemiTones(pitch);
    mSoundTouch.setRateChange(rate);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); // 寻找帧长
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6); // 重叠帧长
    
    NSMutableData *soundTouchDatas = [[NSMutableData alloc] init];
    
    if (data) {
        char *pcmData = (char *)data.bytes;
        NSUInteger pcmSize = data.length;
        NSUInteger nSamples = pcmSize/2;
        mSoundTouch.putSamples((short *)pcmData, (unsigned int)nSamples);
        short *samples = new short[pcmSize];
        int numSamples = 0;
        do {
            memset(samples, 0, pcmSize);
            numSamples = mSoundTouch.receiveSamples(samples, (unsigned int)pcmSize);
            [soundTouchDatas appendBytes:samples length:numSamples*2];
        } while (numSamples > 0);
        delete [] samples;
    }
    NSMutableData *wavDatas = [[NSMutableData alloc] init];
    NSUInteger fileLength = soundTouchDatas.length;
    void *header = createWaveHeader((int)fileLength, 1, sampleRate, 16);
    [wavDatas appendBytes:header length:44];
    [wavDatas appendData:soundTouchDatas];
    return wavDatas;
}

@end



























