//
//  NSData+PCM.m
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "NSData+PCM.h"

@implementation NSData (PCM)

-(NSInteger)PCMInt16Length {
    return self.length / sizeof(SInt16);
}

-(NSInteger)PCMFloatLength {
    return self.length / sizeof(float);
}

-(NSData*)pcmInt16SubDataWithSamplesRange:(NSRange)range {
    return [self subdataWithRange:NSMakeRange(range.location * sizeof(SInt16), range.length * sizeof(SInt16))];
}

-(NSData*)pcmFloatSubDataWithSamplesRange:(NSRange)range {
    return [self subdataWithRange:NSMakeRange(range.location * sizeof(float), range.length * sizeof(float))];
}

@end
