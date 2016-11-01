//
//  CinchAudioRecorder.m
//  CinchAudio
//
//  Created by John Kartupelis on 28/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "CinchAudioRecorder.h"
#import "NSString+OSStatus.h"
@import AVFoundation;
@import AudioToolbox;

@interface CinchAudioRecorder () {
    AudioQueueRef recordQueue;
}

@end


@implementation CinchAudioRecorder

@synthesize audioFormat = _audioFormat;

#pragma mark - Initialisation
-(nonnull instancetype)initWithDataHandler:(nonnull id<CinchAudioRecorderDataHandler>)dataHandler audioFormat:(nonnull id<CinchAudioFormat>)audioFormat {
    if(self = [super init]) {
        _dataHandler = dataHandler;
        _audioFormat = audioFormat;
        
        if([self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort) {
            NSAssert([self.dataHandler respondsToSelector:@selector(cinchAudioRecorder:didReceiveInt16Data:)], @"If using 16 bit short audio format, the data source must implement the int16AudioSamplesWithLength:offsetInSamples:samples: method");
        } else if([self.audioFormat audioFormatType] == CinchAudioFormatType32BitFloat) {
            NSAssert([self.dataHandler respondsToSelector:@selector(cinchAudioRecorder:didReceiveFloatData:)], @"If using float audio format, the data source must implement the floatAudioSamplesWithLength:offsetInSamples:samples: method");
        }
        
        [self setupAudioRecording];
    }
    return self;
}

-(void)dealloc {
    [self tearDownAudioRecording];
}


#pragma mark - Public Methods
-(void)startRecording {
    [self enqueueBuffers];
    [self startQueue];
}

-(void)stopRecording {
    [self stopQueue];
    [self dequeueBuffers];
}


#pragma mark - Start / Stop Queue
-(void)startQueue {
    if(recordQueue && !_recording) {
        OSStatus err = AudioQueueStart(recordQueue, NULL);
        if (err != noErr) {
            NSLog(@"Failed to start audio queue %@", [NSString OSStatusToString:err]);
        } else {
            _recording = TRUE;
        }
    }
}

-(void)stopQueue {
    if(recordQueue && _recording) {
        OSStatus err = AudioQueueStop(recordQueue, TRUE);
        if (err != noErr) {
            NSLog(@"Failed to stop audio queue %@", [NSString OSStatusToString:err]);
        } else {
            _recording = FALSE;
        }
    }
}


#pragma mark - Set Up Audio Recording
-(void)setupAudioRecording {
    [self createRecordingAudioQueue];
}

-(void)createRecordingAudioQueue {
    AudioStreamBasicDescription audioStreamDescription = self.audioStreamDescription;
    OSStatus err = AudioQueueNewInput(&audioStreamDescription, audioEngineInputBufferCallback, ((__bridge void*)self), NULL, NULL, 0, &recordQueue);
    if (err != noErr) {
        NSLog(@"Unable to create new output audio queue (error: %@)", [NSString OSStatusToString:err]);
    }
}

-(void)enqueueBuffers {
    UInt32 bufferSize = [self appropriateBufferSize];
    for (int x = 0; x < 3; x++) {
        AudioQueueBufferRef buffer;
        OSStatus err = AudioQueueAllocateBuffer(recordQueue, bufferSize, &buffer);
        if(err != noErr) {
            NSLog(@"Failed to allocate buffer for audio recording %@", [NSString OSStatusToString:err]);
            continue;
        }
        
        err = AudioQueueEnqueueBuffer(recordQueue, buffer, 0, NULL);
        if(err != noErr) {
            NSLog(@"Failed to enqueue buffer for audio recording %@", [NSString OSStatusToString:err]);
        }
        
        [self.buffers addObject:[NSValue valueWithPointer:buffer]];
    }
}

#pragma mark - Tear Down Audio Recording
-(void)tearDownAudioRecording {
    //TODO: complete tear down
}

-(void)dequeueBuffers {
    if(recordQueue) {
        for(NSValue* value in self.buffers) {
            AudioQueueBufferRef buffer = (AudioQueueBufferRef)value.pointerValue;
            AudioQueueFreeBuffer(recordQueue, buffer);
        }
        [self.buffers removeAllObjects];
    }
}

#pragma mark - Callbacks for Audio Recording
void audioEngineInputBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
    CinchAudioRecorder* recorder = (__bridge CinchAudioRecorder*)inUserData;
    [recorder handleAudioRecorderCallback:inBuffer];
    
    OSStatus err = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    if(err != noErr && err != -66632) {
        NSLog(@"AudioQueueEnqueueBuffer failed with error %@", [NSString OSStatusToString:err]);
    }
}

-(void)handleAudioRecorderCallback:(AudioQueueBufferRef)buffer {
    if(!_recording) {
        return;
    }
    
    void* bytes = buffer->mAudioData;
    size_t bytesSize = buffer->mAudioDataByteSize;
    
    NSData* data = [[NSData alloc] initWithBytes:bytes length:bytesSize];
    
    if([self.audioFormat audioFormatType] == CinchAudioFormatType16BitShort) {
        [self.dataHandler cinchAudioRecorder:self didReceiveInt16Data:data];
    } else if([self.audioFormat audioFormatType] == CinchAudioFormatType32BitFloat) {
        [self.dataHandler cinchAudioRecorder:self didReceiveFloatData:data];
    }
}

@end
