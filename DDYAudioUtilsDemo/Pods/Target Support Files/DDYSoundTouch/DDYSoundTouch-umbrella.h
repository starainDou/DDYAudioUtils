#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AAFilter.h"
#import "BPMDetect.h"
#import "cpu_detect.h"
#import "DDYSoundChange.h"
#import "FIFOSampleBuffer.h"
#import "FIFOSamplePipe.h"
#import "FIRFilter.h"
#import "PeakFinder.h"
#import "RateTransposer.h"
#import "SoundTouch.h"
#import "soundtouch_config.h"
#import "STTypes.h"
#import "TDStretch.h"
#import "WaveHeader.h"

FOUNDATION_EXPORT double DDYSoundTouchVersionNumber;
FOUNDATION_EXPORT const unsigned char DDYSoundTouchVersionString[];

