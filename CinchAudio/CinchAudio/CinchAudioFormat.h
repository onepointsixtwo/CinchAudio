//
//  CinchAudioFormat.h
//  CinchAudio
//
//  Created by John Kartupelis on 29/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#ifndef CinchAudioFormat_h
#define CinchAudioFormat_h

typedef NS_ENUM(NSUInteger, CinchAudioFormatType)
{
    CinchAudioFormatType32BitFloat = 32,
    CinchAudioFormatType16BitShort = 16,
};

typedef NS_ENUM(NSUInteger, CinchAudioSampleRate)
{
    //TODO: add support for sample rates (can also use a numeric value cast to sample rate type)
    CinchAudioSampleRate48Khz = 48000,
    CinchAudioSampleRate44100Hz = 44100,
};

typedef NS_ENUM(NSUInteger, CinchAudioChannelCount)
{
    //TODO: add support for more audio channel types?
    CinchAudioMono = 1,
    CinchAudioStereo = 2,
};

@protocol CinchAudioFormat <NSObject>

-(CinchAudioFormatType)audioFormatType;
-(CinchAudioSampleRate)audioSampleRate;
-(CinchAudioChannelCount)audioChannelCount;

@end

#endif /* CinchAudioFormat_h */
