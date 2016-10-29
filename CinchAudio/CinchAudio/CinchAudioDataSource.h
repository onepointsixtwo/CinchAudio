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

-(size_t)totalCount;

@optional
-(void)provideFloatAudioData:(float**)audioData count:(size_t*)count offset:(size_t)offset;
-(void)provide16BitAudioData:(int16_t**)audioData count:(size_t*)count offset:(size_t)offset;

@end

#endif /* AudioDataSource_h */
