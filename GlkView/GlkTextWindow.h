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

@interface GlkTextWindow : GlkWindow<NSTextStorageDelegate, NSTextViewDelegate> {
	NSScrollView* scrollView;							// The scroller for the text view
	GlkTextView* textView;								// The inner text view
	GlkTypesetter* typesetter;							// The typesetter we should use for laying out images and other Glk-specific things
	NSLayoutManager* layoutManager;						// The layout manager
	NSTextStorage* textStorage;							// The text storage
	
	NSInteger inputPos;									// The position in the text view that the game-supplied text ends, and the user-supplied text begins
	CGFloat margin;										// The size of the margin for this window
	
	NSMutableString* inputBuffer;						// The input data
	
	BOOL flushing;										// YES if the buffer is flushing
	
	BOOL willMakeEditable;								// YES if a request to make the text editable is pending
	BOOL willMakeNonEditable;							// YES if a request to make the text non-editable is pending
	
	BOOL hasMorePrompt;									// YES if this window has a more prompt
	NSInteger moreOffset;								// The character that should be the first on the current 'page'
	CGFloat lastMorePos;								// The last y position a [ MORE ] prompt appeared
	CGFloat nextMorePos;								// The y position that the next [ MORE ] prompt should appear at
	
	NSWindow* moreWindow;								// The window containing the [ MORE ] prompt
	NSDate* whenMoreShown;								// The time that the [ MORE ] prompt was shown
	CGFloat lastMoreState;								// Initial state of the [ MORE ] prompt
	CGFloat finalMoreState;								// Final state fo the [ MORE ] prompt
	NSTimer* moreAnimationTimer;						// Timer for the [ MORE ] animation
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
- (CGFloat) currentMoreState;
/// A request to display the [ MORE ] prompt if necessary
- (void) displayMorePromptIfNecessary;
/// Sets whether or not the [ MORE ] prompt is shown
- (void) setMoreShown: (BOOL) shown;
/// Resets the [ MORE ] prompt position from the specified character position
- (void) resetMorePrompt: (NSInteger) pos
				  paging: (BOOL) paging;
/// Resets the [ MORE ] prompt position from the current input position
- (void) resetMorePrompt;
/// Scroll to the end of the text view
- (void) scrollToEnd;

@end
