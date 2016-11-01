//
//  CinchAudioRecorder.h
//  CinchAudio
//
//  Created by John Kartupelis on 28/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinchAudioFormat.h"
#import "CinchAudioBase.h"
@class CinchAudioRecorder;

@protocol CinchAudioRecorderDataHandler <NSObject>

@optional
-(void)cinchAudioRecorder:(nonnull CinchAudioRecorder*)cinchAudioRecorder didReceiveInt16Data:(nonnull NSData*)data;
-(void)cinchAudioRecorder:(nonnull CinchAudioRecorder*)cinchAudioRecorder didReceiveFloatData:(nonnull NSData*)data;

@end

@interface CinchAudioRecorder : CinchAudioBase

@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioFormat> audioFormat;
@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioRecorderDataHandler> dataHandler;
@property (nonatomic, readonly) BOOL recording;

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithDataHandler:(nonnull id<CinchAudioRecorderDataHandler>)dataHandler audioFormat:(nonnull id<CinchAudioFormat>)audioFormat NS_DESIGNATED_INITIALIZER;
-(void)startRecording;
-(void)stopRecording;

@end
