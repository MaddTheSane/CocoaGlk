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

@implementation GlkLineSection
@synthesize advancement;
@synthesize alignment;
@synthesize bounds;
@synthesize delegate;
@synthesize offset;
@synthesize glyphRange;
@synthesize elastic;
@end
