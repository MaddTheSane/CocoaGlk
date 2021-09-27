//
//  GlkTypesetter.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 10/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

// TODO: Migrate to CoreText, re-merge the two typesetter source files.

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
