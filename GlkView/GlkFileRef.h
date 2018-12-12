//
//  GlkFileRef.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 28/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import "GlkViewDefinitions.h"
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import "GlkFileRefProtocol.h"

@interface GlkFileRef : NSObject<GlkFileRef> {
	NSURL* pathname;
	
	BOOL temporary;
	BOOL autoflush;
}

- (instancetype) init UNAVAILABLE_ATTRIBUTE;
- (instancetype) initWithPath: (NSURL*) pathname NS_DESIGNATED_INITIALIZER;

/// Temporary filerefs are deleted when deallocated
@property (getter=isTemporary) BOOL temporary;

@end
