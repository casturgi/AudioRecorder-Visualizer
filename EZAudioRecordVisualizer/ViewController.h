//
//  ViewController.h
//  EZAudioRecordVisualizer
//
//  Created by cory Sturgis on 2/19/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "EZAudio/EZAudio.h"
//#define kAudioFilePath @"test.m4a"

@interface ViewController : UIViewController <EZAudioPlayerDelegate, EZMicrophoneDelegate, EZRecorderDelegate>

@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;

@property (nonatomic, weak) IBOutlet EZAudioPlotGL *recordingAudioPlot;
@property (nonatomic, weak) IBOutlet EZAudioPlot *playingAudioPlot;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UITextField *recordingNameTextField;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSURL *recordingURL;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZRecorder *recorder;

- (IBAction)onSaveButtonTapped:(id)sender;
- (IBAction)playFile:(id)sender;
- (IBAction)toggleRecording:(UIButton *)sender;


@end

