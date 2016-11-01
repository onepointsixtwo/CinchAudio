//
//  NSMutableData+PCM.h
//  CinchAudio
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (PCM)

-(void)appendPCMFloat:(float)pcmFloat;
-(void)appendPCMInt16:(SInt16)pcmInt16;

@end
