//
//  GlkImage.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 08/08/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#include <tgmath.h>
#import "GlkImage.h"
#import "glk.h"

NSString* GlkImageAttribute = @"GlkImageAttribute";

@implementation GlkImage

// = Initialisation =

- (id) initWithImage: (GlkSuperImage*) img
		   alignment: (unsigned) align
				size: (GlkCocoaSize) sz
			position: (NSUInteger) charPos {
	self = [super init];
	
	if (self) {
		image = [img retain];
		alignment = align;
		size = sz;
		characterPosition = charPos;
	}
	
	return self;
}

- (void) dealloc {
	[image release];
	
	[super dealloc];
}

// = Information =

@synthesize image;
@synthesize size;
@synthesize alignment;
@synthesize characterPosition;

// = Cached information =

@synthesize bounds;
- (void) setBounds: (GlkRect) newBounds {
	calculatedBounds = YES;
	bounds = newBounds;
}

@synthesize calculatedBounds;

- (void) markAsUncalculated {
	calculatedBounds = NO;
}

// = Placing this image =

- (BOOL) formatSectionAtOffset: (CGFloat) offset
				  inTypesetter: (GlkTypesetter*) typesetter
				 forGlyphRange: (NSRange) glyphs {
	scaleFactor = 1.0;
	
	CGFloat remainingMargin = [typesetter remainingMargin];
	
	// Add a new line section for this image
	switch (alignment) {
		case imagealign_InlineUp:
		case imagealign_InlineDown:
		case imagealign_InlineCenter:
		{
			GlkSectionAlignment secAlign = GlkAlignCenter;
			if (alignment == imagealign_InlineUp)
				secAlign = GlkAlignTop;
			else if (alignment == imagealign_InlineDown)
				secAlign = GlkAlignBottom;
		
			[typesetter addLineSection: GlkMakeRect(offset, -size.height, size.width, size.height)
						   advancement: size.width
								offset: offset
							glyphRange: glyphs
							 alignment: secAlign
							  delegate: nil
							   elastic: YES];
			return YES;
		}
			
		case imagealign_MarginLeft:
			if (remainingMargin - size.width < 100) scaleFactor = (remainingMargin-100)/size.width;
			if (remainingMargin < 100) scaleFactor = 0;
			
			marginOffset = [typesetter currentLeftMarginOffset];
			[typesetter addToLeftMargin: (size.width*scaleFactor)+8
								 height: size.height*scaleFactor];
			[typesetter addLineSection: GlkMakeRect(offset, -1, size.width, 1)
						   advancement: 0
								offset: offset
							glyphRange: glyphs
							 alignment: GlkAlignBottom
							  delegate: nil
							   elastic: YES];
			return YES;
			
		case imagealign_MarginRight:
			if (remainingMargin - size.width < 100) scaleFactor = (remainingMargin-100)/size.width;
			if (remainingMargin < 100) scaleFactor = 0;
			
			[typesetter addToRightMargin: (size.width*scaleFactor)+8
								  height: size.height*scaleFactor];
			[typesetter addLineSection: GlkMakeRect(offset, -1, size.width, 1)
						   advancement: 0
								offset: offset
							glyphRange: glyphs
							 alignment: GlkAlignBottom
							  delegate: nil
							   elastic: YES];
			marginOffset = [typesetter currentRightMarginOffset]-8;
			return YES;
	}
	
	return NO;
}

// = Drawing =

- (void) drawAtPoint: (GlkPoint) point
			  inView: (GlkSuperView*) view {
	GlkRect drawRect;
	GlkRect imageRect;
	
	if (alignment == imagealign_MarginLeft) {
		NSSize inset = [(NSTextView*)view textContainerInset];
		
		point.x = marginOffset + inset.width;
	} else if (alignment == imagealign_MarginRight) {
		NSSize inset = [(NSTextView*)view textContainerInset];

		point.x = NSMaxX([view bounds])-marginOffset - inset.width;
	} else {
		CGFloat maxWidth = NSMaxX([view bounds]) - point.x - 8;
		if (maxWidth < size.width) scaleFactor = maxWidth/size.width;
	}
	
	drawRect.origin = GlkMakePoint(floor(point.x), floor(point.y));
	drawRect.size = size;
	drawRect.size.width *= scaleFactor;
	drawRect.size.height *= scaleFactor;
	
	imageRect.origin = NSMakePoint(0,0);
	imageRect.size = [image size];
	
	[image drawInRect: drawRect
			 fromRect: imageRect
			operation: NSCompositeSourceOver
			 fraction: 1.0];
}


@end
