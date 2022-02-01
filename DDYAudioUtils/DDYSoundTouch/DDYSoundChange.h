//
//  DDYSoundChange.h
//  DDYProject
//
//  Created by Megan on 17/11/28.
//  Copyright © 2017 Starain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDYSoundChange: NSObject

+ (NSData *)change:(NSData *)data sampleRate:(int)sampleRate channels:(int)channels tempoChange:(int)tempoChange pitch:(int)pitch rate:(int)rate;

@end
// http://www.surina.net/soundtouch/download.html
