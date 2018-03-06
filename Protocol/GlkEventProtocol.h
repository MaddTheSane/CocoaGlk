//
//  GlkEventProtocol.h
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

#include "glk.h"

///
/// Protocol implemented by any class claiming to be a Glk event
///
NS_SWIFT_NAME(GlkEventProtocol)
@protocol GlkEvent <NSObject>

/// Type of event
@property (readonly) glui32 type;
/// Needs to be converted to a winid_t in the client
@property (readonly) unsigned windowIdentifier;
/// Event data
@property (readonly) glui32 val1;
/// More event data
@property (readonly) glui32 val2;

/// Line data for a line input event
@property (readonly, copy) NSString *lineInput;

@end
