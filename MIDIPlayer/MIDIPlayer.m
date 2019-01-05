//
//  Player
//  MIDIPlayer
//
//  Created by Loren Petrich on 12/19/18.
//  Copyright © 2018 Loren Petrich. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MIDIPlayer.h"

// Do the hour-minute-second formatting by hand,
// since the date-formatter objects don't do it very well
// The separator separates the h-m-s value and the raw floating-point value
static NSString *MakeFormattedTime(double TimeVal, NSString *Separator) {
    int sec = (int)TimeVal;
    int min = sec/60;
    int hr = min/60;
    sec -= 60*min;
    min -= 60*hr;
    return [NSString stringWithFormat:@"%dh %dm %ds%@%lf s", hr, min, sec, Separator, TimeVal];
}

@interface MIDIPlayer () {
    NSData *Data;
    AVMIDIPlayer *Player;
    NSTimer *Timer;
}

@end

@implementation MIDIPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        Data = nil;
        Player = nil;
        Timer = nil;
    }
    return self;
}


- (NSString *)windowNibName {
    return @"MIDIPlayer";
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Save the read-in data
    Data = data;
    return YES;
}


- (void)windowControllerDidLoadNib:(NSWindowController *)WC {
    
    // Set up delegation for window closing
    WC.window.delegate = self;
    
    // The size of the file
    // Transmit as a number so that the UI's NSByteCountFormatter object can work on it
    FileSize.objectValue = [NSNumber numberWithLongLong:Data.length];
    
    // Create a player
    NSError *Error;
    Player = [[AVMIDIPlayer alloc] initWithData:Data soundBankURL:nil error:&Error];
    
    // Get from it how long the music is
    double PlayTimeVal = 0;
    if (Player) {
        PlayTimeVal = Player.duration;
        [Player prepareToPlay];
    }
    PlayTime.stringValue = MakeFormattedTime(PlayTimeVal,@" - ");
    
    // Set up the progress bar
    ProgressBar.minValue = 0;
    ProgressBar.maxValue = PlayTimeVal;
    
    // Start the timer - it will be periodic
    Timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self selector:@selector(UpdateDisplay:)
                                           userInfo:nil repeats:YES];
}


- (void)UpdatePlayButton {
    // Just in case we don't have a valid player
    if (!Player) return;
    
    // To make it run on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self->PlayButton.state = self->Player.playing ? NSControlStateValueOn : NSControlStateValueOff;
    });
}

- (void)WhenFinishedPlaying {
    // Just in case we don't have a valid player
    if (!Player) return;
    
    [self UpdatePlayButton];
}


- (IBAction)TogglePlaying:(id)sender {
    // Just in case we don't have a valid player
    if (!Player) return;
    
    if (Player.playing) {
        [Player stop];
    }
    else {
        [Player play:^{[self WhenFinishedPlaying];}];
    }
    [self UpdatePlayButton];
}


- (IBAction)Rewind:(id)sender {
    // Just in case we don't have a valid player
    if (!Player) return;
    
    // Go back to the beginning
    // Do it cleanly by stopping first
    BOOL WasPlaying = Player.playing;
    if (WasPlaying) [Player stop];
    
    Player.currentPosition = 0;
    if (WasPlaying) [Player play:^{[self WhenFinishedPlaying];}];
}


- (void)UpdateDisplay:(NSTimer *)Timer {
    // Just in case we don't have a valid player
    if (!Player) return;
    
    // Reset to the beginning if necessary
    if (Player.currentPosition >= Player.duration)
        Player.currentPosition = 0;
    
    // Update the UI widgets
    double CurrTimeVal = Player.currentPosition;
    CurrTime.stringValue = MakeFormattedTime(CurrTimeVal,@"\n");
    ProgressBar.doubleValue = CurrTimeVal;
}


// This object is a delegate of its window,
// and as a delegate, it receives window-close events
- (BOOL)windowShouldClose:(NSWindow *)sender {
    
    // So it doesn't continue after the window gets closed
    if (Player) [Player stop];
    
    // Don't bother with a close dialog
    return YES;
}

@end
