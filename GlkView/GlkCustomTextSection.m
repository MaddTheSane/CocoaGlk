//
//  GlkCustomTextSection.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 17/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import <GlkView/GlkCustomTextSection.h>

NSString* const GlkCustomSectionAttributeName = @"GlkCustomSectionAttributeName";

@implementation GlkCustomTextSection

// = Formatting =

- (BOOL) formatSectionAtOffset: (CGFloat) offset
				  inTypesetter: (GlkTypesetter*) typesetter
				 forGlyphRange: (NSRange) glyphs {
	// The default implementation does nothing
	return NO;
}

// = Typesetting =

- (void) placeBaselineAt: (NSPoint) point
				forGlyph: (NSInteger) glyph {
	// Do nothing...
}


// = Drawing =

- (void) drawAtPoint: (NSPoint) point
			  inView: (NSView*) view {
}

@end

