//
//  GlkFileStream.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 28/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GlkStreamProtocol.h"

@interface GlkFileStream : NSObject<GlkStream> {
	/// The filehandle we're using to read/write from
	NSFileHandle* handle;
}

// Initialisation
- (instancetype) initForReadWriteWithFilename: (NSURL*) filename;
- (instancetype) initForWritingWithFilename: (NSURL*) filename;
- (instancetype) initForReadingWithFilename: (NSURL*) filename;

@end
