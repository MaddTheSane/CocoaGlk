//
//  GlkTextWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 20/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkWindow.h>
#import <GlkView/GlkTextView.h>
#import <GlkView/GlkTypesetter.h>

@interface GlkTextWindow : GlkWindow {
	/// The scroller for the text view
	NSScrollView* scrollView;
	/// The inner text view
	GlkTextView* textView;
	/// The typesetter we should use for laying out images and other Glk-specific things
	GlkTypesetter* typesetter;
	/// The layout manager
	NSLayoutManager* layoutManager;
	/// The text storage
	NSTextStorage* textStorage;
	
	/// The position in the text view that the game-supplied text ends, and the user-supplied text begins
	int inputPos;
	/// The size of the margin for this window
	float margin;
	
	/// The input data
	NSMutableString* inputBuffer;
	
	/// \c YES if the buffer is flushing
	BOOL flushing;
	
	/// \c YES if a request to make the text editable is pending
	BOOL willMakeEditable;
	/// \c YES if a request to make the text non-editable is pending
	BOOL willMakeNonEditable;
	
	/// \c YES if this window has a more prompt
	BOOL hasMorePrompt;
	/// The character that should be the first on the current 'page'
	int moreOffset;
	/// The last y position a [ MORE ] prompt appeared
	float lastMorePos;
	/// The y position that the next [ MORE ] prompt should appear at
	float nextMorePos;
	
	/// The window containing the [ MORE ] prompt
	NSWindow* moreWindow;
	/// The time that the [ MORE ] prompt was shown
	NSDate* whenMoreShown;
	/// Initial state of the [ MORE ] prompt
	float lastMoreState;
	/// Final state fo the [ MORE ] prompt
	float finalMoreState;
	/// Timer for the [ MORE ] animation
	NSTimer* moreAnimationTimer;
}

/// Initialise the text view and typesetters
- (void) setupTextview;

/// Adds an image at the end of this view
- (void) addImage: (NSImage*) image
	withAlignment: (unsigned) alignment
			 size: (NSSize) sz;
/// Adds a flow break at the end of this view
- (void) addFlowBreak;

/// Requests that the text buffer view be made editable (ie, ready for command input), takes account of buffering issues
- (void) makeTextEditable;
/// Requests that the text buffer view be made non-editable, takes account of buffering issues
- (void) makeTextNonEditable;

/// Sets whether or not a [ MORE ] prompt should be displayed for this window
- (void) setUsesMorePrompt: (BOOL) useMorePrompt;
/// Sets this window to be infinite size
- (void) setInfiniteSize;
/// The current [ MORE ] animation state (0 = hidden, 1 = shown)
@property (nonatomic, readonly) float currentMoreState;
/// A request to display the [ MORE ] prompt if necessary
- (void) displayMorePromptIfNecessary;
/// Sets whether or not the [ MORE ] prompt is shown
- (void) setMoreShown: (BOOL) shown;
/// Resets the [ MORE ] prompt position from the specified character position
- (void) resetMorePrompt: (int) pos
				  paging: (BOOL) paging;
/// Resets the [ MORE ] prompt position from the current input position
- (void) resetMorePrompt;
/// Scroll to the end of the text view
- (void) scrollToEnd;

@end
