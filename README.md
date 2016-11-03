# CinchAudio

[![CI Status](http://img.shields.io/travis/John Arvids Kartupelis/CinchAudio.svg?style=flat)](https://travis-ci.org/onepointsixtwo/CinchAudio)
[![Version](https://img.shields.io/cocoapods/v/CinchAudio.svg?style=flat)](http://cocoapods.org/pods/CinchAudio)
[![License](https://img.shields.io/cocoapods/l/CinchAudio.svg?style=flat)](http://cocoapods.org/pods/CinchAudio)
[![Platform](https://img.shields.io/cocoapods/p/CinchAudio.svg?style=flat)](http://cocoapods.org/pods/CinchAudio)

## Requirements

This does not have any dependencies on other libraries other than iOS runtimes

## Installation

CinchAudio is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CinchAudio"
```

## Author

John Arvids Kartupelis, john.kartupelis@gmail.com

## License

CinchAudio is available under the Apache 2.0 license. See the LICENSE file for more info.

## Usage

There is a demo application; you can fork this repo or download the zip and try it out. The demo application is a tabbed iOS app containing one tab showing the recorder working (with a very simple visualizer) and one tab showing the playback working outputting a simple sine wave.

### Audio Playback

The CinchAudioPlayer can be created as follows: 

```
CinchAudioPlayer *audioPlayer = [[CinchAudioPlayer alloc] initWithDataSource:<some data source> audioFormat:<some audio format>];
```

where <some data source> is a class which implements the data source protocol:

```
@protocol CinchAudioDataSource <NSObject>

-(NSInteger)totalSamples;

@optional
-(NSData*)floatAudioSamplesWithLength:(NSInteger)length offsetInSamples:(NSInteger)offsetInSamples;
-(NSData*)int16AudioSamplesWithLength:(NSInteger)length offsetInSamples:(NSInteger)offsetInSamples;

@end
```

The data source protocol allows using either float audio samples or int16 audio samples depending on your preference / which for your existing data is in. 

The CinchAudioPlayer constructor also takes an argument of an audioFormat which is an object implementing the audio format protocol: 

```
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
```

The protocol defines the type of PCM audio. The type specified will set which callback is chosen in the data source - using float calls the float audio samples method and using shorts calls the other one.

After having created the player object, playing, pausing and playing from a time point in the data is as easy as using these methods:

```
-(void)play;
-(void)stop;
-(void)seekToTime:(NSTimeInterval)time;
```


### Audio Recording

The CinchAudioRecorder takes the same audio format argument as the player, but it instead of a data source requires a data handler to handle the incoming data from the recording device (iPhone mic):

``` 
@optional
-(void)cinchAudioRecorder:(nonnull CinchAudioRecorder*)cinchAudioRecorder didReceiveInt16Data:(nonnull NSData*)data;
-(void)cinchAudioRecorder:(nonnull CinchAudioRecorder*)cinchAudioRecorder didReceiveFloatData:(nonnull NSData*)data;
```

Again, which method is called depends on whether floats or int16 are used in the audio format.

Starting and stopping recording is done by using the following methods:
```
-(void)startRecording;
-(void)stopRecording;
```

### NSData Categories

Since we're using NSData for all callbacks instead of dealing directly with raw types (float* or SInt16*) there are some useful categories on NSData to allow easier conversion and convenience. NSData+PCM provides these methods:

```
-(NSInteger)PCMInt16Length;
-(NSInteger)PCMFloatLength;
-(NSData*)pcmInt16SubDataWithSamplesRange:(NSRange)range;
-(NSData*)pcmFloatSubDataWithSamplesRange:(NSRange)range;
```

Hopefully they're fairly self-explanatory, but the length returns the length of samples given the type of data we're using for samples. The subdata gives the subdata for the sample range rather than the byte range.

NSMutableData+PCM provides these methods:

```
-(void)appendPCMFloat:(float)pcmFloat;
-(void)appendPCMInt16:(SInt16)pcmInt16;
```

for conveniently adding a PCM int16 or float to a mutable data object. 



## Development

If you'd like to change anything, please do submit a pull request!
