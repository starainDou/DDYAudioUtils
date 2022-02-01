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

#import "DDYAmrPlayer.h"
#import "DDYAmrRecordWriter.h"
#import "DDYConvertToAmr.h"
#import "interf_dec.h"
#import "interf_enc.h"
#import "dec_if.h"
#import "if_rom.h"
#import "amrFileCodec.h"
#import "DDYAudioMeterObserver.h"
#import "DDYAudioRecorder.h"
#import "DDYAudioUtils.h"
#import "DDYAudioUtilsHeader.h"
#import "DDYCafRecordWriter.h"
#import "DDYConvertToMp3.h"
#import "DDYMp3RecordWriter.h"
#import "DDYAudioChange.h"

FOUNDATION_EXPORT double DDYAudioUtilsVersionNumber;
FOUNDATION_EXPORT const unsigned char DDYAudioUtilsVersionString[];

