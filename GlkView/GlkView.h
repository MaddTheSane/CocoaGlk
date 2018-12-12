//
//  GlkView.h
//  CocoaGlk
//
//  Created by C.W. Betts on 12/11/18.
//

#ifndef GlkView_h
#define GlkView_h

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

#if defined(COCOAGLK_IPHONE)
#import "GlkView-iOS.h"
#else
#import "GlkView-Mac.h"
#endif

///
/// Functions that a view delegate can provide
///
@protocol GlkViewDelegate <NSObject>
@optional

/// Set to return YES to get rid of the CocoaGlk logo
- (BOOL) disableLogo;
/// If non-nil, then this will be the logo displayed instead of 'CocoaGlk'
- (nullable GlkSuperImage*) logo;
/// A description of what is running in this window (or nil)
- (nullable NSString*) taskDescription;

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
- (nullable NSString*) pathForNamedFile: (NSString*) name;
/// This works out the 'preferred' directory for save files. CocoaGlk will use it's own judgement if this returns nil
- (nullable NSString*) preferredSaveDirectory;
/// Called to give the delegate a chance to store the final directory chosen for a save in the preferences.
- (void) savePreferredDirectory: (nullable NSString*) finalDir;

/// The delegate can override this to provide custom saving behaviour for its files. This should return \c YES if the delegate is going to handle the event or \c NO otherwise
- (BOOL) promptForFilesForUsage: (NSString*) usage
					 forWriting: (BOOL) writing
						handler: (NSObject<GlkFilePrompt>*) handler
			 preferredDirectory: (nullable NSString*) preferredDirectory;

@end

#import <GlkView/GlkAutomation.h>

#endif /* GlkView_h */
