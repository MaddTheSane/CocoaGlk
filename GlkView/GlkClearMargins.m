//
//  GlkClearMargins.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 20/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import "GlkClearMargins.h"

#if CGFLOAT_IS_DOUBLE
#define CGF(__x) __x
#else
#define CGF(__x) __x ## f
#endif

@implementation GlkClearMargins

- (BOOL) formatSectionAtOffset: (CGFloat) offset
				  inTypesetter: (GlkTypesetter*) typesetter
				 forGlyphRange: (NSRange) glyphs {
	CGFloat height1 = [typesetter currentLeftMarginHeight];
	CGFloat height2 = [typesetter currentRightMarginHeight];
	
	CGFloat clearHeight = height1>height2?height1:height2;
	
	[typesetter addLineSection: GlkMakeRect(offset, -clearHeight, CGF(0.1), clearHeight)
				   advancement: 0
						offset: offset
					glyphRange: glyphs
					 alignment: GlkAlignTop
					  delegate: nil
					   elastic: YES];	
	
	return YES;
}

@end
