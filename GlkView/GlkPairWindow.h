//
//  GlkPairWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 19/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkWindow.h>

///
/// Representation of a Glk pair window
///
@interface GlkPairWindow : GlkWindow {
	// = GLK settings
	
	// The two windows that make up the pair
	/// The key window is used to determine the size of this window (when fixed)
	GlkWindow* key;
	/// Left window is the 'original' window when splitting
	GlkWindow* left;
	/// Right window is the 'new' window when splitting
	GlkWindow* right;
	
	/// The size of the window
	unsigned size;
	
	// Arrangement options
	/// Proportional arrangement if \c NO
	BOOL fixed;
	/// Vertical arrangement if \c NO
	BOOL horizontal;
	/// \c NO if left is above/left of right, \c YES otherwise
	BOOL above;
	
	// = Custom settings
	/// Width of the border
	float borderWidth;
	/// \c YES if the border should only be drawn around windows that have requested input
	BOOL inputBorder;
	
	/// True if something has changed to require the windows to be layed out again
	BOOL needsLayout;
	/// The border sliver
	NSRect borderSliver;
}

// Setting the windows that make up this pair
- (void) setKeyWindow: (GlkWindow*) newKey;
- (void) setLeftWindow: (GlkWindow*) newLeft;
- (void) setRightWindow: (GlkWindow*) newRight;

@property (nonatomic, retain) GlkWindow *keyWindow;
@property (nonatomic, readonly, assign) GlkWindow *nonKeyWindow;
@property (nonatomic, retain) GlkWindow *leftWindow;
@property (nonatomic, retain) GlkWindow *rightWindow;

// Size and arrangement
- (void) setSize: (unsigned) newSize;
/// Proportional arrangement if \c NO
- (void) setFixed: (BOOL) newFixed;
/// Vertical arrangement if \c NO
- (void) setHorizontal: (BOOL) newHorizontal;
/// \c NO if left is above/left of right, \c YES otherwise
- (void) setAbove: (BOOL) newAbove;

@property (nonatomic, readwrite) unsigned size;
@property (nonatomic, readwrite) BOOL fixed;
@property (nonatomic, readwrite) BOOL horizontal;
@property (readwrite) BOOL above;

// Custom settings
/// Width of the divider between windows (not drawn if < 2)
@property (nonatomic) float borderWidth;
/// Set to \c YES to only draw the border if input is requested
@property (nonatomic) BOOL inputBorder;

@end
