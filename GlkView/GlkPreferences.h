//
//  GlkPreferences.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 29/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// Notification sent whenever the preferences are changed (not necessarily sent immediately)
extern NSString* GlkPreferencesHaveChangedNotification;

@class GlkStyle;

///
/// General preferences used for a Glk view
///
@interface GlkPreferences : NSObject<NSCopying> {
	// The fonts
	NSFont* proportionalFont;
	NSFont* fixedFont;
	
	// The standard styles
	NSMutableDictionary* styles;
	
	// Typography
	float textMargin;
	BOOL useScreenFonts;
	BOOL useHyphenation;
	BOOL kerning;
	BOOL ligatures;
	
	// Misc bits
	float scrollbackLength;
	
	/// YES if the last change is being notified
	BOOL changeNotified;
	/// Number of changes
	int  changeCount;
}

/// The shared preferences object (these are automagically stored in the user defaults)
@property (class, readonly, retain) GlkPreferences *sharedPreferences;

// Preferences and the user defaults
/// Used to load the preferences from a defaults file
- (void) setPreferencesFromDefaults: (NSDictionary*) defaults;
/// These preferences in a format suitable for the user defaults file
- (NSDictionary*) preferenceDefaults;

// The preferences themselves

// Font preferences
/// The font used for proportional text
- (void) setProportionalFont: (NSFont*) propFont;
/// The font used for fixed-pitch text
- (void) setFixedFont: (NSFont*) fixedFont;

@property (nonatomic, copy) NSFont *proportionalFont;
@property (nonatomic, copy) NSFont *fixedFont;

/// Replaces the current fonts with ones of the given size
- (void) setFontSize: (float) fontSize;

// Typography preferences
/// The padding to use in text windows
@property (nonatomic) float textMargin;
/// Whether or not to use screen fonts
@property (nonatomic) BOOL useScreenFonts;
/// Whether or not to use hyphenation
@property (nonatomic) BOOL useHyphenation;
/// Whether or not to display ligatures
@property (nonatomic) BOOL useLigatures;
/// Whether or not to use kerning
@property (nonatomic) BOOL useKerning;
/// Replaces the current padding that we should use
- (void) setTextMargin: (float) margin;

// Style preferences
/// Dictionary mapping NSNumbers with Glk styles to GlkStyle objects
- (void) setStyles: (NSDictionary*) styles;
/// Sets a style for a specific Glk hint
- (void) setStyle: (GlkStyle*) style
		  forHint: (unsigned) glkHint;

/// The style dictionary
@property (nonatomic, copy) NSDictionary *styles;
// Misc preferences
/// The amount of scrollback to support in text windows (0-100)
@property (nonatomic) float scrollbackLength;

/// Sets the amount of scrollback to retain
- (void) setScrollbackLength: (float) length;

// Changes
/// Number of changes that have occured on this preference object
@property (readonly) int changeCount;

@end

#import <GlkView/GlkStyle.h>
