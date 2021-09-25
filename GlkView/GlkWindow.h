//
//  GlkWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 19/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <GlkView/GlkViewDefinitions.h>
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import <GlkView/GlkStreamProtocol.h>
#import <GlkView/GlkSessionProtocol.h>

#import <GlkView/GlkEvent.h>
#import <GlkView/GlkPreferences.h>
#import <GlkView/GlkStyle.h>

@class GlkPairWindow;
@class GlkView;

///
/// Class that represents a Glk window
///
@interface GlkWindow : GlkSuperView<GlkStream> {
	/// The pair window that contains this window (or NULL for the root window) !NOT RETAINED!
	GlkPairWindow* parentWindow;
	
	/// YES if this window is closed
	BOOL closed;
	/// The window's unique identifier number (shared with the client)
	unsigned windowIdentifier;
	
	/// Active stream style
	int style;
	/// Whether or not we should always use fixed-pitch and size fonts
	BOOL forceFixed;
	
	/// Border
	CGFloat border;
	// The scale factor to use
	CGFloat scaleFactor;
	
	// Styles
	GlkPreferences* preferences;								// Preferences defines things like fonts
	NSDictionary* styles;										// Maps style numbers to GlkStyle objects
	GlkStyle* immediateStyle;									// The immediate style as set by the user
	NSDictionary* customAttributes;								// The custom attributes to merge with the current style
	
	// Hyperlinks
	NSObject* linkObject;										// Object defining the current hyperlink
	
	// These event variables are useful to subclasses
	/// Where the events go !NOT RETAINED!
	NSObject<GlkEventReceiver>* target;
	/// YES if we're receiving character input
	BOOL charInput;
	/// YES if we're receiving text input
	BOOL lineInput;
	/// YES if we're receiving mouse input
	BOOL mouseInput;
	/// YES if we're receiving hyperlink input
	BOOL hyperlinkInput;
	
	/// The view that contains this window !NOT RETAINED!
	GlkView* containingView;
	
	/// The last known size of this window
	GlkSize lastSize;
}

/// Given a string from a keyboard event, returns the associated Glk keycode
+ (unsigned) keycodeForString: (NSString*) string;
#if !defined(COCOAGLK_IPHONE)
/// Given a keyboard event, produces the associated Glk keycode
+ (unsigned) keycodeForEvent: (NSEvent*) evt;
#endif

// Closed windows can hang around
@property BOOL closed;

// Window metadata
/// The unique window identifier, (shared with and assigned by the client)
/// Sometimes we need to know this
@property unsigned glkIdentifier;

// Layout
/// If the layout has changed, then update/redraw this window
- (void) layoutInRect: (GlkRect) parentRect;
/// Meaning depends on the window format. Returns the preferred size in pixels
- (CGFloat) widthForFixedSize: (unsigned) size;
/// Meaning depends on the window format. Returns the preferred size in pixels
- (CGFloat) heightForFixedSize: (unsigned) size;

/// The border around the window's contents
@property CGFloat border;

/// Size of the content, taking the border into account
@property (readonly) GlkRect contentRect;
/// Size in window units
@property (readonly) GlkSize glkSize;

/// Sets the scale factor for this window
@property CGFloat scaleFactor;

// Styles
/// Whether or not we're currently forcing fixed fonts
@property BOOL forceFixed;

/// Maps style numbers to GlkStyles
- (void) setStyles: (NSDictionary<NSNumber*,GlkStyle*>*) styles;
/// Retrieves a specific style
- (GlkStyle*) style: (unsigned) style;
/// Gets the attributes to use for a specific style
- (NSDictionary<NSAttributedStringKey, id>*) attributes: (unsigned) style;

/// Sets a style hint with immediate effect (glk extension)
- (void) setImmediateStyleHint: (glui32) hint
					   toValue: (glsi32) value;
/// Clears a style hint with immediate effect (glk extension)
- (void) clearImmediateStyleHint: (glui32) hint;
/// Sets some custom attributes to merge with those from the current style
- (void) setCustomAttributes: (NSDictionary*) customAttributes;

/// Sets the \c GlkPreferences object to use for fonts.
- (void) setPreferences: (GlkPreferences*) prefs;
/// Force a reformat of this window (call when the preferences change, for example)
- (void) reformat;

/// The base proportional font we're using
- (GlkFont*) proportionalFont;
/// The base fixed-pitch font we're using
- (GlkFont*) fixedFont;

/// The background colour for this window
- (GlkColor*) backgroundColour;

/// The amount of leading to use
@property (readonly) CGFloat leading;
/// Height of a line in the current font
@property (readonly) CGFloat lineHeight;

/// The attributes for the currently active style
- (NSDictionary<NSAttributedStringKey, id>*) currentTextAttributes;

// Cursor positioning
/// Not supported for most window styles
- (void) moveCursorToXposition: (int) xpos
					 yPosition: (int) ypos;

// Window control
/// Does whatever is appropriate for the window type
- (void) clearWindow;

/// Sets the target for any events this window generates !NOT RETAINED!
@property (assign) NSObject<GlkEventReceiver>* eventTarget;

- (void) requestCharInput;
/// Request that the window generate the appropriate events
- (void) requestLineInput;
- (void) requestMouseInput;
- (void) requestHyperlinkInput;

- (void) cancelCharInput;
/// Request that the window stop generating these events
- (NSString*) cancelLineInput;
- (void) cancelMouseInput;
- (void) cancelHyperlinkInput;

/// Sets the input text to a given pre-defined value
- (void) setInputLine: (NSString*) inputLine;
/// Forces this window to act on the specified input string as if it had been entered by the user
- (void) forceLineInput: (NSString*) forcedInput;

/// Returns YES if this window is waiting for line input
- (BOOL) waitingForLineInput;
/// Returns YES if this window is waiting for character input
- (BOOL) waitingForCharInput;
/// Returns YES if this window is waiting for keyboard input
- (BOOL) waitingForKeyboardInput;
/// Returns YES if this window is waiting for keyboard input for user interaction with the running story
- (BOOL) waitingForUserKeyboardInput;
#if !defined(COCOAGLK_IPHONE)
/// The control that responds to events for this window
- (NSResponder*) windowResponder;
#endif

/// Called just before the buffer flushes (mostly used to tell the text windows to wait before performing layout)
- (void) bufferIsFlushing;
/// Called once the buffer has finished flushing
- (void) bufferHasFlushed;

/// The text position beyond which input is possible
@property (nonatomic, readonly) NSInteger inputPos;
/// Called on a key down event, to give this view a chance to set the caret position appropriately
- (void) updateCaretPosition;

/// If YES, then this view is showing a [ MORE ] prompt and may need paging
@property (readonly) BOOL needsPaging;
/// Perform paging
- (void) page;

/// Select has been called: make the cancelled/requested state 'fixed'
- (void) fixInputStatus;

/// The glk task has finished: tidy up time
- (void) taskFinished;

// The parent window
/// Sets the parent window !NOT RETAINED!
@property (nonatomic, assign) GlkPairWindow *parent;

// The containing view
/// The GlkView that contains this window !NOT RETAINED!
@property (nonatomic, assign) GlkView *containingView;

@end

#import <GlkView/GlkPairWindow.h>
#import <GlkView/GlkView.h>
