//
//  GlkView.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 16/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkSessionProtocol.h>
#import <GlkView/GlkWindow.h>
#import <GlkView/GlkEvent.h>
#import <GlkView/GlkPreferences.h>
#import <GlkView/GlkStyle.h>

@protocol GlkAutomation;
@protocol GlkViewDelegate;

typedef NS_ENUM(NSInteger, GlkLogStatus) {
	GlkLogRoutine,								//!< Routine log message
	GlkLogInformation,							//!< Informational log message
	GlkLogCustom,								//!< Custom log message (from the game, for example)
	GlkLogWarning,								//!< Warning log message
	GlkLogError,								//!< Error log message
	GlkLogFatalError,							//!< Fatal error log message
};

///
/// Base class for CocoaGlk: a view object that an application can embed in order to run Glk client applications
///
@interface GlkView : NSView<GlkSession, GlkBuffer, GlkEventReceiver> {
	// Windows
	NSMutableDictionary* glkWindows;							/// Maps identifiers to windows
	NSSavePanel* lastPanel;										/// Most recent save panel
	GlkWindow* rootWindow;										/// The root window
	GlkWindow* lastRootWindow;									/// The last root window
	
	BOOL windowsNeedLayout;										/// Used when flushing the buffer
	BOOL flushing;												/// A buffer is currently flushing if YES
	
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
	NSMutableArray* outputReceivers;
	/// The automation input receiver attached to this view
	NSMutableArray* inputReceivers;
	
	/// The automation window identifier cache
	NSMutableDictionary* windowPositionCache;
	/// The automation window position -> GlkWindow cache
	NSMutableDictionary* windowIdCache;
}

// Some shared settings
/// Image displayed while there is no root window
+ (NSImage*) defaultLogo;

// Setting up for launch
/// If cookie is non-nil, a client application must know the cookie to connect to this view. If nil, this view is first-come, first-served.
- (void) setViewCookie: (NSString*) cookie;
/// As above, but sets a random cookie. Not guaranteed to be cryptographically secure.
- (void) setRandomViewCookie;

// Launching a client application
/// Launches and controls a Glk client application
- (void) launchClientApplication: (NSString*) launchPath
				   withArguments: (NSArray<NSString*>*) appArgs;
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
@property (assign) id<GlkViewDelegate> delegate;

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
- (NSImage*) imageWithIdentifier: (unsigned) imageId;
/// Retrieves a flipped variant of an image with the given identifier (works around a really annoying Cocoa design flaw, at the expense of storing the image twice)
- (NSImage*) flippedImageWithIdentifier: (unsigned) imageId;

// Dealing with line history
/// Adds a line history event to this view
- (void) addHistoryItem: (NSString*) inputLine
		forWindowWithId: (glui32) windowId;
/// Retrieves the previous history item
- (NSString*) previousHistoryItem;
/// Retrieves the next history item
- (NSString*) nextHistoryItem;
/// Causes the history position to move to the end
- (void) resetHistoryPosition;

// Layout
/// Forces a layout operation if it's required
- (void) performLayoutIfNecessary;
/// Sets the scale factor of this view and any subview (resizing fonts, etc)
- (void) setScaleFactor: (float) scale;
/// Sets up the border width for new pair windows
- (void) setBorderWidth: (float) borderWidth;

// Dealing with [ MORE ] prompts
/// YES if this CocoaGlk window should always page on more
- (void) setAlwaysPageOnMore: (BOOL) alwaysPage;
// Ditto
- (BOOL) alwaysPageOnMore;
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

///
/// Functions that a view delegate can provide
///
@protocol GlkViewDelegate <NSObject>
@optional

/// Set to return YES to get rid of the CocoaGlk logo
- (BOOL) disableLogo;
/// If non-nil, then this will be the logo displayed instead of 'CocoaGlk'
- (NSImage*) logo;
/// A description of what is running in this window (or nil)
- (NSString*) taskDescription;

/// Called to show warnings, etc
- (void) showStatusText: (NSString*) status;
/// Called to show errors
- (void) showError: (NSString*) error;
/// Called to show general purpose log messages
- (void) showLogMessage: (NSString*) message
			 withStatus: (GlkLogStatus) status;

/// Called when the Glk task starts
- (void) taskHasStarted;
/// Called when the Glk task finishes (usually, may not be called under some circumstances)
- (void) taskHasFinished;
/// Additionally called when the task crashes
- (void) taskHasCrashed;

/// This works out the 'real' path for a file requested by name (default is to remove control characters and stick it on the Desktop)
- (NSString*) pathForNamedFile: (NSString*) name;
/// This works out the 'preferred' directory for save files. CocoaGlk will use it's own judgement if this returns nil
- (NSString*) preferredSaveDirectory;
/// Called to give the delegate a chance to store the final directory chosen for a save in the preferences.
- (void) savePreferredDirectory: (NSString*) finalDir;

/// The delegate can override this to provide custom saving behaviour for its files. This should return \c YES if the delegate is going to handle the event or \c NO otherwise
- (BOOL) promptForFilesForUsage: (NSString*) usage
					 forWriting: (BOOL) writing
						handler: (NSObject<GlkFilePrompt>*) handler
			 preferredDirectory: (NSString*) preferredDirectory;

@end

#import <GlkView/GlkAutomation.h>
