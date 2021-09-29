//
//  GlkCustomTextSection.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 17/09/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlkView/GlkTypesetter.h>

/// Attribute indicating that a section of text should use custom attribute formatting. Value should be a \c GlkCustomTextSection object.
extern NSAttributedStringKey const GlkCustomSectionAttributeName;

///
/// Object that can be set against control glyphs to indicate that they have some custom formatting and drawing.
///
@interface GlkCustomTextSection : NSObject<GlkCustomLineSection>

// Formatting

// Note that this element is not typeset when this is called (wait for the placeBaselineAt: call)
/// Request from the typesetter that this object generate a suitable line section object. Returns \c YES to indicate that a line section has been created
- (BOOL) formatSectionAtOffset: (CGFloat) offset
				  inTypesetter: (GlkTypesetter*) typesetter
				 forGlyphRange: (NSRange) glyphs;

// Drawing

- (void) drawAtPoint: (NSPoint) point
			  inView: (NSView*) view;

@end
