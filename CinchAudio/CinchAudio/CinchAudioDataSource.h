//
//  AudioDataSource.h
//  CinchAudio
//
//  Created by John Kartupelis on 29/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#ifndef AudioDataSource_h
#define AudioDataSource_h

@protocol CinchAudioDataSource <NSObject>

-(size_t)totalSamples;

@optional
-(void)floatAudioSamplesWithLength:(size_t)length offsetInSamples:(size_t)offsetInSamples samples:(float**)samples;
-(void)int16AudioSamplesWithLength:(size_t)length offsetInSamples:(size_t)offsetInSamples samples:(SInt16**)samples;

@end

#endif /* AudioDataSource_h */
