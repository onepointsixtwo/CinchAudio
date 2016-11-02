//
//  RecordingDemoViewController.m
//  CinchAudioDemo
//
//  Created by John Kartupelis on 31/10/2016.
//  Copyright © 2016 onepointsixtwo. All rights reserved.
//

#import "RecordingDemoViewController.h"
#import <CinchAudio/CinchAudio.h>
#import "RecordingVisualiserView.h"
@import AVFoundation;

@interface RecordingDemoViewController ()<CinchAudioRecorderDataHandler, CinchAudioFormat> {
    CinchAudioRecorder* audioRecorder;
    BOOL shouldRender;
}

@property (weak, nonatomic) IBOutlet RecordingVisualiserView* renderingView;

@end

@implementation RecordingDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    audioRecorder = [[CinchAudioRecorder alloc] initWithDataHandler:self audioFormat:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.renderingView start];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.renderingView stop];
    shouldRender = FALSE;
    [self.renderingView clear];
}

-(IBAction)startRecording:(id)sender {
    void(^microphonePermissionsCallback)(BOOL) = ^(BOOL granted) {
        //This should really call to a weak version of self, but since this view controller is never deallocated, it doesn't matter.
        if(granted) {
            [audioRecorder startRecording];
            shouldRender = TRUE;
        } else {
            [self showMicrophonePermissionsDenied];
        }
    };
    
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    switch(permission) {
        case AVAudioSessionRecordPermissionDenied:
            [self showMicrophonePermissionsDenied];
            break;
            
        case AVAudioSessionRecordPermissionGranted:
            microphonePermissionsCallback(TRUE);
            break;
            
        case AVAudioSessionRecordPermissionUndetermined:
            [[AVAudioSession sharedInstance] requestRecordPermission:microphonePermissionsCallback];
            break;
    }
}

-(IBAction)stopRecording:(id)sender {
    [audioRecorder stopRecording];
    shouldRender = FALSE;
    [self.renderingView clear];
}

#pragma mark - Helpers
-(void)showMicrophonePermissionsDenied {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Microphone permissions have been denied. Please enable permissions in Settings to continue."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Audio Format
-(CinchAudioFormatType)audioFormatType {
    return CinchAudioFormatType32BitFloat;
}

-(CinchAudioSampleRate)audioSampleRate {
    return CinchAudioSampleRate44100Hz;
}

-(CinchAudioChannelCount)audioChannelCount {
    return CinchAudioMono;
}

#pragma mark - Recording Data Handler
-(void)cinchAudioRecorder:(CinchAudioRecorder *)cinchAudioRecorder didReceiveFloatData:(NSData *)data {
    //Downsample to 1/40th of the original rate
    size_t len = data.length / sizeof(float);
    float* arr = (float*)[data bytes];
    NSMutableArray<NSNumber*>* arrOutput = [[NSMutableArray alloc] init];
    for(int x = 0; x < len; x++) {
        if(x % 20 == 0) {
            [arrOutput addObject:@(arr[x])];
        }
    }
    
    [self performSelectorOnMainThread:@selector(addFloats:) withObject:arrOutput waitUntilDone:FALSE];
}

-(IBAction)addFloats:(NSArray<NSNumber*>*)floats {
    if(shouldRender) {
        [self.renderingView addFloats:floats];
    }
}

@end
