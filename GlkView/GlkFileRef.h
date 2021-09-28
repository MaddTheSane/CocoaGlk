//
//  GlkFileRef.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 28/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GlkFileRefProtocol.h"

@interface GlkFileRef : NSObject<GlkFileRef> {
	NSString* pathname;
	
	BOOL temporary;
	BOOL autoflush;
}

/// Designated initialiser
- (id) initWithPath: (NSString*) pathname;

/// Temporary filerefs are deleted when deallocated
- (void) setTemporary: (BOOL) isTemp;

@end
