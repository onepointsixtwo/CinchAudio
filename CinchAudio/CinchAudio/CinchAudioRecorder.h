//
//  CinchAudioRecorder.h
//  CinchAudio
//
//  Created by John Kartupelis on 28/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinchAudioFormat.h"

@protocol CinchAudioRecorderDataHandler <NSObject>

@optional


@end

@interface CinchAudioRecorder : NSObject

@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioFormat> audioFormat;
@property (nonatomic, weak, readonly) _Nullable id<CinchAudioRecorderDataHandler> delegate;

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithDataHandler:(nonnull id<CinchAudioRecorderDataHandler>)dataHandler audioFormat:(nonnull id<CinchAudioFormat>)audioFormat NS_DESIGNATED_INITIALIZER;
-(void)startRecording;
-(void)stopRecording;

@end
