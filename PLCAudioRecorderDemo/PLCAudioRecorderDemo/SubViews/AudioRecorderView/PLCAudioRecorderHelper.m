//
//  PLCAudioRecorderHelper.m
//  PLCAudioRecorderDemo
//
//  Created by PlutusCat on 2017/4/27.
//  Copyright © 2017年 PlutusCat. All rights reserved.
//

#import "PLCAudioRecorderHelper.h"

@interface PLCAudioRecorderHelper ()<AVAudioRecorderDelegate>
/** 录音文件地址 */
@property (nonatomic, strong) NSURL *recordFileUrl;
//音频录音机
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioSession *session;
@end

@implementation PLCAudioRecorderHelper

static PLCAudioRecorderHelper *_instance;

static id instance;

+ (instancetype)sharedPLCAudioRecorderHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

#pragma mark - 懒加载
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        
        // 1.获取沙盒地址
        self.recordFileUrl = [PLCAudioPath getRecordFilePath];
        NSLog(@"recordFileUrl = %@", self.recordFileUrl);
        
        // 3.设置录音的一些参数
        NSDictionary *setting = [self getAudioSetting];

        NSError *error = nil;
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordFileUrl
                                                         settings:setting
                                                            error:&error];
        self.audioRecorder.delegate = self;
        self.audioRecorder.meteringEnabled = YES;
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
        [self.audioRecorder prepareToRecord];
    }
    return _audioRecorder;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //录音的质量
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //....其他设置等
    return dicM;
}


#pragma mark - - 开始录音
- (void)startAudioRecorder {
    // 停止正在播放的音频
    
    // 停止正在录制的音频
//    [self.audioRecorder stop];
    // 删除之前的录音文件
//    [self.audioRecorder deleteRecording];
    [PLCAudioPath deleteRecordFile];

    /**
     *  开始录音
     *  设置音频会话
     */
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
        
    }else {
        [session setActive:YES error:nil];
    }
    
    self.session = session;

    if ([self.audioRecorder prepareToRecord]) {
        NSLog(@"prepareToRecord = YES");
    }else {
        NSLog(@"prepareToRecord = NO");
    }
    
    if ([self.audioRecorder record]) {
        NSLog(@"record = YES");
    }else {
        NSLog(@"record = NO");
    }
    
}

#pragma mark - - 暂停录音
- (void)pauseAudioRecorder {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
    }
}

#pragma mark - - 恢复录音
- (void)resumeAudioRecorder {
    [self startAudioRecorder];
}

#pragma mark - - 停止录音
- (void)endAudioRecorder {
    [self.audioRecorder stop];
}

#pragma mark - - AVAudioRecorderDelegate -
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"录音完成!");
        [self.session setActive:NO error:nil];
    }  
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    
    NSLog(@"录音出错 = %@", error);
    
}

@end
