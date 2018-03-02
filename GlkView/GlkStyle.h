//
//  GlkStyle.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 29/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlkView/glk.h>

extern NSString* GlkStyleAttributeName;									// Styles store themselves in the attributes to facilitate reformating after a change to a preference object

//
// Description of a Glk style, and functions for turning a Glk style into a cocoa style
//
// (Maybe I should split this into a Mutable/Immutable pair)
//

@class GlkPreferences;

@interface GlkStyle : NSObject<NSCopying> {
	// Style attributes
	CGFloat indentation;
	CGFloat paraIndent;
	NSTextAlignment alignment;
	CGFloat size;
	int weight;
	BOOL oblique;
	BOOL proportional;
	NSColor* textColour;
	NSColor* backColour;
	BOOL reversed;
	
	// Caching the attributes
	NSInteger prefChangeCount;											// Change count for the preferences last time we cached the style dictionary
	GlkPreferences*	lastPreferences;									// The last preference object this style was applied to
	CGFloat lastScaleFactor;											// The scale factor the attributes were created at
	NSDictionary* lastAttributes;										// The attributes generated last time we needed to
}

// Creating a style
+ (GlkStyle*) style;													//!< 'Normal' style

// The hints
@property (nonatomic) CGFloat indentation;								//!< Measured in points
@property (nonatomic) CGFloat paraIndentation;							//!< Measured in points
@property (nonatomic) NSTextAlignment justification;					//!< Glk doesn't allow us to support 'Natural' alignment
@property (nonatomic) CGFloat size;										//!< Relative, in points
@property (nonatomic) int weight;										//!< -1 = lighter, 1 = bolder
@property (nonatomic) BOOL oblique;										//!< \c YES if an italic/oblique version of the font should be used (italics are used for preference)
@property (nonatomic) BOOL proportional;								//!< \c NO if fixed-pitch
@property (nonatomic, retain) NSColor* textColour;						//!< Foreground text colour
@property (nonatomic, retain) NSColor* backColour;						//!< Background text colour
@property (nonatomic) BOOL reversed;									//!< \c YES If text/back are reversed

// Dealing with glk style hints
- (void) setHint: (glui32) hint
		 toValue: (glsi32) value;
- (void) setHint: (glui32) hint
	toMatchStyle: (GlkStyle*) style;

// Utility functions
- (BOOL) canBeDistinguishedFrom: (GlkStyle*) style;						//!< Returns \c YES if this style will look different to the given style

// Turning styles into dictionaries for attributed strings
- (NSDictionary*) attributesWithPreferences: (GlkPreferences*) prefs
								scaleFactor: (CGFloat) scaleFactor;		//!< Attributes suitable to use with an attributed string while displaying
- (NSDictionary*) attributesWithPreferences: (GlkPreferences*) prefs;	//!< Attributes suitable to use with an attributed string while displaying

@end

#import <GlkView/GlkPreferences.h>
