//
//  PlaybackDemoViewController.m
//  CinchAudioDemo
//
//  Created by John Kartupelis on 31/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "PlaybackDemoViewController.h"
#import <CinchAudio/CinchAudio.h>

@interface PlaybackDemoViewController () <CinchAudioDataSource, CinchAudioFormat> {
    CinchAudioPlayer* audioPlayer;
    CinchAudioSampleRate sampleRate;
    NSMutableData* sineWave;
}

@end

@implementation PlaybackDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    sampleRate = CinchAudioSampleRate48Khz;
    long long sineWaveLength = sampleRate * 20;
    float frequency = 1600.f;
    sineWave = [[NSMutableData alloc] init];
    for(long x = 0; x < sineWaveLength; x++) {
        float value = sin(((frequency * M_PI_2 * (float)x) / (float)sampleRate));
        SInt16 v = (SInt16)(value * 32767.f);
        [sineWave appendPCMInt16:v];
    }
    
    audioPlayer = [[CinchAudioPlayer alloc] initWithDataSource:self audioFormat:self];
}

-(CinchAudioFormatType)audioFormatType {
    return CinchAudioFormatType16BitShort;
}

-(CinchAudioSampleRate)audioSampleRate {
    return sampleRate;
}

-(CinchAudioChannelCount)audioChannelCount {
    return CinchAudioMono;
}

-(NSInteger)totalSamples {
    return [sineWave PCMInt16Length];
}

-(NSData*)int16AudioSamplesWithLength:(NSInteger)length offsetInSamples:(NSInteger)offsetInSamples {
    return [sineWave pcmInt16SubDataWithSamplesRange:NSMakeRange(offsetInSamples, length)];
}

#pragma mark - Actions
-(IBAction)play:(id)sender {
    [audioPlayer play];
}

-(IBAction)stop:(id)sender {
    [audioPlayer stop];
}

@end
