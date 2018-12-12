//
//  GlkTypesetter.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 10/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import "GlkViewDefinitions.h"
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif


///
/// NSTypesetter subclass that can do all the funky things that Glk requires to support images
///
@interface GlkTypesetter : NSTypesetter {
	// What we're laying out
	/// The text storage object that we're laying out [NOT RETAINED]
	__unsafe_unretained NSAttributedString* storage;
	/// The layout manager that we're dealing with [NOT RETAINED]
	__unsafe_unretained NSLayoutManager* layout;
	/// The list of all of the text containers in the current [NOT RETAINED]
	__unsafe_unretained NSArray* containers;
	/// The text container that we're fitting text into [NOT RETAINED]
	__unsafe_unretained NSTextContainer* container;
	
	/// The line fragment padding to use
	CGFloat inset;
	/// The last glyph laid out
	NSInteger lastSetGlyph;
	
	// The glyph cache
	/// The range of the cached glyphs
	NSRange cached;
	/// Size of the cache
	NSUInteger cacheLength;
	
	/// The identifier for each glyph that we're laying out
	NSGlyph* cacheGlyphs;
	/// The character index into the source string for each glyph
	NSUInteger* cacheCharIndexes;
	/// The inscriptions for each glyph
	NSGlyphInscription* cacheInscriptions;
	/// The elastic bits for each glyph
	BOOL* cacheElastic;
	/// The bidirectional level for each glyph
	unsigned char* cacheBidi;
	
	/// The X-advancements for each glyph that we're laying out
	CGFloat* cacheAdvancements;
	/// The ascenders for each glyph that we're laying out
	CGFloat* cacheAscenders;
	/// The descenders for each glyph that we're laying out
	CGFloat* cacheDescenders;
	/// The line heights for each glyph that we're laying out
	CGFloat* cacheLineHeight;
	/// The bounds for each glyph that we're laying out
	GlkRect* cacheBounds;
	/// The attributes for each glyph that we're laying out [RETAINED]
	NSDictionary*__strong* cacheAttributes;
	/// The font attribute for each glyph that we're laying out [NOT RETAINED]
	NSFont*__unsafe_unretained* cacheFonts;
	
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
	NSInteger lineFragmentInitialGlyph;
	/// Left margin added (so far) in this fragment
	CGFloat thisLeftMargin;
	/// Right margin added (so far) in this fragment
	CGFloat thisRightMargin;
	CGFloat thisLeftMaxY;
	CGFloat thisRightMaxY;
	
	// The current paragraph
	/// The character range for the current paragraph
	NSRange paragraph;
	/// The NSParagraphStyle for the current paragraph [NOT RETAINED]
	NSParagraphStyle* paraStyle;
	
	// Line sections
	/// The used rect of the current text container
	GlkRect usedRect;
	/// The size of the current text container
	GlkCocoaSize size;
	/// The line sections themselves
	NSMutableArray<GlkLineSection*> *sections;
	/// Offset to apply to the baseline due to custom alignment
	CGFloat customOffset;
	/// If YES, then the bounding box is not sufficient to calculate the baseline offset to use
	BOOL customBaseline;
	
	/// The overall line fragment bounds
	GlkRect fragmentBounds;
	/// The line fragment rectangle according to the text container
	GlkRect proposedRect;
	/// The remaining rectangle, according to the text container
	GlkRect remaining;

	// The delegate
	/// The delegate [NOT RETAINED]
	id<GlkCustomTextLayout> delegate;
}

// Laying out line sections
/// Ensures that the specified range of glyphs are in the cache
- (BOOL) cacheGlyphsIncluding: (NSInteger) minGlyphIndex;
/// Starts a new line fragment
- (void) beginLineFragment;
/// Finishes the current line fragment and adds it to the layout manager
- (BOOL) endLineFragment: (BOOL) lastFragment
				 newline: (BOOL) newline;

/// Adds a new line section
- (void) addLineSection: (GlkRect) bounds
			advancement: (CGFloat) advancement
				 offset: (CGFloat) offset
			 glyphRange: (NSRange) glyphRange
			  alignment: (GlkSectionAlignment) alignment
			   delegate: (id<GlkCustomLineSection>) delegate
				elastic: (BOOL) elastic;

// Margins
/// Adds a certain width to the left margin on the current line
/// (for flowing images)
- (void) addToLeftMargin: (CGFloat) width
				  height: (CGFloat) height;
/// Adds a certain width to the right margin on the current line
/// (for flowing images)
- (void) addToRightMargin: (CGFloat) width
				   height: (CGFloat) height;

/// Get the current offset into the left margin
@property (readonly) CGFloat currentLeftMarginOffset;
/// Get the current offset into the right margin
@property (readonly) CGFloat currentRightMarginOffset;
/// Remaining space for margin objects
@property (readonly) CGFloat remainingMargin;

/// Amount required to clear the left margin
@property (readonly) CGFloat currentLeftMarginHeight;
/// Amount required to clear the right margin
@property (readonly) CGFloat currentRightMarginHeight;

// Laying out glyphs
/// Lays out a single line fragment from the specified glyph
- (NSInteger) layoutLineFromGlyph: (NSInteger) glyph;

// Setting the delegate
/// Sets the delegate (the delegate is NOT RETAINED)
@property (assign) id<GlkCustomTextLayout> delegate;

// Clearing the cache
/// Forces any cached glyphs to be cleared (eg when a textstorage object changes)
- (void) flushCache;

@end
