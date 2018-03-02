//
//  GlkPairWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 19/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkWindow.h>

//
// Representation of a Glk pair window
//
@interface GlkPairWindow : GlkWindow {
	// = GLK settings
	
	// The two windows that make up the pair
	GlkWindow* key;							// The key window is used to determine the size of this window (when fixed)
	GlkWindow* left;						// Left window is the 'original' window when splitting
	GlkWindow* right;						// Right window is the 'new' window when splitting
	
	// The size of the window
	unsigned size;
	
	// Arrangement options
	BOOL fixed;								// Proportional arrangement if NO
	BOOL horizontal;						// Vertical arrangement if NO
	BOOL above;								// NO if left is above/left of right, YES otherwise
	
	// = Custom settings
	float borderWidth;						// Width of the border
	BOOL inputBorder;						// YES if the border should only be drawn around windows that have requested input
	
	BOOL needsLayout;						// True if something has changed to require the windows to be layed out again
	NSRect borderSliver;					// The border sliver
}

// Setting the windows that make up this pair
@property (nonatomic, retain) GlkWindow *keyWindow;
@property (nonatomic, readonly, retain) GlkWindow *nonKeyWindow;
@property (nonatomic, retain) GlkWindow *leftWindow;
@property (nonatomic, retain) GlkWindow *rightWindow;

// Size and arrangement
@property (nonatomic) unsigned size;
//! Proportional arrangement if \c NO
@property (nonatomic) BOOL fixed;
//! Vertical arrangement if \c NO
@property (nonatomic) BOOL horizontal;
//! \c NO if left is above/left of right, \c YES otherwise
@property BOOL above;

// Custom settings
- (void) setBorderWidth: (float) borderWidth;					// Width of the divider between windows (not drawn if < 2)
- (void) setInputBorder: (BOOL) inputBorder;					// Set to true to only draw the border if input is requested

@end
