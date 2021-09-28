//
//  GlkStyle.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 29/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlkView/glk.h>

/// Styles store themselves in the attributes to facilitate reformating after a change to a preference object
extern NSString* GlkStyleAttributeName;


@class GlkPreferences;

///
/// Description of a Glk style, and functions for turning a Glk style into a cocoa style
///
/// (Maybe I should split this into a Mutable/Immutable pair)
///
@interface GlkStyle : NSObject<NSCopying> {
	// Style attributes
	float indentation;
	float paraIndent;
	NSTextAlignment alignment;
	float size;
	int weight;
	BOOL oblique;
	BOOL proportional;
	NSColor* textColour;
	NSColor* backColour;
	BOOL reversed;
	
	// Caching the attributes
	/// Change count for the preferences last time we cached the style dictionary
	int prefChangeCount;
	/// The last preference object this style was applied to
	GlkPreferences*	lastPreferences;
	/// The scale factor the attributes were created at
	float lastScaleFactor;
	/// The attributes generated last time we needed to
	NSDictionary* lastAttributes;
}

// Creating a style
/// 'Normal' style
+ (GlkStyle*) style;

// The hints
/// Measured in points
- (void) setIndentation: (float) indentation;
/// Measured in points
- (void) setParaIndentation: (float) paraIndent;
/// Glk doesn't allow us to support 'Natural' alignment
- (void) setJustification: (NSTextAlignment) alignment;
/// Relative, in points
- (void) setSize: (float) size;
/// -1 = lighter, 1 = bolder
- (void) setWeight: (int) weight;
/// YES if an italic/oblique version of the font should be used (italics are used for preference)
- (void) setOblique: (BOOL) oblique;
/// \c NO if fixed-pitch
- (void) setProportional: (BOOL) proportional;
/// Foreground text colour
- (void) setTextColour: (NSColor*) textColor;
/// Background text colour
- (void) setBackColour: (NSColor*) backColor;
/// \c YES If text/back are reversed
- (void) setReversed: (BOOL) reversed;

- (float)			indentation;
- (float)			paraIndentation;
- (NSTextAlignment)	justification;
- (float)			size;
- (int)				weight;
- (BOOL)			oblique;
- (BOOL)			proportional;
- (NSColor*)		textColour;
- (NSColor*)		backColour;
- (BOOL)			reversed;

// Dealing with glk style hints
- (void) setHint: (glui32) hint
		 toValue: (glsi32) value;
- (void) setHint: (glui32) hint
	toMatchStyle: (GlkStyle*) style;

// Utility functions
/// Returns \c YES if this style will look different to the given style
- (BOOL) canBeDistinguishedFrom: (GlkStyle*) style;

// Turning styles into dictionaries for attributed strings
/// Attributes suitable to use with an attributed string while displaying
- (NSDictionary*) attributesWithPreferences: (GlkPreferences*) prefs
								scaleFactor: (float) scaleFactor;
/// Attributes suitable to use with an attributed string while displaying
- (NSDictionary*) attributesWithPreferences: (GlkPreferences*) prefs;

@end

#import <GlkView/GlkPreferences.h>
