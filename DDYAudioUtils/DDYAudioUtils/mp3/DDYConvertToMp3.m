//
//  DDYConvertToMp3.m
//  MeLLC
//
//  Created by RainDou on 2016/05/15.
//  Copyright (c) 2016 MeLLC. All rights reserved.
//

#import "DDYConvertToMp3.h"
#import <AVFoundation/AVFoundation.h>
#import <lame/lame.h>

@implementation DDYConvertToMp3

+ (void)cafToMP3:(NSString *)cafFilePath result:(DDYConvertResult)result
{
    if ([cafFilePath hasSuffix:@".caf"] || [cafFilePath hasSuffix:@".caf"]) {
        NSString *mp3FilePath = [[cafFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            @try {
                int read, write;
                
                FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
                fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
                FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
                
                const int PCM_SIZE = 8192;
                const int MP3_SIZE = 8192;
                short int pcm_buffer[PCM_SIZE*2];
                unsigned char mp3_buffer[MP3_SIZE];
                
                lame_t lame = lame_init();
                lame_set_num_channels(lame, 2);//设置1为单通道，默认为2双通道
                lame_set_in_samplerate(lame, 8000);
                // lame_set_VBR(lame, vbr_default);
                lame_set_brate(lame, 16);
                lame_set_mode(lame, 3);
                lame_set_quality(lame, 7); /* 2=high 5 = medium 7=low 音质*/
                lame_init_params(lame);
                
                do {
                    read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                    if (read == 0) {
                        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                    } else {
                        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    }
                    fwrite(mp3_buffer, write, 1, mp3);
                    
                } while (read != 0);
                
                lame_mp3_tags_fid(lame, mp3);
                
                lame_close(lame);
                fclose(mp3);
                fclose(pcm);
            }
            @catch (NSException *exception) {
                NSLog(@"%@",[exception description]);
                result(NO, @"");
            }
            @finally {
                NSLog(@"-----\n  MP3生成成功: %@   -----  \n", mp3FilePath);
                result(YES, mp3FilePath);
            }
        });
    } else {
        result(NO, @"");
    }
}

@end
