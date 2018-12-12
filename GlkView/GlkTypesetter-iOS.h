//
//  GlkTypesetter-iOS.h
//  GlkView-iOS
//
//  Created by C.W. Betts on 12/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlkTypesetter : NSObject {
	
	// The glyph cache
	/// The range of the cached glyphs
	NSRange cached;
	/// Size of the cache
	NSUInteger cacheLength;

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
	UIFont*__unsafe_unretained* cacheFonts;

	/// The character index into the source string for each glyph
	NSUInteger* cacheCharIndexes;
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

NS_ASSUME_NONNULL_END
