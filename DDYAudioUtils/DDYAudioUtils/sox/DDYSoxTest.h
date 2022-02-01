//
//  DDYSoxTest.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDYSoxTest : NSObject

- (void)testSilenceRemove:(NSURL *)srcURL dstURL:(NSURL *)dstURL;

- (void)testPad:(NSURL *)srcURL dstURL:(NSURL *)dstURL;

- (void)testTransform:(NSURL *)srcURL profile:(int)tprofile dstURL:(NSURL *)dstURL;

@end
