//
//  RecordingVisualiserView.h
//  CinchAudioDemo
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingVisualiserView : UIView

-(void)start;
-(void)stop;
-(void)addFloats:(NSArray<NSNumber*>*)floats;
-(void)clear;

@end
