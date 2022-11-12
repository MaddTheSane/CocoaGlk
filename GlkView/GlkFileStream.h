//
//  GlkFileStream.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 28/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#ifndef __GLKVIEW_GLKFILESTREAM_H__
#define __GLKVIEW_GLKFILESTREAM_H__

#import <Foundation/Foundation.h>

#import <GlkView/GlkStreamProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlkFileStream : NSObject<GlkStream> {
	/// The filehandle we're using to read/write from
	NSFileHandle* handle;
}

// Initialisation
- (nullable instancetype) initForReadWriteWithFilename: (NSString*) filename;
- (nullable instancetype) initForWritingWithFilename: (NSString*) filename;
- (nullable instancetype) initForReadingWithFilename: (NSString*) filename;

- (nullable instancetype) initForReadWriteWithFileURL: (NSURL*) filename;
- (nullable instancetype) initForWritingToFileURL: (NSURL*) filename;
- (nullable instancetype) initForReadingFromFileURL: (NSURL*) filename;

@end

NS_ASSUME_NONNULL_END

#endif
