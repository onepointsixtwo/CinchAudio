//
//  NSData+PCM.h
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (PCM)

-(NSInteger)PCMInt16Length;
-(NSInteger)PCMFloatLength;
-(NSData*)pcmInt16SubDataWithSamplesRange:(NSRange)range;
-(NSData*)pcmFloatSubDataWithSamplesRange:(NSRange)range;

@end
