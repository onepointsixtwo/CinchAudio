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


@protocol CinchAudioPlayerDelegate <NSObject>

-(void)cinchAudioPlayerDidCompletePlayback:(CinchAudioPlayer*)cinchAudioPlayer;

@end


@interface CinchAudioPlayer : NSObject

@property (nonatomic, readonly) NSTimeInterval totalPlaybackTime;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDataSource:(id<CinchAudioDataSource>)dataSource audioFormat:(id<CinchAudioFormat>)audioFormat NS_DESIGNATED_INITIALIZER;
-(void)play;
-(void)pause;
-(void)stop;
-(void)seekToTime:(NSTimeInterval)interval;

@end
