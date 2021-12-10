//
//  GlkWindowController.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 18/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import "GlkWindowController.h"
#import <GlkSound/GlkSound.h>


@implementation GlkWindowController {
	GlkSoundHandler *soundHandler;
}

#pragma mark - Initialisation

- (id) init {
	self = [super initWithWindowNibName: @"CocoaGlk"];
	
	if (self) {
		soundHandler = [[GlkSoundHandler alloc] init];
	}
	
	return self;
}

- (void) windowDidLoad {
	// Set the auto save name
	[self setWindowFrameAutosaveName: @"CocoaGlkWindow"];
	
	// Set the status
	[status setStringValue: [[NSBundle mainBundle] localizedStringForKey: @"Waiting for game..."
																   value: @"Waiting for game..."
																   table: nil]];
	
	// set up sound handling.
	glkView.soundHandler = soundHandler;
	soundHandler.glkctl = glkView;
	
	// We're the view delegate
	[glkView setDelegate: self];
}

#pragma mark - The Glk view

- (GlkView*) glkView {
	[self window];				// Ensures the window is loaded
	
	return glkView;
}

#pragma mark - GlkView delegate methods

- (void) taskHasStarted {
	[self showStatusText: @"Running..."];
}

- (void) taskHasFinished {
	[self showStatusText: @"Finished"];
}

- (void) showStatusText: (NSString*) text {
	[status setStringValue: text];
}

@end
