//
//  GlkSessionProtocol.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 20/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#if defined(COCOAGLK_IPHONE)
# include <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

//
// Streams can also be accessed through the buffer (and usually are for writing)
//
// Our streams use unichars and unicode strings rather than the Latin-1 specified by Glk.
// This amounts to the same things overall, but makes it easy to update later.
//

typedef NS_ENUM(int, GlkSeekMode) {
	GlkSeekStart,
	GlkSeekCurrent,
	GlkSeekEnd
};

#define GlkEOFChar 0xffff

///
/// Streams can also be accessed through the buffer (and usually are for writing)
///
/// Our streams use unichars and unicode strings rather than the Latin-1 specified by Glk.
/// This amounts to the same things overall, but makes it easy to update later.
///
@protocol GlkStream <NSObject>

// Control
- (void) closeStream;
- (void) setPosition: (in NSInteger) position
		  relativeTo: (in enum GlkSeekMode) seekMode;

- (NSUInteger) getPosition;

// Writing
- (void) putChar: (in unichar) ch;
- (void) putString: (in bycopy NSString*) string;
- (void) putBuffer: (in bycopy NSData*) buffer;

// Reading
- (unichar) getChar;
- (bycopy NSString*) getLineWithLength: (int) maxLen;
- (bycopy NSData*) getBufferWithLength: (NSUInteger) length;

// Styles
- (void) setStyle: (int) styleId;
- (int) style;

@property (nonatomic, readwrite) int style;

- (void) setImmediateStyleHint: (unsigned) hint
					   toValue: (int) value;
- (void) clearImmediateStyleHint: (unsigned) hint;
- (void) setCustomAttributes: (NSDictionary*) customAttributes;

- (void) setHyperlink: (unsigned int) value;
- (void) clearHyperlink;

@end
