//
//  glk_stream.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 16/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "glk.h"
#import "cocoaglk.h"
#import "glk_client.h"

#import "GlkMemoryStream.h"
#import "GlkUcs4Stream.h"
#import "GlkUTF8Stream.h"
#import "GlkBufferedStream.h"
#import "ClientLogging.h"

#define GlkStreamMaxBuffer 32768

strid_t cocoaglk_currentstream = nil;
strid_t cocoaglk_firststream = nil;
unsigned cocoaglk_maxstreamid = 0;

#pragma mark - Utility functions

void cocoaglk_verify_streams(void) {
	// Debug functions
	strid_t str = cocoaglk_firststream;
	while (str != NULL) {
		if (!cocoaglk_strid_sane(str)) {
			cocoaglk_error("cocoaglk_verify_streams failed");
		}
		
		str = str->next;
	}
}

strid_t cocoaglk_stream(void) {
	// Creates a very empty stream object
	// You must fill in the rest of the structures to persuade this to work
	strid_t res = malloc(sizeof(struct glk_stream_struct));
	
	res->key = GlkStreamKey;
	res->identifier = cocoaglk_maxstreamid++;
	res->rock = 0;
	
	res->fmode = filemode_Read;
	
	res->buffered = NO;
	res->lazyFlush = NO;
	res->streamBuffer = nil; //[[GlkBuffer alloc] init];
	res->bufferedAmount = 0;
	
	res->stream = nil;
	res->written = 0;
	res->read = 0;
	
	res->windowStream = NO;
	res->windowIdentifier = 0;
	
	res->style = style_Normal;
	
	res->echo = NULL;
	res->echoesTo = [[NSMutableArray alloc] init];
	
	if (cocoaglk_firststream) {
		cocoaglk_firststream->last = res;
	}
	res->next = cocoaglk_firststream;
	res->last = NULL;
	cocoaglk_firststream = res;
	
	return res;
}

void cocoaglk_flushstream(strid_t stream, const char* reason) {
	// Clears out the buffer being used for this stream
	if (!stream->buffered) return;
	
	// Get the buffer this stream is using
	GlkBuffer* buffer = nil;
	if (stream->streamBuffer == nil) {
		buffer = cocoaglk_buffer;
		cocoaglk_flushbuffer(reason);
		stream->bufferedAmount = 0;
		return;
	} else {
		buffer = stream->streamBuffer;
	}
	
	if ([buffer shouldBeFlushed]) {
		os_log_debug(GlkClientTrace, "Flushing a stream buffer: %{public}s", reason);
		
		// Flush the buffer
		[cocoaglk_session performOperationsFromBuffer: buffer];
		
		// Reset the count of how much is buffered
		stream->bufferedAmount = 0;
		
		// Rotate the buffers
		[buffer release];
		buffer = [[GlkBuffer alloc] init];
		if (stream->streamBuffer == nil) {
			cocoaglk_buffer = buffer;
		} else {
			stream->streamBuffer = buffer;
		}

		// Flush this buffer
		[cocoaglk_session performOperationsFromBuffer: buffer];
		
		os_log_debug(GlkClientTrace, "Stream flushed");
	}
}

void cocoaglk_maybeflushstream(strid_t stream, const char* reason) {
	// Flushes a stream if necessary
	if (stream->buffered && stream->bufferedAmount >= GlkStreamMaxBuffer) {
		cocoaglk_flushstream(stream, reason);
	}
	
	if ([cocoaglk_buffer hasGotABitOnTheLargeSide]) {
		// Might as well check for this as well
		cocoaglk_flushbuffer("While flushing stream: main buffer has become large");
	}
}

void cocoaglk_loadstream(strid_t stream) {
	// Ensures that the stream's 'real' object is available
	if (stream->stream == nil && !stream->windowStream) {
		cocoaglk_error("Encountered a stream which is not connected to anything");
	}
	
	if (stream->stream == nil && stream->windowStream) {
		cocoaglk_flushstream(stream, "Connecting a stream");
		cocoaglk_flushbuffer("Connecting a stream");
		
		stream->stream = [cocoaglk_session streamForWindowIdentifier: stream->windowIdentifier];
		
		if (stream->stream == nil) {
			cocoaglk_error("Failed to obtain the stream for a window");
		}
	}
}

BOOL cocoaglk_strid_sane(strid_t stream) {
	// Checks that a strid object is 'sane'
	if (stream == NULL) return NO;
	if (stream->key != GlkStreamKey) return NO;
		
	// These are internal consistency checks
	if (stream->last == NULL && stream != cocoaglk_firststream) {
		os_log_fault(GlkClientLog, "Stream has no previous stream, but is not the first in the list");
		return NO;
	} else if (stream->last != NULL && stream == cocoaglk_firststream) {
		os_log_fault(GlkClientLog, "Stream has a preceding stream, but is also marked as the first in the list");
		return NO;
	}
	
	return YES;
}

BOOL cocoaglk_strid_write(strid_t str) {
	// Returns YES if the stream can be written to
	if (str->fmode == filemode_Write ||
		str->fmode == filemode_WriteAppend ||
		str->fmode == filemode_ReadWrite) {
		return YES;
	} else {
		return NO;
	}
}

BOOL cocoaglk_strid_read(strid_t str) {
	// Returns YES if the stream can be read from
	if (str->fmode == filemode_Read ||
		str->fmode == filemode_ReadWrite) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark - Stream functions

///
/// You can open a stream which reads from or writes to a disk file.
///
/// fileref indicates the file which will be opened. fmode can be
/// any of \c filemode_Read , \c filemode_Write , \c filemode_WriteAppend , or
/// \c filemode_ReadWrite . If \c fmode is \c filemode_Read , the file must already
/// exist; for the other modes, an empty file is created if none exists. If
/// \c fmode is \c filemode_Write , and the file already exists, it is truncated
/// down to zero length (an empty file). If \c fmode is \c filemode_WriteAppend ,
/// the file mark is set to the end of the file.
///
/// The file may be read or written in text or binary mode; this is determined
/// by the fileref argument. Similarly, platform-dependent attributes such
/// as file type are determined by fileref. See section 6, "File References".
///
strid_t glk_stream_open_file(frefid_t fileref, glui32 fmode,
							 glui32 rock) {
	// Sanity check
	if (!cocoaglk_frefid_sane(fileref)) {
		cocoaglk_error("glk_stream_open_file called with an invalid frefid");
		return NULL;
	}

	// Get the stream
	id<GlkStream> stream = nil;
	
	if (fmode == filemode_ReadWrite || fmode == filemode_WriteAppend) {
		stream = [fileref->fileref createReadWriteStream];
	} else if (fmode == filemode_Write) {
		stream = [fileref->fileref createWriteOnlyStream];
	} else if (fmode == filemode_Read) {
		stream = [fileref->fileref createReadOnlyStream];
		
		if ((fileref->usage&fileusage_TextMode) == 0 && [stream isProxy]) {
			stream = [[[GlkBufferedStream alloc] initWithStream: stream] autorelease];
		}
	} else {
		cocoaglk_error("glk_stream_open_file called with an unknown fmode");
		return NULL;
	}
	
	if (stream == NULL) {
		// Couldn't create the stream for some reason
		return NULL;
	}
	
	if (fmode == filemode_WriteAppend) {
		[stream setPosition: 0
				 relativeTo: GlkSeekEnd];
	}
	
	// Create the stream
	strid_t res = cocoaglk_stream();
	
	// Stream should be buffered
	if ([stream isProxy]) {
		res->buffered = YES;
		res->streamBuffer = [fileref->fileref autoflushStream]?nil:[[GlkBuffer alloc] init];
	} else {
		res->buffered = NO;
		res->streamBuffer = nil;
	}
	
	// Set the file mode
	res->fmode = fmode;
	
	// Set the stream object
	res->stream = [stream retain];
	
	// The rock
	res->rock = rock;
	
	// Tell the UI about this stream (though it never really needs to know about it)
	if (res->streamBuffer) {
		[res->streamBuffer registerStream: stream
							forIdentifier: res->identifier];
	} else if (res->buffered) {
		[cocoaglk_buffer registerStream: stream
						  forIdentifier: res->identifier];
	}
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}
	
	os_log_debug(GlkClientTrace, "glk_stream_open_file(%{public}p, %{public}u, %{public}u) = %{public}p", fileref, fmode, rock, res);
	
	return res;
}

strid_t glk_stream_open_file_uni(frefid_t fileref, glui32 fmode,
								 glui32 rock) {
	// Sanity check
	if (!cocoaglk_frefid_sane(fileref)) {
		cocoaglk_error("glk_stream_open_file called with an invalid frefid");
		return NULL;
	}
	
	// Get the stream
	id<GlkStream> stream = nil;
	
	if (fmode == filemode_ReadWrite || fmode == filemode_WriteAppend) {
		stream = [fileref->fileref createReadWriteStream];

		if ((fileref->usage&fileusage_TextMode) == 0 && [stream isProxy]) {
			stream = [[[GlkBufferedStream alloc] initWithStream: stream] autorelease];
		}
	} else if (fmode == filemode_Write) {
		stream = [fileref->fileref createWriteOnlyStream];
	} else if (fmode == filemode_Read) {
		stream = [fileref->fileref createReadOnlyStream];
	} else {
		cocoaglk_error("glk_stream_open_file called with an unknown fmode");
		return NULL;
	}
	
	if (stream == NULL) {
		// Couldn't create the stream for some reason
		return NULL;
	}
	
	if (fmode == filemode_WriteAppend) {
		[stream setPosition: 0
				 relativeTo: GlkSeekEnd];
	}
	
	if ((fileref->usage&fileusage_TextMode) == fileusage_TextMode) {
		// Convert to UTF-8
		stream = [[GlkUTF8Stream alloc] initWithStream: stream];
	} else {
		// Convert to UCS-4
		stream = [[GlkUcs4Stream alloc] initWithStream: stream
											 bigEndian: YES];
	}
	
	// Create the stream
	strid_t res = cocoaglk_stream();
	
	// Stream should be buffered
	if ([stream isProxy]) {
		res->buffered = YES;
		res->streamBuffer = [fileref->fileref autoflushStream]?nil:[[GlkBuffer alloc] init];
	} else {
		res->buffered = NO;
		res->streamBuffer = nil;
	}
	
	// Set the file mode
	res->fmode = fmode;
	
	// Set the stream object
	res->stream = stream;
	
	// The rock
	res->rock = rock;
	
	// Tell the UI about this stream (though it never really needs to know about it)
	if (res->streamBuffer) {
		[res->streamBuffer registerStream: stream
							forIdentifier: res->identifier];
	} else if (res->buffered) {
		[cocoaglk_buffer registerStream: stream
						  forIdentifier: res->identifier];
	}
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}
	
	os_log_debug(GlkClientTrace, "glk_stream_open_file(%{public}p, %{public}u, %{public}u) = %{public}p", fileref, fmode, rock, res);
	
	return res;
}


// Gets a stream provided by the client with the specified key
strid_t cocoaglk_get_stream_for_key(const char* key) {
	static NSMutableDictionary* knownStreams = nil;
	
	if (!knownStreams) {
		knownStreams = [[NSMutableDictionary alloc] init];
	}
	
	// Try to fetch a previously retrieved stream from the known streams list
	NSString* strKey = [NSString stringWithUTF8String: key];
	NSValue* oldStream = [knownStreams objectForKey: strKey];
	
	if (oldStream) {
		return [oldStream pointerValue];
	}
	
	// Try fetching the stream from the session instead
	id<GlkStream> inputStream = [cocoaglk_session streamForKey: strKey];
	
	if (!inputStream) return NULL;
	
	// Create the stream
	strid_t res = cocoaglk_stream();
	
	// Stream should be buffered
	res->buffered = YES;
	res->streamBuffer = [[GlkBuffer alloc] init];
	
	// Set the file mode
	res->fmode = filemode_Read;
	
	// Set the stream object
	res->stream = [inputStream retain];
	
	// The rock
	res->rock = 0;
	
	// Tell the UI about this stream (though it never really needs to know about it)
	[cocoaglk_buffer registerStream: inputStream
					  forIdentifier: res->identifier];
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}
	
	os_log_debug(GlkClientTrace, "cocoaglk_get_input_stream() = %{public}p", res);
	
	// Store in in the known streams dictionary
	[knownStreams setObject: [NSValue valueWithPointer: res]
					 forKey: strKey];
	
	return res;
}

// Gets the input stream provided by the server (or NULL if none was provided)
strid_t cocoaglk_get_input_stream(void) {
	static strid_t instream = NULL;
	
	if (instream) {
		os_log_debug(GlkClientTrace, "cocoaglk_get_input_stream() = %{public}p", instream);

		return instream;
	}
	
	id<GlkStream> inputStream = [cocoaglk_session inputStream];
	
	if (!inputStream) return NULL;
	
	// Create the stream
	strid_t res = cocoaglk_stream();
	
	// Stream should be buffered
	res->buffered = YES;
	res->streamBuffer = [[GlkBuffer alloc] init];
	
	// Set the file mode
	res->fmode = filemode_Read;
	
	// Set the stream object
	res->stream = [inputStream retain];
	
	// The rock
	res->rock = 0;
	
	// Tell the UI about this stream (though it never really needs to know about it)
	[cocoaglk_buffer registerStream: inputStream
					  forIdentifier: res->identifier];
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}

	os_log_debug(GlkClientTrace, "cocoaglk_get_input_stream() = %{public}p", res);

	return instream=res;
}

///
/// You can open a stream which reads from or writes into a space in memory.
///
/// \c fmode must be \c filemode_Read , \c filemode_Write , or \c filemode_ReadWrite .
///
/// \c buf points to the buffer where output will be read from or written
/// to. buflen is the length of the buffer.
///
strid_t glk_stream_open_memory(char *buf, glui32 buflen, glui32 fmode,
							   glui32 rock) {
	// Sanity check
	if (fmode != filemode_Read &&
		fmode != filemode_Write &&
		fmode != filemode_WriteAppend &&
		fmode != filemode_ReadWrite) {
		cocoaglk_error("glk_stream_open_memory called with an invalid file mode");
	}
	
	if (fmode == filemode_WriteAppend) {
		cocoaglk_error("glk_stream_open_memory called with a file mode of WriteAppend, which is not valid for this stream type");
	}
	
	// Create the memory stream
	GlkMemoryStream* str = [[GlkMemoryStream alloc] initWithMemory: (unsigned char*) buf
															length: buflen
															  type: "&+#!Cn"];
	
	// Create the resulting stream
	strid_t res = cocoaglk_stream();
	
	// Stream is always unbuffered
	res->buffered = NO;
	
	// Set the file mode
	res->fmode = fmode;
	
	// Set the stream object
	res->stream = str;
	
	// The rock
	res->rock = rock;
	
	// Tell the UI about this stream (though it never really needs to know about)
	[cocoaglk_buffer registerStream: str
					  forIdentifier: res->identifier];
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}

	os_log_debug(GlkClientTrace, "glk_stream_open_memory(%{public}p, %{public}u, %{public}u, %{public}u) = %{public}p", buf, buflen, fmode, rock, res);
		
	// Return the result
	return res;
}


strid_t glk_stream_open_memory_uni(glui32 *buf, glui32 buflen,
								   glui32 fmode, glui32 rock) {
	// Sanity check
	if (fmode != filemode_Read &&
		fmode != filemode_Write &&
		fmode != filemode_WriteAppend &&
		fmode != filemode_ReadWrite) {
		cocoaglk_error("glk_stream_open_memory called with an invalid file mode");
	}
	
	if (fmode == filemode_WriteAppend) {
		cocoaglk_error("glk_stream_open_memory called with a file mode of WriteAppend, which is not valid for this stream type");
	}
	
	// Create the memory stream
	GlkMemoryStream* str = [[GlkMemoryStream alloc] initWithMemory: (unsigned char*) buf
															length: buflen*4
															  type: "&+#!Iu"];
	
	// Convert to UCS-4
	BOOL isBigEndian;
#ifdef __LITTLE_ENDIAN__
	isBigEndian = NO;
#else
# ifdef __BIG_ENDIAN__
	isBigEndian = YES;
# else
#  error Could not determine endianness
# endif
#endif
	GlkUcs4Stream* ucsStr = [[GlkUcs4Stream alloc] initWithStream: str
														bigEndian: isBigEndian];
	
	[str release];
	
	// Create the resulting stream
	strid_t res = cocoaglk_stream();
	
	// Stream is always unbuffered
	res->buffered = NO;
	
	// Set the file mode
	res->fmode = fmode;
	
	// Set the stream object
	res->stream = ucsStr;
	
	// The rock
	res->rock = rock;
	
	// Tell the UI about this stream (though it never really needs to know about)
	[cocoaglk_buffer registerStream: ucsStr
					  forIdentifier: res->identifier];
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Stream);
	}
	
	os_log_debug(GlkClientTrace, "glk_stream_open_memory(%{public}p, %{public}u, %{public}u, %{public}u) = %{public}p", buf, buflen, fmode, rock, res);
	
	// Return the result
	return res;
}

//
//// This closes the stream str. The result argument points to a structure
/// which is filled in with the final character counts of the stream. If
/// you do not care about these, you may pass \c NULL as the result argument.
///
/// If str is the current output stream, the current output stream is set
/// to \c NULL .
///
/// You cannot close window streams; use glk_window_close() instead. See
/// section 3.2, "Window Opening, Closing, and Constraints".
///
void glk_stream_close(strid_t str, stream_result_t *result) {
	os_log_debug(GlkClientTrace, "glk_stream_close(%{public}p, %{public}p)", str, result);

	// Sanity checks
	if (str == NULL) {
		cocoaglk_warning("glk_stream_close called with a NULL strid");
		return;
	}
	
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_close called with an invalid strid");
	}

	// Unregister the stream
	if (cocoaglk_unregister) {
		cocoaglk_unregister(str, gidisp_Class_Stream, str->giRock);
	}
	
	// Despite what the spec says above, we can actually close window streams (provided you never
	// close the window afterwards)
	
	if (str == cocoaglk_currentstream) cocoaglk_currentstream = NULL;
	
	// Tell the buffer we've closed down
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Tell the buffer to close the stream
		[buf closeStreamIdentifier: str->identifier];
	} else {
		// Just close it
		[str->stream closeStream];
		[buf unregisterStreamIdentifier: str->identifier];
	}
	
	// Fill in the result structure
	if (result) {
		result->readcount = str->read;
		result->writecount = str->written;
	}
	
	// If we're echoing anywhere, then stop it
	for (NSValue* echoingTo in str->echoesTo) {
		strid_t eStr = [echoingTo pointerValue];
		
		if (!cocoaglk_strid_sane(eStr)) {
			cocoaglk_error("glk_stream_close found a bad echoing stream");
		}
		
		if (eStr->echo != str) {
			cocoaglk_error("glk_stream_close found a stream that it thought was echoing to the closing stream, but turned out not to be");
		}
		
		eStr->echo = NULL;
	}

	// Remove from the list of streams
	if (str->next) {
		str->next->last = str->last; 
	}
	if (str->last) {
		str->last->next = str->next;
	} else {
		cocoaglk_firststream = str->next;
	}
	
	// Flush the buffer
	if (!str->lazyFlush) cocoaglk_flushstream(str, "Closing a stream");
	
	// Finish off the stream object
	[str->stream release]; str->stream = nil;
	[str->echoesTo release]; str->echoesTo = nil;
	[str->streamBuffer release]; str->streamBuffer = nil;
	
	str->key = 0;
	str->identifier = 0;
	
	free(str);
}

///
/// This iterates through all the existing streams.
///
strid_t glk_stream_iterate(strid_t str, glui32 *rockptr) {
	// Return the first stream if str is NULL
	if (str == NULL) {
		if (cocoaglk_firststream && rockptr) *rockptr = cocoaglk_firststream->rock;
		return cocoaglk_firststream;
	}
	
	// Sanity check
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_iterate called with an invalid strid");
	}

	// Return the next stream
	if (str->next && rockptr) *rockptr = str->next->rock;	

	os_log_debug(GlkClientTrace, "glk_stream_iterate(%{public}p, %{public}p=%{public}u) = %{public}p", str, rockptr, rockptr?*rockptr:0, str->next);
		
	return str->next;
}

///
/// This retrieves the stream's rock value. See section 1.6.1, "Rocks".
///
glui32 glk_stream_get_rock(strid_t str) {
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_get_rock called with an invalid strid");
	}

	os_log_debug(GlkClientTrace, "glk_stream_get_rock(%{public}p) = %{public}u", str, str->rock);
		
	return str->rock;
}

///
/// This sets the position of the mark. The position is controlled by pos,
/// and the meaning of pos is controlled by seekmode:
///
/// * seekmode_Start: pos characters after the beginning of the file.
/// * seekmode_Current: pos characters after the current position
///	 (moving backwards if pos is negative.)
/// * seekmode_End: pos characters after the end of the file. (pos should
///	 always be zero or negative, so that this will move backwards to a
///	 position within the file.)
///
/// It is illegal to specify a position before the beginning or after the
/// end of the file.
///
/// In binary files, the mark position is exact -- it corresponds with
/// the number of characters you have read or written. In text files, this
/// mapping can vary, because of linefeed conversions or other character-set
/// approximations. (See section 5, "Streams".) glk_stream_set_position()
/// and \c glk_stream_get_position() measure positions in the platform's native
/// encoding -- after character cookery. Therefore, in a text stream, it is
/// safest to use \c glk_stream_set_position() only to move to the beginning or
/// end of a file, or to a position determined by \c glk_stream_get_position() .
///
void glk_stream_set_position(strid_t str, glsi32 pos, glui32 seekmode) {
	os_log_debug(GlkClientTrace, "glk_stream_set_position(%{public}p, %{public}u, %{public}u)", str, pos, seekmode);
		
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_set_position called with a bad stream");
	}
		
	// Stream must have a connection available and be up-to-date
	cocoaglk_loadstream(str);
	if (str->fmode != filemode_Read) cocoaglk_flushstream(str, "Setting the stream position");
	
	int relative = 0;
	
	switch (seekmode) {
		case seekmode_Current: relative = GlkSeekCurrent; break;
		case seekmode_Start: relative = GlkSeekStart; break;
		case seekmode_End: relative = GlkSeekEnd; break;
		default:
			cocoaglk_error("glk_stream_set_position called with a bad value for seekmode");
	}
	
	[str->stream setPosition: pos
				  relativeTo: relative];
}

///
/// This returns the position of the mark. For memory streams and binary
/// file streams, this is exactly the number of bytes read or written
/// from the beginning of the stream (unless you have moved the mark with
/// \c glk_stream_set_position() .) For text file streams, matters are more
/// ambiguous, since (for example) writing one byte to a text file may store
/// more than one character in the platform's native encoding. You can only
/// be sure that the position increases as you read or write to the file.
///
glui32 glk_stream_get_position(strid_t str) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_get_position called with a bad stream");
	}
	
	// Stream must have a connection available and be up-to-date
	cocoaglk_loadstream(str);
	cocoaglk_flushstream(str, "Retrieving the position in the stream");
	
	glui32 res = (glui32)[str->stream getPosition];
	
	os_log_debug(GlkClientTrace, "glk_stream_get_position(%{public}p) = %{public}u", str, res);
		
	return res;
}

///
/// Glk has a notion of the "current (output) stream". If you print text
/// without specifying a stream, it goes to the current output stream. The
/// current output stream may be \c NULL , meaning that there isn't one. It is
/// illegal to print text to stream \c NULL , or to print to the current stream
/// when there isn't one.
///
/// If the stream which is the current stream is closed, the current stream
/// becomes \c NULL .
///
void glk_stream_set_current(strid_t str) {
	os_log_debug(GlkClientTrace, "glk_stream_set_current(%{public}p)", str);
	
	// Sanity checking
	if (str != NULL && !cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_stream_set_current called with a bad stream");
	}

	cocoaglk_currentstream = str;
}

strid_t glk_stream_get_current(void) {
	os_log_debug(GlkClientTrace, "glk_stream_get_current() = %{public}p", cocoaglk_currentstream);
	
	return cocoaglk_currentstream;
}

void glk_put_char(unsigned char ch) {
	glk_put_char_stream(cocoaglk_currentstream, ch);
}

void glk_put_string(char *s) {
	glk_put_string_stream(cocoaglk_currentstream, s);
}

void glk_put_buffer(char *buf, glui32 len) {
	glk_put_buffer_stream(cocoaglk_currentstream, buf, len);
}

void glk_set_style(glui32 styl) {
	glk_set_style_stream(cocoaglk_currentstream, styl);
}

void glk_put_char_stream(strid_t str, unsigned char ch) {
	os_log_debug(GlkClientTrace, "glk_put_char_stream(%{public}p, '%{public}c')", str, ch);
	
	if (!str) {
		cocoaglk_warning("glk_put_char_stream called with a NULL stream");
		return;
	}
	
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_put_char_stream called with a bad stream");
	}
	
	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("glk_put_char_stream called on a read-only stream");
	}
	
	GlkBuffer* buf = nil;
	
	if (str->echo) {
		// Echo this character
		glk_put_char_stream(str->echo, ch);
	}
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf putChar: ch
			toStream: str->identifier];

		str->bufferedAmount++;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream putChar: ch];
	}
	
	str->written++;
	
	cocoaglk_maybeflushstream(str, "Writing a character");
}

void glk_put_string_stream(strid_t str, char *s) {
	os_log_debug(GlkClientTrace, "glk_put_string_stream(%{public}p, \"%{public}s\")", str, s);
	
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_put_string_stream called with an invalid strid");
	}

	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("glk_put_string_stream called on a read-only stream");
	}
	
	if (str->echo) {
		// Echo this string
		glk_put_string_stream(str->echo, s);
	}

	NSString* string = [[NSString alloc] initWithBytes: s
												length: strlen(s)
											  encoding: NSISOLatin1StringEncoding];
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf putString: string
			  toStream: str->identifier];
		
		str->bufferedAmount += [string length];
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream putString: string];
	}
	
	str->written += [string length];
	
	[string release];

	cocoaglk_maybeflushstream(str, "Writing a string");
}

void glk_put_buffer_stream(strid_t str, char *buffer, glui32 len) {
	os_log_debug(GlkClientTrace, "glk_put_buffer_stream(%{public}p, %{public}p, %{public}u)", str, buffer, len);

	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_put_buffer_stream called with an invalid strid");
	}

	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("glk_put_buffer_stream called on a read-only stream");
	}
	
	if (str->echo) {
		// Echo this buffer
		glk_put_buffer_stream(str->echo, buffer, len);
	}
	
	NSData* data = [[NSData alloc] initWithBytes: buffer
										  length: len];
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf putData: data
			toStream: str->identifier];
		
		str->bufferedAmount += len;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream putBuffer: data];
	}
	
	str->written += [data length];
	
	[data release];

	cocoaglk_maybeflushstream(str, "Writing a buffer");
}

void glk_set_style_stream(strid_t str, glui32 styl) {
	os_log_debug(GlkClientTrace, "glk_set_style_stream(%{public}p, %{public}u)", str, styl);

	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_set_style_stream called with an invalid strid");
	}

	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("glk_set_style_stream called on a read-only stream");
	}
	
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf setStyle: styl
			 onStream: str->identifier];
		
		str->bufferedAmount++;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream setStyle: styl];
	}

	cocoaglk_maybeflushstream(str, "Setting a stream style");
}

///
/// This reads one character from the given stream. (There is no notion
/// of a "current input stream.") It is illegal for str to be \c NULL , or an
/// output-only stream.
///
/// The result will be between 0 and 255; as always, Glk assumes the Latin-1
/// encoding. See section 2, "Character Encoding". If the end of the stream
/// has been reached, the result will be -1. [[Note that high-bit characters
///	(128..255) are *not* returned as negative numbers.]]
///
glsi32 glk_get_char_stream(strid_t str) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_get_char_stream called with an invalid strid");
	}
	
	if (!cocoaglk_strid_read(str)) {
		cocoaglk_error("glk_get_char_stream called with a strid that cannot be read from");
	}
	
	// First, flush the stream
	cocoaglk_flushstream(str, "Retrieving a character");
	
	// Next, use the stream object to get our result
	unichar res = [str->stream getChar];

	os_log_debug(GlkClientTrace, "glk_get_char_stream(%{public}p) = %{public}i", str, res);
		
	if (res == GlkEOFChar) return -1;
	
	str->read++;
	return res;
}

/// This reads characters from the given stream, until either len-1 characters
/// have been read or a newline has been read. It then puts a terminal null
/// ('\0') character on the end. It returns the number of characters actually
/// read, including the newline (if there is one) but not including the
/// terminal null.
glui32 glk_get_line_stream(strid_t str, char *buf, glui32 len) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_get_line_stream called with an invalid strid");
	}
	
	if (!cocoaglk_strid_read(str)) {
		cocoaglk_error("glk_get_line_stream called with a strid that cannot be read from");
	}
	
	if (buf == NULL) {
		cocoaglk_error("glk_get_line_stream called with a NULL buffer");
	}
	
	// First, flush the stream
	cocoaglk_flushstream(str, "Retrieving a line of text");
	
	// Next, use the stream object to get our result
#if 0
	int pos = 0;
	
	unichar ch;
	while (pos < len-1) {
		ch = [str->stream getChar];
		
		if (ch == GlkEOFChar) break;
		buf[pos++] = ch;
		
		if (ch == '\n') break;
	}
	buf[pos] = 0;
	
	int length = pos;
#else
	NSString* line = [str->stream getLineWithLength: len-1 ];
	NSData* latin1 = [line dataUsingEncoding: NSISOLatin1StringEncoding
						allowLossyConversion: YES];
	
	NSInteger length = [latin1 length];
	
	if (length+1 > len) {
		// Trim the line if the buffer is not big enough (this shouldn't happen)
		os_log(GlkClientLog, "trimming line returned from getLineWithLength as it's longer than requested");
		length = len-1;
	}
	
	// Copy into the buffer
	if (buf) {
		memcpy(buf, [latin1 bytes], length);
	}
	buf[length] = 0;
#endif

	os_log_debug(GlkClientTrace, "glk_get_line_stream(%{public}p, %{public}p=\"%{public}s\", %{public}u) = %{public}ld", str, buf, buf, len, (long)length);
		
	// Return the result
	str->read += len;
	return (glui32)length;
}

/// This reads len characters from the given stream, unless the end of stream
/// is reached first. No terminal null is placed in the buffer. It returns
/// the number of characters actually read.
glui32 glk_get_buffer_stream(strid_t str, char *buf, glui32 len) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("glk_get_buffer_stream called with an invalid strid");
	}
	
	if (!cocoaglk_strid_read(str)) {
		cocoaglk_error("glk_get_buffer_stream called with a strid that cannot be read from");
	}
	
	if (buf == NULL) {
		cocoaglk_error("glk_get_buffer_stream called with a NULL buffer");
	}
 	
	// First, flush the stream
	cocoaglk_flushstream(str, "Retrieving a buffer");
	
	// Next, use the stream object to get our result
	NSData* data = [str->stream getBufferWithLength: len];
	
	NSInteger length = [data length];
	
	if (length > len) {
		os_log(GlkClientLog, "getBufferWithLength: returned more data than was asked for (trimming)");
		length = len;
	}
	
	// Copy into the buffer
	if (buf) {
		memcpy(buf, [data bytes], length);
	}
	
	os_log_debug(GlkClientTrace, "glk_get_buffer_stream(%{public}p, %{public}p, %{public}i) = %{public}ld", str, buf, len, (long)length);
		
	str->read += length;
	return (glui32)length;
}

strid_t glkunix_stream_open_pathname(char *pathname, glui32 textmode,
									 glui32 rock) {
	NSURL *fileURL = [NSURL fileURLWithFileSystemRepresentation:pathname isDirectory:NO relativeToURL:nil];
	frefid_t fileRef = cocoaglk_open_file(fileURL, textmode, rock);
	return glk_stream_open_file(fileRef, filemode_Read, rock);
}

#pragma mark - Custom styles

// Causes CocoaGlk to set a style hint immediately in the specified stream
void cocoaglk_set_immediate_style_hint(strid_t str, glui32 hint, glsi32 value) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("cocoaglk_set_immediate_style_hint called with an invalid strid");
	}
	
	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("cocoaglk_set_immediate_style_hint called on a read-only stream");
	}
	
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf setStyleHint: hint
				  toValue: value
				 inStream: str->identifier];
		
		str->bufferedAmount++;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream setImmediateStyleHint: hint
								   toValue: value];
	}
	
	cocoaglk_maybeflushstream(str, "Setting a stream style immediately");
}

// Causes CocoaGlk to clear a style hint immediately in the specified stream
void cocoaglk_clear_immediate_style_hint(strid_t str, glui32 hint) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("cocoaglk_clear_immediate_style_hint called with an invalid strid");
	}
	
	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("cocoaglk_clear_immediate_style_hint called on a read-only stream");
	}
	
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf clearStyleHint: hint
				   inStream: str->identifier];
		
		str->bufferedAmount++;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream clearImmediateStyleHint: hint];
	}
	
	cocoaglk_maybeflushstream(str, "Clearing a stream style immediately");
}

// Sets a set of Cocoa text attributes to merge with those set by the current style. Set this to nil to indicate that only the current style should be used.
void cocoaglk_set_custom_text_attributes(strid_t str, NSDictionary* attributes) {
	// Sanity checking
	if (!cocoaglk_strid_sane(str)) {
		cocoaglk_error("cocoaglk_set_custom_text_attributes called with an invalid strid");
	}
	
	if (!cocoaglk_strid_write(str)) {
		cocoaglk_error("cocoaglk_set_custom_text_attributes called on a read-only stream");
	}
	
	GlkBuffer* buf = nil;
	
	if (str->buffered) {
		// Get the buffer
		buf = str->streamBuffer;
		if (buf == nil) {
			buf = cocoaglk_buffer;
		}
	}
	
	if (buf) {
		// Write using the buffer
		[buf setCustomAttributes: attributes
						inStream: str->identifier];
		
		str->bufferedAmount++;
	} else {
		// Write direct
		cocoaglk_loadstream(str);
		
		[str->stream setCustomAttributes: attributes];
	}
	
	cocoaglk_maybeflushstream(str, "Clearing a stream style immediately");	
}
