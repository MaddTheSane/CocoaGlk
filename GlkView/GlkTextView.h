//
//  GlkTextView.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 01/04/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlkView/GlkTypesetter.h>

///
/// Class that implements our custom extensions to the text view (mainly character input and image drawing)
///
@interface GlkTextView : NSTextView<GlkCustomTextLayout> {
	// Character input
	/// Set to true if we're waiting for single-character input
	BOOL receivingCharacters;
	
	// Custom glyphs (ordered)
	/// Ordered list of custom inline glyphs (images, mostly)
	NSMutableArray* customGlyphs;
	/// Ordered list of custom margin images
	NSMutableArray* marginGlyphs;
	/// The first unlaid margin glyph (index into marginGlyphs)
	int firstUnlaidMarginGlyph;
}

// Character input
/// Any characters sent to this window that can be handled by Glk will be passed to the superview
- (void) requestCharacterInput;
/// Cancels the previous
- (void) cancelCharacterInput;

@end
