//
//  GlkTypesetter.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 10/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GlkCustomTextSection;
@class GlkMarginSection;

///
/// Protocol that can be implemented by custom line sections (which want to know about their final typesetting information)
///
@protocol GlkCustomLineSection <NSObject>

/// This object has been typeset at the specified position
- (void) placeBaselineAt: (NSPoint) point
				forGlyph: (int) glyph;

@end

///
/// Protocol implemented by things that wish to be informed about the locations of custom glyphs
///
/// (This is by way of a hack to avoid having to implement a NSLayoutManager subclass that can draw the custom glyphs
/// itself)
///
@protocol GlkCustomTextLayout <NSObject>

- (void) invalidateCustomGlyphs: (NSRange) range;
- (void) addCustomGlyph: (int) location
				section: (GlkCustomTextSection*) section;

@end

///
/// Possible alignments for a section within a line fragment
///
typedef enum GlkSectionAlignment GlkSectionAlignment;
enum GlkSectionAlignment {
	/// Line up this section with the baseline
	GlkAlignBaseline,
	/// Line up this section with top of the line fragment (not including leading)
	GlkAlignTop,
	/// Line up this section with the center of the line fragment
	GlkAlignCenter,
	/// Line up this section with the bottom of the line fragment (not including leading)
	GlkAlignBottom
};

///
/// Representation of a section of a line fragment
///
typedef struct GlkLineSection {
	/// The bounds for this line section: 0,0 indicates the start of the line fragment, 0,0 indicates the far left of the current fragment, at the baseline
	NSRect bounds;
	/// The X-advancement for this line section
	float advancement;
	/// The X-offset for this line section
	float offset;
	/// The glyph range for this line section
	NSRange glyphRange;
	/// The alignment for this line section
	GlkSectionAlignment alignment;

	/// A line section delegate object
	id<GlkCustomLineSection> delegate;
	/// Whether or not this is an elastic line section (used in full-justification)
	BOOL elastic;
} GlkLineSection;

///
/// NSTypesetter subclass that can do all the funky things that Glk requires to support images
///
@interface GlkTypesetter : NSTypesetter {
	// What we're laying out
	/// The text storage object that we're laying out [NOT RETAINED]
	NSAttributedString* storage;
	/// The layout manager that we're dealing with [NOT RETAINED]
	NSLayoutManager* layout;
	/// The list of all of the text containers in the current [NOT RETAINED]
	NSArray* containers;
	/// The text container that we're fitting text into [NOT RETAINED]
	NSTextContainer* container;
	
	/// The line fragment padding to use
	float inset;
	/// The last glyph laid out
	int lastSetGlyph;
	
	// The glyph cache
	/// The range of the cached glyphs
	NSRange cached;
	/// Size of the cache
	int cacheLength;
	
	/// The identifier for each glyph that we're laying out
	NSGlyph* cacheGlyphs;
	/// The character index into the source string for each glyph
	unsigned* cacheCharIndexes;
	/// The inscriptions for each glyph
	NSGlyphInscription* cacheInscriptions;
	/// The elastic bits for each glyph
	BOOL* cacheElastic;
	/// The bidirectional level for each glyph
	unsigned char* cacheBidi;
	
	/// The X-advancements for each glyph that we're laying out
	float* cacheAdvancements;
	/// The ascenders for each glyph that we're laying out
	float* cacheAscenders;
	/// The descenders for each glyph that we're laying out
	float* cacheDescenders;
	/// The line heights for each glyph that we're laying out
	float* cacheLineHeight;
	/// The bounds for each glyph that we're laying out
	NSRect* cacheBounds;
	/// The attributes for each glyph that we're laying out [RETAINED]
	NSDictionary** cacheAttributes;
	/// The font attribute for each glyph that we're laying out [NOT RETAINED]
	NSFont** cacheFonts;
	
	// Left and right margin sections
	/// Left margin items (by line fragment initial glyph)
	NSMutableArray* leftMargins;
	/// Right margin items (by line fragment initial glyph)
	NSMutableArray* rightMargins;
	/// Left margin active before this line fragment started
	GlkMarginSection* activeLeftMargin;
	/// Right margin active before this line fragment started
	GlkMarginSection* activeRightMargin;
	
	/// First glyph on the current line fragment
	int lineFragmentInitialGlyph;
	/// Left margin added (so far) in this fragment
	float thisLeftMargin;
	/// Right margin added (so far) in this fragment
	float thisRightMargin;
	float thisLeftMaxY;
	float thisRightMaxY;
	
	// The current paragraph
	/// The character range for the current paragraph
	NSRange paragraph;
	/// The NSParagraphStyle for the current paragraph [NOT RETAINED]
	NSParagraphStyle* paraStyle;
	
	// Line sections
	/// The used rect of the current text container
	NSRect usedRect;
	/// The size of the current text container
	NSSize size;
	/// Number of line sections
	int numLineSections;
	/// The line sections themselves
	GlkLineSection* sections;
	/// Offset to apply to the baseline due to custom alignment
	float customOffset;
	/// If YES, then the bounding box is not sufficient to calculate the baseline offset to use
	BOOL customBaseline;
	
	/// The overall line fragment bounds
	NSRect fragmentBounds;
	/// The line fragment rectangle according to the text container
	NSRect proposedRect;
	/// The remaining rectangle, according to the text container
	NSRect remaining;

	// The delegate
	/// The delegate [NOT RETAINED]
	id<GlkCustomTextLayout> delegate;
}

// Laying out line sections
/// Ensures that the specified range of glyphs are in the cache
- (BOOL) cacheGlyphsIncluding: (int) minGlyphIndex;
/// Starts a new line fragment
- (void) beginLineFragment;
/// Finishes the current line fragment and adds it to the layout manager
- (BOOL) endLineFragment: (BOOL) lastFragment
				 newline: (BOOL) newline;

/// Adds a new line section
- (void) addLineSection: (NSRect) bounds
			advancement: (float) advancement
				 offset: (float) offset
			 glyphRange: (NSRange) glyphRange
			  alignment: (GlkSectionAlignment) alignment
			   delegate: (id<GlkCustomLineSection>) delegate
				elastic: (BOOL) elastic;

// Margins
/// Adds a certain width to the left margin on the current line
/// (for flowing images)
- (void) addToLeftMargin: (float) width
				  height: (float) height;
/// Adds a certain width to the right margin on the current line
/// (for flowing images)
- (void) addToRightMargin: (float) width
				   height: (float) height;

/// Get the current offset into the left margin
- (float) currentLeftMarginOffset;
/// Get the current offset into the right margin
- (float) currentRightMarginOffset;
/// Remaining space for margin objects
- (float) remainingMargin;

/// Amount required to clear the left margin
- (float) currentLeftMarginHeight;
/// Amount required to clear the right margin
- (float) currentRightMarginHeight;

// Laying out glyphs
/// Lays out a single line fragment from the specified glyph
- (int) layoutLineFromGlyph: (int) glyph;

// Setting the delegate
/// Sets the delegate (the delegate is NOT RETAINED)
- (void) setDelegate: (id<GlkCustomTextLayout>) delegate;

// Clearing the cache
/// Forces any cached glyphs to be cleared (eg when a textstorage object changes)
- (void) flushCache;

@end

#import <GlkView/GlkCustomTextSection.h>
