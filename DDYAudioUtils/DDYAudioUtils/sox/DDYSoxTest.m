//
//  DDYSoxTest.h
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYSoxTest.h"
#import "sox.h"

@implementation DDYSoxTest

- (void)testSilenceRemove:(NSURL *)srcURL dstURL:(NSURL *)dstURL {
    silenceRemoveTest(srcURL, dstURL);
}

- (void)testPad:(NSURL *)srcURL dstURL:(NSURL *)dstURL {
    padTest(srcURL, dstURL);
}


BOOL silenceRemoveTest(NSURL *srcURL, NSURL *dstURL) {
  //remove the silence from the beginning and end of the audio in the Dir, Inner, and Actor Files
  @try {
    static sox_format_t *in, *out; /* input and output files */
    sox_effects_chain_t * effectsChain;
    sox_effect_t * soxEffect;
    char *args[10];
    /* All libSoX applications must start by initialising the SoX library */
    assert(sox_init() == SOX_SUCCESS);
    //NSLog(@"path.fileSystemRepresentation %s",startInputDirectoryPath.fileSystemRepresentation);
    assert(in = sox_open_read(srcURL.fileSystemRepresentation, NULL, NULL, NULL));
    
    /* Open the output file; we must specify the output signal characteristics.
     * Since we are using only simple effects, they are the same as the input
     * file characteristics */
    
    //NSLog(@"path.fileSystemRepresentation %s",modifiedAudio.fileSystemRepresentation);
    assert(out = sox_open_write(dstURL.fileSystemRepresentation, &in->signal, NULL, NULL, NULL, NULL));
    
    /* Create an effects chain; some effects need to know about the input
     * or output file encoding so we provide that information here */
    effectsChain = sox_create_effects_chain(&in->encoding, &out->encoding);
    
    //* The first effect in the effect chain must be something that can source
    //* samples; in this case, we use the built-in handler that inputs
    //* data from an audio file */
    
    soxEffect = sox_create_effect(sox_find_effect("input"));
    (void)(args[0] = (char *)in), assert(sox_effect_options(soxEffect, 1, args) == SOX_SUCCESS);
    /* This becomes the first `effect' in the chain */
    assert(sox_add_effect(effectsChain, soxEffect, &in->signal, &in->signal) == SOX_SUCCESS);
    
    char *options[10];
    
//    const char *sd = [durationToDetectSilence UTF8String];
//    const char *td = [thresholdCount UTF8String];
    
    options[0] = ("1");
    options[1] = ("0.3");
    options[2] = ("0.01%");
    for(int i = 0; i < 2; ++i) {
      // silence 1 0.3 0.1%
      soxEffect = sox_create_effect(sox_find_effect("silence"));
      
      if(sox_effect_options(soxEffect, 3, options) != SOX_SUCCESS) {
        //                             on_error("silence1 effect options error!");
        //                            printf("silence1 effect options error!");
        NSLog(@"silence1 effect options error!");
      }
      if(sox_add_effect(effectsChain, soxEffect, &in->signal, &in->signal) != SOX_SUCCESS) {
        NSLog(@"add effect error");
        //on_error("add effect error!");
      }
      free(soxEffect);
      
      // reverse
      soxEffect = sox_create_effect(sox_find_effect("reverse"));
      if(sox_effect_options(soxEffect, 0, NULL) != SOX_SUCCESS) {
        //on_error("silence1 effect options error!");
      }
      if(sox_add_effect(effectsChain, soxEffect, &in->signal, &in->signal) != SOX_SUCCESS) {
        //on_error("add effect error!");
      }
      free(soxEffect);
    }
    
    
    /* The last effect in the effect chain must be something that only consumes
     * samples; in this case, we use the built-in handler that outputs
     * data to an audio file */
    
    
    soxEffect = sox_create_effect(sox_find_effect("output"));
    (void)(args[0] = (char *)out), assert(sox_effect_options(soxEffect, 1, args) == SOX_SUCCESS);
    assert(sox_add_effect(effectsChain, soxEffect, &out->signal, &out->signal) == SOX_SUCCESS);
    
    /* Flow samples through the effects processing chain until EOF is reached */
    sox_flow_effects(effectsChain, NULL, NULL);
    
    /* All done; tidy up: */
    sox_delete_effects_chain(effectsChain);
    sox_close(out);
    sox_close(in);
    sox_quit();
    //  });
    
    
  }@catch (NSException *exception) {
    NSLog(@"Error Occure During Trimming: %@", [exception description]);
//    [self errorOccuredDuringFileTrim];
    //return NO;
  }
}

BOOL padTest(NSURL *srcURL, NSURL *dstURL) {
  @try {
    static sox_format_t *in, *out; /* input and output files */
    sox_effects_chain_t * effectsChain;
    sox_effect_t * soxEffect;
    char *args[10];
    /* All libSoX applications must start by initialising the SoX library */
    assert(sox_init() == SOX_SUCCESS);
    //NSLog(@"path.fileSystemRepresentation %s",startInputDirectoryPath.fileSystemRepresentation);
    assert(in = sox_open_read(srcURL.fileSystemRepresentation, NULL, NULL, NULL));
    
    /* Open the output file; we must specify the output signal characteristics.
     * Since we are using only simple effects, they are the same as the input
     * file characteristics */
    
    //NSLog(@"path.fileSystemRepresentation %s",modifiedAudio.fileSystemRepresentation);
    assert(out = sox_open_write(dstURL.fileSystemRepresentation, &in->signal, NULL, NULL, NULL, NULL));
    
    /* Create an effects chain; some effects need to know about the input
     * or output file encoding so we provide that information here */
    effectsChain = sox_create_effects_chain(&in->encoding, &out->encoding);
    
    //* The first effect in the effect chain must be something that can source
    //* samples; in this case, we use the built-in handler that inputs
    //* data from an audio file */
    
    soxEffect = sox_create_effect(sox_find_effect("input"));
    (void)(args[0] = (char *)in), assert(sox_effect_options(soxEffect, 1, args) == SOX_SUCCESS);
    /* This becomes the first `effect' in the chain */
    assert(sox_add_effect(effectsChain, soxEffect, &in->signal, &in->signal) == SOX_SUCCESS);
    
    char *options[10];
    
    options[0] = ("0");
    options[1] = ("1");
    
    soxEffect = sox_create_effect(sox_find_effect("pad"));
    
    if(sox_effect_options(soxEffect, 2, options) != SOX_SUCCESS) {
      //                             on_error("silence1 effect options error!");
      //                            printf("silence1 effect options error!");
      NSLog(@"pad effect options error!");
    }
    if(sox_add_effect(effectsChain, soxEffect, &in->signal, &in->signal) != SOX_SUCCESS) {
      NSLog(@"pad add effect error");
      //          on_error("add effect error!");
    }
    free(soxEffect);
    
    

    /* The last effect in the effect chain must be something that only consumes
     * samples; in this case, we use the built-in handler that outputs
     * data to an audio file */
    
    
    soxEffect = sox_create_effect(sox_find_effect("output"));
    (void)(args[0] = (char *)out), assert(sox_effect_options(soxEffect, 1, args) == SOX_SUCCESS);
    assert(sox_add_effect(effectsChain, soxEffect, &out->signal, &out->signal) == SOX_SUCCESS);
    
    /* Flow samples through the effects processing chain until EOF is reached */
    sox_flow_effects(effectsChain, NULL, NULL);
    
    /* All done; tidy up: */
    sox_delete_effects_chain(effectsChain);
    sox_close(out);
    sox_close(in);
    sox_quit();
    //  });
    
    
  }@catch (NSException *exception) {
    NSLog(@"Error Occure During Trimming: %@", [exception description]);
    //    [self errorOccuredDuringFileTrim];
    //return NO;
  }
  
}

- (void)testTransform:(NSURL *)srcURL profile:(int)tprofile dstURL:(NSURL *)dstURL {
    static sox_format_t *in, *out; /* input and output files */
    sox_effects_chain_t * chain;
    sox_effect_t * e;
    char *args[10];
    
    //    if ([[NSFileManager alloc] fileExistsAtPath:target])
    //        return target;
    
    /* All libSoX applications must start by initialising the SoX library */
    assert(sox_init() == SOX_SUCCESS);
    
    /* Open the input file (with default parameters) */
    assert(in = sox_open_read(srcURL.fileSystemRepresentation, NULL, NULL, NULL));
    
    /* Open the output file; we must specify the output signal characteristics.
     * Since we are using only simple effects, they are the same as the input
     * file characteristics */
    // assert(out = sox_open_write([modifiedAudio UTF8String], &in->signal, NULL, NULL, NULL, NULL));
    assert(out = sox_open_write(dstURL.fileSystemRepresentation, &in->signal, NULL, NULL, NULL, NULL));
    /* Create an effects chain; some effects need to know about the input
     * or output file encoding so we provide that information here */
    chain = sox_create_effects_chain(&in->encoding, &out->encoding);
    
    /* The first effect in the effect chain must be something that can source
     * samples; in this case, we use the built-in handler that inputs
     * data from an audio file */
    e = sox_create_effect(sox_find_effect("input"));
    args[0] = (char *)in, assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
    /* This becomes the first `effect' in the chain */
    assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    if (tprofile == 0) {
        //small hall effect
        e = sox_create_effect(sox_find_effect("reverb"));
        args[0] = "60", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
    }
    
    if (tprofile == 1) {
        //small hall effect
        e = sox_create_effect(sox_find_effect("reverse"));
        //        args[0] = "90", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
        //e = sox_create_effect(sox_find_effect("gain"));
        //args[0] = "-10", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        //assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    }
    
    if (tprofile == 2) {

        e = sox_create_effect(sox_find_effect("highpass"));
        args[0] = "2000", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
        e = sox_create_effect(sox_find_effect("gain"));
        args[0] = "-10", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    }
    
    if (tprofile == 3) {
        
//        e = sox_create_effect(sox_find_effect("tremolo"));
//        args[0] = "1";
//        args[1] = "60";
//        assert(SOX_SUCCESS == sox_effect_options(e, 2, args));
//        assert(SOX_SUCCESS == sox_add_effect(chain, e, &in->signal, &out->signal));

        e = sox_create_effect(sox_find_effect("echo"));
        args[0] = "0.9";// 输入音量
        args[1] = "0.7"; // 输出音量
        args[2] = "200"; // 延迟 ms
        
        args[3] = "0.25";
        args[4] = "260";
        
        args[5] = "0.3"; // 相对于输入音量的衰减值
        assert(sox_effect_options(e, 6, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
//        e = sox_create_effect(sox_find_effect("chorus"));
//        args[0] = "0.7";
//        args[1] = "0.9";
//        args[2] = "55";
//        args[3] = "0.4";
//        args[4] = "0.25";
//        args[5] = "2";
//        args[6] = "-t";
//        assert(sox_effect_options(e, 7, args) == SOX_SUCCESS);
//        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
//        e = sox_create_effect(sox_find_effect("delay"));
//        args[0] = "0", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
//        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
        e = sox_create_effect(sox_find_effect("pitch"));
        args[0] = "200", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
//
//        e = sox_create_effect(sox_find_effect("speed"));
//        args[0] = "1.5", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
//        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
//        e = sox_create_effect(sox_find_effect("bass"));
//        args[0] = "20", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
//        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
        
//        e = sox_create_effect(sox_find_effect("reverb"));
//        args[0] = "-w";
//        args[1] = "2";
//        args[2] = "0";
//        args[3] = "2";
//        args[4] = "1";
//        args[5] = "0";
//        args[6] = "0";
//        assert(sox_effect_options(e, 7, args) == SOX_SUCCESS);
//        assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    }
    
    
    /* Create the `vol' effect, and initialise it with the desired parameters: */
//    e = sox_create_effect(sox_find_effect("vol"));
//    args[0] = "3dB", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
//    /* Add the effect to the end of the effects processing chain: */
//    assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    
    /* Create the `flanger' effect, and initialise it with default parameters: */
    e = sox_create_effect(sox_find_effect("flanger"));
    assert(sox_effect_options(e, 0, NULL) == SOX_SUCCESS);
    /* Add the effect to the end of the effects processing chain: */
    assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    
    
    /* The last effect in the effect chain must be something that only consumes
     * samples; in this case, we use the built-in handler that outputs
     * data to an audio file */
    e = sox_create_effect(sox_find_effect("output"));
    args[0] = (char *)out, assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
    assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    
    /* Flow samples through the effects processing chain until EOF is reached */
    sox_flow_effects(chain, NULL, NULL);
    
    /* All done; tidy up: */
    sox_delete_effects_chain(chain);
    sox_close(out);
    sox_close(in);
    sox_quit();
}

@end
// http://sox.sourceforge.net/Docs/Features
// https://www.shuzhiduo.com/A/pRdBOam1zn/
// https://www.shuzhiduo.com/A/1O5EgvMaz7/
// https://www.jianshu.com/p/9fb24dc60f29
// https://github.com/pxhbug123/SoxLibInAndroid/blob/77038094325ebaddc2d0919a88c20127bdd2c70c/soxcommandlibrary/src/main/sox/src/JniNative.c
// https://github.com/AwaisFayyaz/Soxlib-iOS-Test
// https://github.com/shieldlock/SoX-iPhone-Lib/blob/master/AudioEffects/AudioEffects/ViewController.m
// https://github.com/mixflame/MixDJ/blob/c125d7372a434a3353c2269fe27c00e52a2d2f3e/MixDJ/soxEncode.m
// https://github.com/KelvinJin/libsox-iOS
