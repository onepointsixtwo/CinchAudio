//
//  CinchAudioPlayer.m
//  CinchAudio
//
//  Created by John Kartupelis on 28/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "CinchAudioPlayer.h"
#import "NSString+OSStatus.h"
#import <mach/mach_time.h>

@interface CinchAudioPlayer () {
    AudioQueueRef playQueue;
    AudioQueueProcessingTapRef audioQueueProcessingTap;
    unsigned long playbackPosition;
    NSTimer* endingTimer;
}

@end

@implementation CinchAudioPlayer

@synthesize audioFormat = _audioFormat;

#pragma mark - Initialiser
-(instancetype)initWithDataSource:(id<CinchAudioDataSource>)dataSource audioFormat:(id<CinchAudioFormat>)audioFormat {
    if(self = [super init]) {
        _dataSource = dataSource;
        _audioFormat = audioFormat;
        
        if([self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort) {
            NSAssert([self.dataSource respondsToSelector:@selector(int16AudioSamplesWithLength:offsetInSamples:)], @"If using 16 bit short audio format, the data source must implement the int16AudioSamplesWithLength:offsetInSamples:samples: method");
        } else if([self.audioFormat audioFormatType] == CinchAudioFormatType32BitFloat) {
            NSAssert([self.dataSource respondsToSelector:@selector(floatAudioSamplesWithLength:offsetInSamples:)], @"If using float audio format, the data source must implement the floatAudioSamplesWithLength:offsetInSamples:samples: method");
        }
        
        size_t totalSamples = [self.dataSource totalSamples];
        NSUInteger sampleRate = [self.audioFormat audioSampleRate];
        NSUInteger channels = [self.audioFormat audioChannelCount];
        NSAssert(totalSamples > 0 && sampleRate > 0 && channels > 0, @"Zero samples, channels or zero sample rate given - invalid!");
        _totalPlaybackTime = (NSTimeInterval)totalSamples / (NSTimeInterval)channels / (NSTimeInterval)sampleRate;
        
        [self setupAudio];
    }
    return self;
}

-(void)dealloc {
    [self tearDownAudio];
}


#pragma mark - Public Methods
-(void)play {
    [self setupAudioSession:AVAudioSessionCategoryPlayback];
    [self startQueue];
}

-(void)stop {
    [self stopQueue];
    [self tearDownAudioSession];
    playbackPosition = 0;
}

-(void)seekToTime:(NSTimeInterval)time {
    BOOL wasPlaying = _playing;
    [self stopQueue];
    playbackPosition = [self byteOffsetFromTimeInterval:time];
    if(wasPlaying) {
        [self startQueue];
    }
}


#pragma mark - Helpers
-(long)byteOffsetFromTimeInterval:(NSTimeInterval)time {
    NSTimeInterval totalTime = self.totalPlaybackTime;
    double proportionOfBytes = time / totalTime;
    return floor(proportionOfBytes * (double)[self.dataSource totalSamples]);
}


#pragma mark - Setup Audio
-(void)setupAudio {
    [self setupAudioQueue];
}

-(void)setupAudioQueue {
    [self createOutputAudioQueue];
    [self setupAudioProcessingTap];
    [self setupBuffers];
}

-(void)createOutputAudioQueue {
    //Create the output audio queue
    AudioStreamBasicDescription audioStreamDescription = self.audioStreamDescription;
    OSStatus err = AudioQueueNewOutput(&audioStreamDescription, audioEngineOutputBufferCallback, (__bridge void *)(self), nil, nil, 0, &playQueue);
    if (err != noErr) {
        NSLog(@"Unable to create new output audio queue (error: %@)", [NSString OSStatusToString:err]);
    }
}

-(void)setupAudioProcessingTap {
    UInt32 maxFrames;
    AudioStreamBasicDescription audioStreamDescription = self.audioStreamDescription;
    OSStatus err = AudioQueueProcessingTapNew(playQueue, processingTapCallback, (__bridge void *)self, kAudioQueueProcessingTap_PostEffects, &maxFrames, &audioStreamDescription, &audioQueueProcessingTap);
    if(err != noErr) {
        NSLog(@"Unable to create audio queue processing tap (error: %@)", [NSString OSStatusToString:err]);
    } else {
        NSLog(@"Max frames for audio processing tap %i", (int)maxFrames);
    }
}

-(void)setupBuffers {
    OSStatus err;
    UInt32 bufferByteSize = [self appropriateBufferSize];
    for(int x = 0; x < 2; x++) {
        AudioQueueBufferRef bufferRef;
        err = AudioQueueAllocateBuffer(playQueue, bufferByteSize, &bufferRef);
        if (err == noErr) {
            [self.buffers addObject:[NSValue valueWithPointer:bufferRef]];
            
            [self writeAudioToBuffer:bufferRef];
            
            err = AudioQueueEnqueueBuffer (playQueue, bufferRef, 0, NULL);
            if (err != noErr) {
                NSLog(@"Failed to enqueue data to audio buffer (error: %@)", [NSString OSStatusToString:err]);
            }
        } else {
            NSLog(@"Failed to allocate audio buffer (error: %@)", [NSString OSStatusToString:err]);
            return;
        }
    }
}


#pragma mark - Tear down
-(void)tearDownAudio {
    [self stopQueue];
    [self tearDownBuffers];
    [self releaseQueue];
}

-(void)tearDownBuffers {
    if(playQueue) {
        for(NSValue* value in self.buffers) {
            AudioQueueBufferRef buffer = (AudioQueueBufferRef)value.pointerValue;
            AudioQueueFreeBuffer(playQueue, buffer);
        }
        [self.buffers removeAllObjects];
    }
}

-(void)releaseQueue {
    if(playQueue) {
        AudioQueueDispose(playQueue, TRUE);
    }
}


#pragma mark - Playback finished handler
-(void)handlePlaybackFinished {
    NSLog(@"Playback finished");
    [self stopQueue];
}


#pragma mark - Start / Stop Queue
-(void)startQueue {
    if(playQueue && !_playing) {
        [self setupBuffers];
        OSStatus err = AudioQueueStart(playQueue, NULL);
        if (err != noErr) {
            NSLog(@"Failed to start audio queue %@", [NSString OSStatusToString:err]);
        } else {
            _playing = TRUE;
        }
    }
}

-(void)stopQueue {
    if(playQueue && _playing) {
        OSStatus err = AudioQueueStop(playQueue, TRUE);
        if (err != noErr) {
            NSLog(@"Failed to stop audio queue %@", [NSString OSStatusToString:err]);
        } else {
            [self tearDownBuffers];
            _playing = FALSE;
        }
    }
}


#pragma mark - Buffer Writing
-(void)writeAudioToBuffer:(AudioQueueBufferRef)audioQueueBuffer {
    if(playbackPosition < [self.dataSource totalSamples]) {
        void *buffer;
        size_t length;
        size_t sizeOfElement;
        
        if([self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort) {
            length = audioQueueBuffer->mAudioDataBytesCapacity / sizeof(SInt16);
            unsigned long remaining = [self.dataSource totalSamples] - playbackPosition;
            if(length > remaining) {
                length = remaining;
            }
            NSData* data = [self.dataSource int16AudioSamplesWithLength:length offsetInSamples:playbackPosition];
            buffer = (void*)[data bytes];
            sizeOfElement = sizeof(SInt16);
        } else {
            length = audioQueueBuffer->mAudioDataBytesCapacity / sizeof(float);
            unsigned long remaining = [self.dataSource totalSamples] - playbackPosition;
            if(length > remaining) {
                length = remaining;
            }
            NSData* data = [self.dataSource floatAudioSamplesWithLength:length offsetInSamples:playbackPosition];
            buffer = (void*)[data bytes];
            sizeOfElement = sizeof(float);
        }
        
        void* audioData = audioQueueBuffer->mAudioData;
        size_t bytesLength = length * sizeOfElement;
        memcpy(audioData, buffer, bytesLength);
        
        audioQueueBuffer->mAudioDataByteSize = (UInt32)bytesLength;
        
        playbackPosition += length;
    } else {
        void* audioData = audioQueueBuffer->mAudioData;
        size_t length = audioQueueBuffer->mAudioDataBytesCapacity;
        memset(audioData, 0, length);
        audioQueueBuffer->mAudioDataByteSize = 0;
    }
}

-(void)processOutputBuffer: (AudioQueueBufferRef) buffer queue:(AudioQueueRef) queue {
    if (_playing) {
        [self writeAudioToBuffer:buffer];
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
}


#pragma mark - C AudioQueue Callback - Fill in Buffer Data
void audioEngineOutputBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    CinchAudioPlayer* audioPlayer = (__bridge CinchAudioPlayer*)inUserData;
    [audioPlayer processOutputBuffer:inBuffer queue:inAQ];
}


#pragma mark - C AudioQueue callback - Audio Processing Tap
void processingTapCallback(void * inClientData, AudioQueueProcessingTapRef inAQTap, UInt32 inNumberFrames, AudioTimeStamp *ioTimeStamp, UInt32 *ioFlags, UInt32 *outNumberFrames, AudioBufferList *ioData){
    CinchAudioPlayer *cinchAudioPlayer = (__bridge CinchAudioPlayer*)inClientData;
    AudioQueueProcessingTapGetSourceAudio(inAQTap, inNumberFrames, ioTimeStamp, ioFlags, outNumberFrames, ioData);
    if (*ioFlags ==  kAudioQueueProcessingTap_StartOfStream) {
        uint64_t timeOfLastSampleLeavingSpeaker = ioTimeStamp->mHostTime + (cinchAudioPlayer.totalPlaybackTime / ticksToSeconds());
        [cinchAudioPlayer lastSampleDoneAt:timeOfLastSampleLeavingSpeaker];
    }
}


#pragma mark - ObjC Stream Completed Playback Handling
-(void)lastSampleDoneAt:(uint64_t)lastSampTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        uint64_t currentTime = mach_absolute_time();
        if (lastSampTime > currentTime) {
            double secondsFromNow = (lastSampTime - currentTime) * ticksToSeconds();
            endingTimer = [NSTimer scheduledTimerWithTimeInterval:secondsFromNow + .1f target:self selector:@selector(endingTimerFired:) userInfo:nil repeats:FALSE];
        }
        else{
            [self handlePlaybackFinished];
        }
    });
}

-(IBAction)endingTimerFired:(id)sender {
    [self handlePlaybackFinished];
}



#pragma mark - C Helper Functions
/*
 Credit for these functions, and for the method of working out when the audioqueue has completed playback goes to http://stackoverflow.com/users/1313967/dave for his answer on this question http://stackoverflow.com/questions/30377711/precise-time-of-audio-queue-playback-finish
*/
double getTimeConversion(){
    double timecon;
    mach_timebase_info_data_t tinfo;
    kern_return_t kerror;
    kerror = mach_timebase_info(&tinfo);
    timecon = (double)tinfo.numer / (double)tinfo.denom;
    
    return  timecon;
}
double ticksToSeconds(){
    static double ticksToSeconds = 0;
    if (!ticksToSeconds) {
        ticksToSeconds = getTimeConversion() * 0.000000001;
    }
    return ticksToSeconds;
}

@end
