//
//  CinchAudioBase.m
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "CinchAudioBase.h"
@import AVFoundation;

@interface CinchAudioBase ()

@property (strong, nonatomic) NSString* storedAudioSessionCategory;

@end


@implementation CinchAudioBase

#pragma mark - Initialisation
-(instancetype)init {
    if(self = [super init]) {
        _buffers = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Audio Stream Description
-(AudioStreamBasicDescription)audioStreamDescription {
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = (Float64)[self.audioFormat audioSampleRate];
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = [self audioFormatFlags];
    streamFormat.mBitsPerChannel = [self bitsPerChannel];
    streamFormat.mChannelsPerFrame = [self channelsPerFrame];
    streamFormat.mBytesPerPacket = ([self bitsPerChannel] / 8) * streamFormat.mChannelsPerFrame;
    streamFormat.mBytesPerFrame = ([self bitsPerChannel] / 8) * streamFormat.mChannelsPerFrame;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mReserved = 0;
    return streamFormat;
}

-(UInt32)bitsPerChannel {
    return (UInt32)[self.audioFormat audioFormatType];
}

-(UInt32)channelsPerFrame {
    return (UInt32)[self.audioFormat audioChannelCount];
}

-(AudioFormatFlags)audioFormatFlags {
    if([self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort) {
        return kAudioFormatFlagIsSignedInteger;
    }
    return kLinearPCMFormatFlagIsFloat;
}


#pragma mark - AudioSession Handling
-(void)setupAudioSession:(NSString*)AVAudioSessionCategory {
    NSError* error = nil;
    
    self.storedAudioSessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error) {
        NSLog(@"Failed to set category playback on avaudiosssion %@", error);
        error = nil;
    }
    
    [[AVAudioSession sharedInstance] setActive:TRUE error:&error];
    if(error) {
        NSLog(@"Failed to setactive on avaudiosssion %@", error);
        error = nil;
    }
    
    [[AVAudioSession sharedInstance] setPreferredSampleRate:[self.audioFormat audioSampleRate] error:&error];
    if(error) {
        NSLog(@"Failed to set preferred sample rate on avaudiosssion %@", error);
        error = nil;
    }
}

-(void)tearDownAudioSession {
    NSError* error = nil;
    
    if(self.storedAudioSessionCategory) {
        [[AVAudioSession sharedInstance] setCategory:self.storedAudioSessionCategory error:&error];
        if(error) {
            NSLog(@"Failed to set category playback on avaudiosssion %@", error);
            error = nil;
        }
    }
    
    [[AVAudioSession sharedInstance] setActive:FALSE error:&error];
    if(error) {
        NSLog(@"Failed to setactive on avaudiosssion %@", error);
        error = nil;
    }
}

#pragma mark - Helpers
-(UInt32)appropriateBufferSize {
    //Appropritae buffer size just returns a buffer large enough for 1/2 second of audio
    size_t elementSize = [self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort ? sizeof(SInt16) : sizeof(float);
    return (UInt32)(([self.audioFormat audioSampleRate] / 2) * elementSize);
}

@end
