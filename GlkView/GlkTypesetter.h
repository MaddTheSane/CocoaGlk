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

@class GlkCustomTextSection;
@class GlkMarginSection;

///
/// Protocol that can be implemented by custom line sections (which want to know about their final typesetting information)
///
@protocol GlkCustomLineSection <NSObject>

/// This object has been typeset at the specified position
- (void) placeBaselineAt: (GlkPoint) point
				forGlyph: (NSInteger) glyph;

@end

///
/// Protocol implemented by things that wish to be informed about the locations of custom glyphs
///
/// (This is by way of a hack to avoid having to implement a NSLayoutManager subclass that can draw the custom glyphs
/// itself)
///
@protocol GlkCustomTextLayout <NSObject>

- (void) invalidateCustomGlyphs: (NSRange) range;
- (void) addCustomGlyph: (NSInteger) location
				section: (GlkCustomTextSection*) section;

@end

///
/// Possible alignments for a section within a line fragment
///
typedef NS_ENUM(int, GlkSectionAlignment) {
	GlkAlignBaseline,							//!< Line up this section with the baseline
	GlkAlignTop,								//!< Line up this section with top of the line fragment (not including leading)
	GlkAlignCenter,								//!< Line up this section with the center of the line fragment
	GlkAlignBottom								//!< Line up this section with the bottom of the line fragment (not including leading)
};

///
/// Representation of a section of a line fragment
///
@interface GlkLineSection: NSObject {
	/// The bounds for this line section: 0,0 indicates the start of the line fragment, 0,0 indicates the far left of the current fragment, at the baseline
	GlkRect bounds;
	/// The X-advancement for this line section
	CGFloat advancement;
	/// The X-offset for this line section
	CGFloat offset;
	/// The glyph range for this line section
	NSRange glyphRange;
	/// The alignment for this line section
	GlkSectionAlignment alignment;

	/// A line section delegate object
	__unsafe_unretained id<GlkCustomLineSection> delegate;
	/// Whether or not this is an elastic line section (used in full-justification)
	BOOL elastic;
}

/// The bounds for this line section: 0,0 indicates the start of the line fragment, 0,0 indicates the far left of the current fragment, at the baseline
@property GlkRect bounds;
/// The X-advancement for this line section
@property CGFloat advancement;
/// The X-offset for this line section
@property CGFloat offset;
/// The glyph range for this line section
@property NSRange glyphRange;
/// The alignment for this line section
@property GlkSectionAlignment alignment;

/// A line section delegate object
@property (assign) id<GlkCustomLineSection> delegate;
/// Whether or not this is an elastic line section (used in full-justification)
@property (getter=isElastic) BOOL elastic;

@end

#if defined(COCOAGLK_IPHONE)
#import "GlkTypesetter-iOS.h"
#else
#import "GlkTypesetter-Mac.h"
#endif

#import <GlkView/GlkCustomTextSection.h>
