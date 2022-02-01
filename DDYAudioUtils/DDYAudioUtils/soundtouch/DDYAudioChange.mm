//
//  DDYAudioChange.m
//  DDYProject
//
//  Created by Megan on 17/11/28.
//  Copyright © 2017 Starain. All rights reserved.
//

#import "DDYAudioChange.h"
//#import "SoundTouch.h"
//#import "WaveHeader.h"
#import <DDYSoundTouch/DDYSoundChange.H>

@implementation DDYAudioChange

+ (NSData *)change:(NSData *)data withConfig:(DDYACConfig)config {
    return [DDYSoundChange change:data sampleRate:config.sampleRate channels:config.channels tempoChange:config.tempoChange pitch:config.pitch rate:config.rate];
}

//+ (id)changeConfig:(DDYACConfig)config audioData:(NSData *)data target:(id)target action:(SEL)action {
//    return [[self alloc] initWithConfig:config audioData:data target:target action:action];
//}
//
//- (id)initWithConfig:(DDYACConfig)myConfig audioData:(NSData *)myData target:(id)myTarget action:(SEL)myAction {
//    if (self = [super init]) {
//        target = myTarget;
//        action = myAction;
//        config = myConfig;
//        data   = myData;
//    }
//    return self;
//}
//
//- (void)main {
//    NSData *wavDatas = [DDYAudioChange change:data withConfig:config];
//
//    BOOL result = [wavDatas writeToFile:@"" atomically:YES];
//
//    if (result && !self.isCancelled) {
//        [target performSelectorOnMainThread:action withObject:nil waitUntilDone:NO];
//    }
//}

@end



























