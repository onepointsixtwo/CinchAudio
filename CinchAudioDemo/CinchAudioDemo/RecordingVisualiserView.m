//
//  RecordingVisualiserView.m
//  CinchAudioDemo
//
//  Created by John Kartupelis on 01/11/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "RecordingVisualiserView.h"

const NSInteger maxLength = 1200;

@interface RecordingVisualiserView () {
    CADisplayLink* displayLink;
}

@property (strong, nonatomic) NSMutableArray<NSNumber*>* points;

@end


@implementation RecordingVisualiserView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor blackColor] setStroke];
    
    CGFloat pointDistance = rect.size.width / self.points.count;
    CGFloat maxHeight = rect.size.height / 2.f;
    
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path setLineWidth:2.f];
    [path moveToPoint:CGPointMake(0.f, maxHeight)];
    CGFloat x = 0.f;
    NSArray<NSNumber*>* p = nil;
    @synchronized(self.points) {
        p = self.points.copy;
    }
    for(NSNumber* point in p) {
        float y = maxHeight + (point.floatValue * maxHeight);
        [path addLineToPoint:CGPointMake(x, y)];
        x+=pointDistance;
    }
    
    [path stroke];
}

-(IBAction)redraw:(id)sender {
    [self setNeedsDisplay];
}

-(void)start {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)stop {
    [displayLink invalidate];
    displayLink = nil;
}

-(void)addFloats:(NSArray<NSNumber *> *)floats {
    @synchronized(self.points) {
        [self.points addObjectsFromArray:floats];
        NSInteger diff = self.points.count - maxLength;
        if(diff > 0) {
            self.points = [[self.points subarrayWithRange:NSMakeRange(diff, self.points.count - diff)] mutableCopy];
        }
    }
}

-(void)clear {
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(int x = 0; x < maxLength; x++) {
        [arr addObject:@(0)];
    }
    @synchronized(self.points) {
        self.points = arr;
    }
    [self setNeedsDisplay];
}

@end
