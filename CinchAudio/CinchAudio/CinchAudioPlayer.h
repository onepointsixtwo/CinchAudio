//
//  CinchAudioPlayer.h
//  CinchAudio
//
//  Created by John Kartupelis on 28/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinchAudioDataSource.h"
#import "CinchAudioFormat.h"
@class CinchAudioPlayer;
@import AVFoundation;
@import AudioToolbox;


@protocol CinchAudioPlayerDelegate <NSObject>

-(void)cinchAudioPlayerDidCompletePlayback:(nonnull CinchAudioPlayer*)cinchAudioPlayer;

@end


@interface CinchAudioPlayer : NSObject

@property (nonatomic, readonly) NSTimeInterval totalPlaybackTime;
@property (nonatomic, readonly) AudioStreamBasicDescription audioStreamDescription;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioDataSource> dataSource;
@property (nonatomic, strong, readonly) _Nonnull id<CinchAudioFormat> audioFormat;
@property (nonatomic, weak) _Nullable id<CinchAudioPlayerDelegate> delegate;

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithDataSource:(nonnull id<CinchAudioDataSource>)dataSource audioFormat:(nonnull id<CinchAudioFormat>)audioFormat NS_DESIGNATED_INITIALIZER;
-(void)play;
-(void)stop;
-(void)seekToTime:(NSTimeInterval)time;

@end
