//
//  GlkTypesetter.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 10/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

// TODO: (?) monitor the text storage object for changes, and flush the glyph cache as appropriate
// TODO: deal with more than one container
// TODO: support different line breaking modes
// TODO: bidirectional support
// TODO: tabstop support
// TODO: hyphenation
// TODO: release stuff in the attribute caches
// TODO: underlining
// TODO: NSKernAttributeName
// TODO: NSBaselineOffsetAttributeName
// TODO: text attachments
// TODO: (?) recognise all newline characters (U+085 in particular), and the DOS combos
// TODO: dealloc method
// TODO: if we can't layout even a single glyph in a line, we just abort layout at that point
// TODO: squish custom sections that won't find on a line
// TODO: zombie bug? (eg, shrink down view so that glyphs won't fit on a line, though seems to happen at other points too)
// TODO: NSFont boundsForGlyph seems to be returning utter garbage in many cases
// TODO: crash if we shrink the view below the size of the left/right margin
// TODO: Deal with images that occupy a margin and that are shorter than the image that's currently there better

#include <tgmath.h>
#import <GlkView/GlkImage.h>
#import "glk.h"

#import <GlkView/GlkTypesetter.h>
#import <GlkView/GlkCustomTextSection.h>

#if CGFLOAT_IS_DOUBLE
#define CGF(__x) __x
#else
#define CGF(__x) __x ## f
#endif

// Internal classes
@interface GlkMarginSection : NSObject {
	NSInteger fragmentGlyph;
	CGFloat width;
	CGFloat maxY;
}

- (id) initWithFragmentGlyph: (NSInteger) glyph
					   width: (CGFloat) width
						maxY: (CGFloat) maxY;

@property (readonly) NSInteger glyph;
@property (readonly) CGFloat width;
@property (readonly) CGFloat maxY;

@end

@implementation GlkMarginSection

- (id) initWithFragmentGlyph: (NSInteger) glyph
					   width: (CGFloat) newWidth
						maxY: (CGFloat) newMaxY {
	self = [super init];
	
	if (self) {
		fragmentGlyph = glyph;
		width = newWidth;
		maxY = newMaxY;
	}
	
	return self;
}

@synthesize glyph=fragmentGlyph;
@synthesize width;
@synthesize maxY;

@end

// Behaviour #defines

#define GlyphLookahead 512								// Number of glyphs to 'look ahead' when working out character positioning, etc
#define GlyphMinRemoval 256								// Minimum number of glyphs to remove from the cache all at once
#undef  Debug											// Define to put this in debugging mode
#undef  MoreDebug										// More debugging information
#undef  EvenMoreDebug									// Even more debugging information
#undef  CheckForOverflow								// Check for overflow when laying out the lines

// OS X version #defines

#undef MeasureMultiGlyphs								// Use the 10.4 routines in NSFont to measure multiple glyphs at once

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
# define MeasureMultiGlyphs
#endif

#undef MeasureMultiGlyphs

// Static variables

static NSCharacterSet* newlineSet = nil;
static NSCharacterSet* whitespaceSet = nil;

static NSParagraphStyle* defaultParaStyle = nil;

#ifdef Debug
static NSString* buggyAttribute = @"BUG IF WE TRY TO ACCESS THIS";
#endif

@implementation GlkLineSection
@synthesize advancement;
@synthesize alignment;
@synthesize bounds;
@synthesize delegate;
@synthesize offset;
@synthesize glyphRange;
@synthesize elastic;
@end
