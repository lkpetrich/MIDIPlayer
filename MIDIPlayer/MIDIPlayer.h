//
//  Player.h
//  MIDIPlayer
//
//  Created by Loren Petrich on 12/19/18.
//  Copyright © 2018 Loren Petrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MIDIPlayer : NSDocument <NSWindowDelegate> {
    IBOutlet NSTextField *FileSize, *PlayTime, *CurrTime;
    IBOutlet NSButton *PlayButton;
    IBOutlet NSProgressIndicator *ProgressBar;
}

- (IBAction)TogglePlaying:(id)sender;

- (IBAction)Rewind:(id)sender;

@end
