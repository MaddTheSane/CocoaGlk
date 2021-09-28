//
//  GlkImage.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 08/08/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlkView/GlkCustomTextSection.h>

/// Attribute that can be applied to control glyphs to indicate that they should cause formatting of a specific Glk image
extern NSString* GlkImageAttribute;

///
/// Representation of an image in a text container
///
@interface GlkImage : GlkCustomTextSection {
	/// The NSImage associated with this image
	NSImage* image;
	/// The size to draw this image with
	NSSize size;
	/// The Glk alignment of this image
	unsigned alignment;
	/// The character position of this image in the text stream
	unsigned characterPosition;
	
	/// The bounds of this image in the text container
	NSRect bounds;
	/// Whether or not the bounds for this image have been calculated yet
	BOOL calculatedBounds;

	/// If this is a margin image, the offset that it should be drawn at
	float marginOffset;
	/// Scale factor for margin objects
	float scaleFactor;
}

// Initialisation
- (id) initWithImage: (NSImage*) image
		   alignment: (unsigned) alignment
				size: (NSSize) size
			position: (unsigned) characterPosition;

// Information
/// The NSImage associated with this image
@property (readonly, retain) NSImage *image;
/// The size to draw this image with
@property (readonly) NSSize size;
/// The Glk alignment of this image
@property (readonly) unsigned alignment;
/// The character position of this image in the text stream
@property (readonly) unsigned characterPosition;

/// Sets the bounds of this image, marks it as calculated
- (void) setBounds: (NSRect) bounds;
/// Retrieves the bounds of this image
- (NSRect) bounds;
/// Returns \c YES if the bounds are calculated
@property (readonly) BOOL calculatedBounds;
/// Marks this image as uncalculated
- (void) markAsUncalculated;

@property (nonatomic) NSRect bounds;

@end
