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
    size_t sineWaveLength;
    SInt16* sineWave;
}

@end

@implementation PlaybackDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    sampleRate = CinchAudioSampleRate48Khz;
    sineWaveLength = sampleRate * 20;
    float frequency = 1600.f;
    sineWave = malloc(sizeof(SInt16) * sineWaveLength);
    for(long x = 0; x < sineWaveLength; x++) {
        float value = sin(((frequency * M_PI_2 * (float)x) / (float)sampleRate));
        sineWave[x] = (SInt16)(value * 32767.f);
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

-(size_t)totalSamples {
    return sineWaveLength;
}

-(void)int16AudioSamplesWithLength:(size_t)length offsetInSamples:(size_t)offsetInSamples samples:(SInt16 **)samples {
    SInt16 audioData[length];
    for(int i = 0; i < length; i++) {
        audioData[i] = sineWave[offsetInSamples + i];
    }
    
    *samples = audioData;
}

#pragma mark - Actions
-(IBAction)play:(id)sender {
    [audioPlayer play];
}

-(IBAction)stop:(id)sender {
    [audioPlayer stop];
}

@end
