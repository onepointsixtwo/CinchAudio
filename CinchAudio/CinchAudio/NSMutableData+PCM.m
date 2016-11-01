//
//  NSMutableData+PCM.m
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "NSMutableData+PCM.h"

@implementation NSMutableData (PCM)

-(void)appendPCMFloat:(float)pcmFloat {
    [self appendBytes:&pcmFloat length:sizeof(float)];
}

-(void)appendPCMInt16:(SInt16)pcmInt16 {
    [self appendBytes:&pcmInt16 length:sizeof(SInt16)];
}

@end
