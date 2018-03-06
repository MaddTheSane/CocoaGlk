//
//  GlkGraphicsWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 20/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkWindow.h>

@interface GlkGraphicsWindow : GlkWindow {
	/// The image buffer for this window
	NSImage* windowImage;
	/// The background colour for this window
	NSColor* backgroundColour;
}

// Drawing in the graphics window
/// Fills in an area in a solid colour
- (void) fillRect: (NSRect) rect
	   withColour: (NSColor*) col;
/// Sets the background colour of the window to the specified colour
- (void) setBackgroundColour: (NSColor*) col;
/// Draws an image, scaled to the given rectangle
- (void) drawImage: (NSImage*) img
			inRect: (NSRect) imgRect;

@end
