//
//  GlkView.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 16/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import "GlkViewDefinitions.h"
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import <GlkView/GlkSessionProtocol.h>
#import <GlkView/GlkWindow.h>
#import <GlkView/GlkEvent.h>
#import <GlkView/GlkPreferences.h>
#import <GlkView/GlkStyle.h>

NS_ASSUME_NONNULL_BEGIN

///
/// Base class for CocoaGlk: a view object that an application can embed in order to run Glk client applications
///
@interface GlkView : NSView<GlkSession, GlkBuffer, GlkEventReceiver> {
	// Windows
	/// Maps identifiers to windows
	NSMutableDictionary* glkWindows;
	/// Most recent save panel
	NSSavePanel* lastPanel;
	/// The root window
	GlkWindow* rootWindow;
	/// The last root window
	GlkWindow* lastRootWindow;
	
	/// Used when flushing the buffer
	BOOL windowsNeedLayout;
	/// A buffer is currently flushing if YES
	BOOL flushing;
	
	// Styles
	/// Active preferences
	GlkPreferences* prefs;
	/// Active styles
	NSMutableDictionary<NSNumber*,NSMutableDictionary*>* styles;
	/// The active scale factor
	CGFloat scaleFactor;
	/// The border width to set for new pair windows
	int borderWidth;
	
	// Streams
	/// Maps identifiers to streams
	NSMutableDictionary* glkStreams;

	/// The input stream
	NSObject<GlkStream>* inputStream;
	/// Maps keys to extra input streams
	NSMutableDictionary* extraStreamDictionary;
	/// Used while prompting for a file
	NSObject<GlkFilePrompt>* promptHandler;
	/// Types of files we can show in the panels
	NSArray<NSString*>* allowedFiletypes;
	
	/// YES if windows in this view should automatically page through more prompts
	BOOL alwaysPageOnMore;
	
	// File handling
	/// Dictionary mapping the file usage strings to the list of allowed file types
	NSMutableDictionary* extensionsForUsage;
	
	// Events
	/// The last Arrange event we received
	GlkEvent* arrangeEvent;
	/// The listener for events
	NSObject<GlkEventListener>* listener;
	/// The queue of waiting events
	NSMutableArray* events;
	
	/// The synchronisation counter
	NSInteger syncCount;
	
	// The logo
	/// Used to draw the fading logo
	NSWindow* logoWindow;
	/// The time we started fading the logo
	NSDate* fadeStart;
	/// Used to fade out the logo
	NSTimer* fadeTimer;

	NSTimeInterval waitTime;
	NSTimeInterval fadeTime;
	
	// The task
	/// \c YES if the task is running
	BOOL running;
	/// The session cookie to use with this view
	NSString* viewCookie;
	/// Only used if this is connected as a session via the \c launchClientApplication: method
	NSTask* subtask;
	
	// The delegate
	/// Can respond to certain events if it likes
	id<GlkViewDelegate> delegate;
	
	// Images and graphics
	/// Source of data for images
	NSObject<GlkImageSource>* imgSrc;
	/// Dictionary of images
	NSMutableDictionary* imageDictionary;
	/// Dictionary of flipped images
	NSMutableDictionary* flippedImageDictionary;
	
	// Input history
	/// History of input lines
	NSMutableArray* inputHistory;
	/// Current history position
	NSInteger historyPosition;
	
	// Automation
	/// The automation output receivers attached to this view
	NSMutableArray<id<GlkAutomation>>* outputReceivers;
	/// The automation input receiver attached to this view
	NSMutableArray* inputReceivers;
	
	/// The automation window identifier cache
	NSMutableDictionary* windowPositionCache;
	/// The automation window position -> GlkWindow cache
	NSMutableDictionary* windowIdCache;
}

// Some shared settings
/// Image displayed while there is no root window
@property (class, readonly, retain) NSImage *defaultLogo;

// Setting up for launch
/// If cookie is non-nil, a client application must know the cookie to connect to this view. If nil, this view is first-come, first-served.
@property (nonatomic, copy, nullable) NSString *viewCookie;
/// As above, but sets a random cookie. Not guaranteed to be cryptographically secure.
- (void) setRandomViewCookie;

// Launching a client application
/// Launches and controls a Glk client application
- (void) launchClientApplication: (NSString*) launchPath
				   withArguments: (nullable NSArray<NSString*>*) appArgs;
/// Terminates the client application
- (void) terminateClient;
/// Sets the input stream
- (void) setInputStream: (NSObject<GlkStream>*) stream;
/// Sets the input stream to be input from the given file
- (void) setInputFilename: (NSString*) filename;
/// Adds a keyed stream that the client can obtain if necessary
- (void) addStream: (NSObject<GlkStream>*) stream
		   withKey: (NSString*) streamKey;
/// Adds a keyed stream that reads from the specified filename
- (void) addInputFilename: (NSString*) filename
				  withKey: (NSString*) streamKey;

// Writing log messages
/// If the client supports logging, then tell it to display the specified log message
- (void) logMessage: (NSString*) message
		 withStatus: (GlkLogStatus) status;

// The delegate
/// The delegate for this view. Delegates are not retained.
@property (assign, nullable) id<GlkViewDelegate> delegate;

// Events
/// Note that Arrange events are merged if not yet claimed
- (void) queueEvent: (GlkEvent*) event;
/// Called by views to indicate that their app-side data has gone out of date (eg because they are now a different size)
- (void) requestClientSync;

// Preferences
/// Set before this view has attached to a client for the best effect
@property (retain) GlkPreferences* preferences;
/// Current styles
- (NSMutableDictionary*) stylesForWindowType: (unsigned) type;

// Managing images
/// Retrieves the image with the given identifier, asking the client process if necessary
- (nullable NSImage*) imageWithIdentifier: (unsigned) imageId;
/// Retrieves a flipped variant of an image with the given identifier (works around a really annoying Cocoa design flaw, at the expense of storing the image twice)
- (nullable NSImage*) flippedImageWithIdentifier: (unsigned) imageId;

// Dealing with line history
/// Adds a line history event to this view
- (void) addHistoryItem: (NSString*) inputLine
		forWindowWithId: (glui32) windowId;
/// Retrieves the previous history item
@property (nullable, readonly) NSString *previousHistoryItem;
/// Retrieves the next history item
@property (nullable, readonly) NSString *nextHistoryItem;
/// Causes the history position to move to the end
- (void) resetHistoryPosition;

// Layout
/// Forces a layout operation if it's required
- (void) performLayoutIfNecessary;
/// The scale factor of this view and any subview (resizing fonts, etc)
@property (nonatomic) CGFloat scaleFactor;
/// Sets up the border width for new pair windows
- (void) setBorderWidth: (CGFloat) borderWidth;

// Dealing with [ MORE ] prompts
/// YES if this CocoaGlk window should always page on more
@property BOOL alwaysPageOnMore;
/// True if any windows are waiting on a [ MORE ] prompts
- (BOOL) morePromptsPending;
/// Causes all windows that require it to page forwards (returns NO if no windows actually needed paging)
- (BOOL) pageAll;

// Various UI events
/// Perform a tab action from the specified GlkWindow (ie, changing focus)
- (void) performTabFrom: (GlkWindow*) window
				forward: (BOOL) forward;
/// Tries to set the first responder again
- (BOOL) setFirstResponder;

// Automation
/// Adds an automation object to receive game and user output events
- (void) addOutputReceiver: (NSObject<GlkAutomation>*) receiver;
/// Adds an automation object to receive notifications about when it can sensibly send input to the game (if there is an input receiver, input through the UI is disabled)
- (void) addInputReceiver: (NSObject<GlkAutomation>*) receiver;

/// Removes an automation object from input and/or output duties
- (void) removeAutomationObject: (NSObject<GlkAutomation>*) receiver;

/// Returns true if there are windows waiting for input (ie, a sendCharacters event will succeed)
- (BOOL) canSendInput;
/// Sends the specified characters to the given window number as a line or character input event
- (int) sendCharacters: (NSString*) characters
			  toWindow: (int) window;
/// Sends a mouse click at the specified position to the given window number
- (int) sendClickAtX: (int) xpos
				   Y: (int) ypos
			toWindow: (int) window;

/// Request from a window object to send characters to the automation system
- (void) automateStream: (NSObject<GlkStream>*) stream
			  forString: (NSString*) string;
@end

NS_ASSUME_NONNULL_END
