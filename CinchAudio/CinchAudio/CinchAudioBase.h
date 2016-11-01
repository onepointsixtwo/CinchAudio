//
//  CinchAudioBase.h
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinchAudioFormat.h"
@import AudioToolbox;

@interface CinchAudioBase : NSObject

@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioFormat> audioFormat;
@property (strong, nonatomic, readonly)  NSMutableArray* _Nonnull  buffers;
@property (nonatomic, readonly) AudioStreamBasicDescription audioStreamDescription;

-(void)setupAudioSession:(nonnull NSString*)AVAudioSessionCategory;
-(void)tearDownAudioSession;
-(UInt32)appropriateBufferSize;

@end
