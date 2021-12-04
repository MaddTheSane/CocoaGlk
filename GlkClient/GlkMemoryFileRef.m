//
//  GlkMemoryFileRef.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 12/11/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import "GlkMemoryFileRef.h"
#import "GlkMemoryStream.h"


@implementation GlkMemoryFileRef

- (id) initWithData: (NSData*) fileData {
	self = [super init];
	
	if (self) {
		data = fileData;
	}
	
	return self;
}

- (byref id<GlkStream>) createReadOnlyStream {
	return [[GlkMemoryStream alloc] initWithMemory: (unsigned char*)[data bytes]
											length: [data length]];
}

- (byref id<GlkStream>) createWriteOnlyStream {
	return nil;
}

- (byref id<GlkStream>) createReadWriteStream {
	return nil;
}

- (void) deleteFile {
	// Do nothing
}

- (BOOL) fileExists {
	return YES;
}

@synthesize autoflushStream = autoflush;

@end
