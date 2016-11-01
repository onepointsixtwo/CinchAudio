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

-(NSInteger)totalSamples;

@optional
-(NSData*)floatAudioSamplesWithLength:(NSInteger)length offsetInSamples:(NSInteger)offsetInSamples;
-(NSData*)int16AudioSamplesWithLength:(NSInteger)length offsetInSamples:(NSInteger)offsetInSamples;

@end

#endif /* AudioDataSource_h */
