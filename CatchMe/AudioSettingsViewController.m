//
//  AudioSettingsViewController.m
//  CatchMe
//
//  Created by Nicholas Hoekstra on 10/20/12.
//  Copyright (c) 2012 Same Level Software. All rights reserved.
//

// Known bugs: Audio is not saved after exiting and reopening the simulator. This is because the simulator creates a new document folder each time overwriting the previous one. This is not the case on actual iOS devices and therefore shouldn't be a problem.

#import "AudioSettingsViewController.h"
#import "AVFoundation/AVAudioRecorder.h"
#import "AVFoundation/AVAudioPlayer.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

// Audio recording and playback can be done through the use of the AVAudioRecorder and AVAudioPlayer API

@implementation AudioSettingsViewController

@synthesize recordButton, stopButton, playButton, saveButton, defaultButton;

// Actions to occur when the window opens
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Sets buttons to enable/disable
    playButton.enabled = TRUE;
    [playButton setBackgroundColor:[UIColor greenColor]];
    recordButton.enabled = TRUE;
    [recordButton setBackgroundColor:[UIColor greenColor]];
    stopButton.enabled = FALSE;
    [stopButton setBackgroundColor:[UIColor redColor]];
    defaultButton.enabled = TRUE;
    [defaultButton setBackgroundColor:[UIColor greenColor]];
    
    // Load any setting values previously saved
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool audioMessageOn = [defaults boolForKey:@"audioMessageOn"];
    CGFloat messageVolume = [defaults floatForKey:@"messageVolume"];
    NSString *soundFileName = [defaults objectForKey:@"soundFileName"];
     
    // If the audio settings are being opened for the first time
    if (soundFileName == nil) {
        // Copy over system sounds to Documents folder
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *newPath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"default-audio-alert.caf"];
        [filemanager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"default-audio-alert" ofType:@"caf"] toPath:newPath error:nil];
        NSLog(@"oldPath: %@ newPath: %@", [[NSBundle mainBundle] pathForResource:@"default-audio-alert" ofType:@"caf"],newPath);
        newPath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"saved-audio-alert.caf"];
        [filemanager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"saved-audio-alert" ofType:@"caf"] toPath:newPath error:nil];
        NSLog(@"oldPath: %@ newPath: %@", [[NSBundle mainBundle] pathForResource:@"saved-audio-alert" ofType:@"caf"],newPath);
        
        // Set audio to default alert
        soundFileName = @"default-audio-alert.caf";
    }
    
    if (audioMessageOn) {
        [audioMessageStatus setOn:YES];
    }
    
    if (messageVolume != 0) {
        volumeSlider.value = messageVolume;
    }
    
    // Initialize audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    [audioSession setActive:YES error: nil];
    
    // Initialize audio recorder
    
    // Specify recorder file path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fullFilePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"recorded-audio-alert.caf"];
    NSLog(@"Made it here %@", fullFilePath);
    URLtoHoldFile = [NSURL fileURLWithPath:fullFilePath];
    
    NSError *recordError = nil; // will hold any error information that occurs during the recorder initialization
    
    // Recorder settings
    NSDictionary *recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                      [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
                                      [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                      [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                      [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                      nil];
    
    // Create recorder
    aRecorder = [[AVAudioRecorder alloc] initWithURL:URLtoHoldFile settings:recorderSettings error:&recordError];
    
    if (recordError) {
        NSLog(@"There was an error creating the recorder: %@", [recordError localizedDescription]);
    }
    
    [aRecorder prepareToRecord];
    
    // Set the filepath to be the last saved audio clip so that when play is pressed the current saved message plays

    fullFilePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:soundFileName];
    URLtoHoldFile = [NSURL fileURLWithPath:fullFilePath];
    
    NSLog(@"Audio URL: %@", [URLtoHoldFile path]);
    
    // Initialize the audio player
    NSError *audioError = nil; // will hold any error information that occurs during audio initialization
    aPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URLtoHoldFile error:&audioError]; // sets up audio player
    
    if (audioError) {
        NSLog(@"An error occured setting up the audio player: %@", [audioError localizedDescription]);
    }

    aPlayer.volume = volumeSlider.value;
}

// Actions to take place when the window closes
- (void)viewDidUnload
{
    volumeSlider = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Checks to see if the interface is correctly oriented
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Starts recording audio message
- (IBAction)recordSound {
    
    if (!aRecorder.recording) {
        playButton.enabled = FALSE;
        [playButton setBackgroundColor:[UIColor redColor]];
        recordButton.enabled = FALSE;
        [recordButton setBackgroundColor:[UIColor redColor]];
        stopButton.enabled = TRUE;
        [stopButton setBackgroundColor:[UIColor greenColor]];
        defaultButton.enabled = FALSE;
        [defaultButton setBackgroundColor:[UIColor redColor]];
        
        
        URLtoHoldFile = aRecorder.url;
        [aRecorder record];
        NSLog(@"URL USED: %@", [NSString stringWithFormat:@"%@",URLtoHoldFile]);
    }
     
}

// Stops recording audio message || stops playing audio message
- (IBAction)stopSound {
    
    playButton.enabled = TRUE;
    [playButton setBackgroundColor:[UIColor greenColor]];
    recordButton.enabled = TRUE;
    [recordButton setBackgroundColor:[UIColor greenColor]];
    stopButton.enabled = FALSE;
    [stopButton setBackgroundColor:[UIColor redColor]];
    defaultButton.enabled = TRUE;
    [defaultButton setBackgroundColor:[UIColor greenColor]];
    
    if (aRecorder.recording) {
        [aRecorder stop];
    }
    else if (aPlayer.playing) {
        [aPlayer stop];
    }
}

// Starts playing audio message
- (IBAction)playSound {
    
    if (!aRecorder.recording) {
        playButton.enabled = FALSE;
        [playButton setBackgroundColor:[UIColor redColor]];
        recordButton.enabled = FALSE;
        [recordButton setBackgroundColor:[UIColor redColor]];
        stopButton.enabled = TRUE;
        [stopButton setBackgroundColor:[UIColor greenColor]];
        defaultButton.enabled = FALSE;
        [defaultButton setBackgroundColor:[UIColor redColor]];
        
        NSError *audioError = nil; // will hold any error information that occurs during audio initialization
        
        NSLog(@"URL USED: %@", [NSString stringWithFormat:@"%@",URLtoHoldFile]);
        
        aPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URLtoHoldFile error:&audioError]; // sets up audio player
        aPlayer.volume = volumeSlider.value;
        
        if (audioError) {
            NSLog(@"An error occured setting up the audio player: %@", [audioError localizedDescription]);
        }
        else {
            //[aPlayer prepareToPlay];
            [aPlayer play];
        }
    }
}

// Use default sound alert when user taps on the "Use Default Audio Message" button
- (IBAction)defaultSound {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fullFilePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"default-audio-alert.caf"];
    URLtoHoldFile = [NSURL fileURLWithPath:fullFilePath];
}

// Saves the audio message
- (IBAction)saveSound {
    // Save the recorded sound
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    NSString *soundFileName;
    NSError *savingError;
    
    // Used for comparisons below
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSURL *defaultURL = [NSURL fileURLWithPath:[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"default-audio-alert.caf"]];
    NSURL *recordedURL = [NSURL fileURLWithPath:[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"recorded-audio-alert.caf"]];
    NSURL *savedURL = [NSURL fileURLWithPath:[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"saved-audio-alert.caf"]];
    
    if ([[URLtoHoldFile path] isEqual:[defaultURL path]]) {
        // Set the recorded audio to the default
        soundFileName = @"default-audio-alert.caf";
    }
    else if ([[URLtoHoldFile path] isEqual:[recordedURL path]]) {
        NSLog(@"We got here!!!");
        // Remove the previously saved file
        [filemanager  removeItemAtPath:[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"saved-audio-alert.caf"] error:&savingError];
        
        // Get new saved file path
        NSString *newPath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"saved-audio-alert.caf"];
        
        // Copy recorded-audio-alert over to the new saved-audio-alert path
        [filemanager copyItemAtPath:[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"recorded-audio-alert.caf"]
                             toPath:newPath error:&savingError];
        
        soundFileName = @"saved-audio-alert.caf";
    }
    else if ([[URLtoHoldFile path] isEqual:[savedURL path]]) {
        // No changes to the recording were made
        soundFileName = @"saved-audio-alert.caf";
    }
    else {
        NSLog(@"There was an error in saving the correct file.");
    }
    
    // Store data in user default settings
    bool audioMessageOn = [audioMessageStatus isOn];
    CGFloat messageVolume = volumeSlider.value;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:audioMessageOn forKey:@"audioMessageOn"];
    [defaults setFloat:messageVolume forKey:@"messageVolume"];
    [defaults setObject:soundFileName forKey:@"soundFileName"];
    
    [self dismissModalViewControllerAnimated:YES];
}

// Changes playback volume in Audio Settings
- (IBAction)changeVolume {
    aPlayer.volume = volumeSlider.value;
}

// Discard any changes and go back to the Settings Menu
- (IBAction)cancelChanges {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Error decoding the audio file: %@\n", error);
}


@end
