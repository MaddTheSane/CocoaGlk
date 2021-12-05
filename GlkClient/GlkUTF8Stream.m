//
//  GlkUTF8Stream.m
//  GlkClient
//
//  Created by C.W. Betts on 12/5/21.
//

#import "GlkUTF8Stream.h"
#import "glk_client.h"

static int countUTF8Len(unsigned char charPoint) {
	if ((charPoint & 0x80) == 0) {
		// Just this character
		return 1;
	} else if ((charPoint & 0xE0) == 0xC0) {
		return 2;
	} else if ((charPoint & 0xF0) == 0xE0) {
		return 3;
	} else if ((charPoint & 0xF8) == 0xF0) {
		return 4;
	}
	//Anything else isn't up to spec
	abort();
	return -1;
}

@implementation GlkUTF8Stream {
	/// The stream that gets the results of writing to this stream
	id<GlkStream> dataStream;
}

- (id) initWithStream: (id<GlkStream>) stream {
	self = [super init];
	
	if (self) {
		dataStream = stream;
	}
	
	return self;
}

#pragma mark Control

- (void) closeStream {
	[dataStream closeStream];
}

- (void) setPosition: (in NSInteger) position
		  relativeTo: (in GlkSeekMode) seekMode {
	[dataStream setPosition: position
				 relativeTo: seekMode];
}

- (unsigned long long) getPosition {
	return [dataStream getPosition];
}

#pragma mark Writing

- (void) putChar: (in unichar) ch {
	[self putString: [NSString stringWithCharacters: &ch
											 length: 1]];
}

- (void) putString: (in bycopy NSString*) string {
	NSData *strData = [string dataUsingEncoding:NSUTF8StringEncoding];
	if (strData) {
		[self putBuffer:strData];
		return;
	}
}

- (void) putBuffer: (in bycopy NSData*) buffer {
	[dataStream putBuffer: buffer];
}

#pragma mark Reading

- (unichar) getChar {
	NSData* charData = [self getBufferWithLength: 1];
	if ([charData length] != 1) {
		return GlkEOFChar;
	}
	unsigned char charByte = *((const unsigned char*)charData.bytes);
	if ((charByte & 0xE0) == 0xC0) {
		// 2-char encoding
		unichar res = (charByte & 0x1F) << 6;
		charData = [self getBufferWithLength: 1];
		if ([charData length] != 1) {
			return GlkEOFChar;
		}
		charByte = *((const unsigned char*)charData.bytes);
		res |= (charByte & 0x3F);
		return res;
	} else if ((charByte & 0xF0) == 0xE0) {
		// 3-char encoding
		unichar res = (charByte & 0x0F) << 16;
		charData = [self getBufferWithLength: 2];
		if ([charData length] != 2) {
			return GlkEOFChar;
		}
		charByte = ((const unsigned char*)charData.bytes)[0];
		res |= (charByte & 0x3F) << 6;
		charByte = ((const unsigned char*)charData.bytes)[1];
		res |= (charByte & 0x3F);
		return res;
	} else if ((charByte & 0x80) == 0) {
		// 1-char encoding
		return charByte;
	} else {
		// anything else is too big for one UTF16 character
		// still, read the whole Unicode character anyway.
		// TODO: Update when 5 bytes are added to the UTF-8 spec.
		charData = [self getBufferWithLength: 3];
		if ([charData length] != 3) {
			return GlkEOFChar;
		}

		return '?';
	}
}

- (bycopy NSString*) getLineWithLength: (NSInteger) maxLen {
	char* line = NULL;
	int lineLength = 0;
	int lineAllocated = 0;
	
	for (NSInteger uniLen = 0; uniLen <= maxLen; uniLen++) {
		// Read the next character
		NSData* charData = [self getBufferWithLength: 1];
		if ([charData length] != 1) break;
		
		// Append to the result
		if (lineLength+4 > lineAllocated) {
			lineAllocated = lineLength + 256;
			line = realloc(line, sizeof(char)*lineAllocated);
		}
		
		const unsigned char ucs1 = *((const unsigned char*)[charData bytes]);
		int charsLen = countUTF8Len(ucs1);
		if (charsLen > 1) {
			int extraChars = charsLen - 1;
			// make sure we have all the needed bytes:
			charData = [self getBufferWithLength: extraChars];
			if (charData.length != extraChars) {
				//end-of-stream reached
				break;
			}
			line[lineLength++] = ucs1;
			const unsigned char *ucs4 = [charData bytes];
			for (int i = 0; i < extraChars ; i++) {
				line[lineLength++] = ucs4[i];
			}
			// Skip new-line check
			continue;
		} else {
			line[lineLength++] = ucs1;
		}
		
		// Check if it is a \n or a \r
		if ((ucs1 == '\n' || ucs1 == '\r')) {
			break;
		}
	}
	
	// Convert to a NSString
	NSString* res = [[NSString alloc] initWithBytesNoCopy: line
												   length: lineLength
												 encoding: NSUTF8StringEncoding
											 freeWhenDone: YES];
	
	if (!res) {
		// Get something back.
		res = [[NSString alloc] initWithBytes: line
									   length: lineLength
									 encoding: NSMacOSRomanStringEncoding];
		free(line);
	}
	
	return res;
}

- (bycopy NSData*) getBufferWithLength: (NSUInteger) length {
	return [dataStream getBufferWithLength: length];
}

#pragma mark Styles

- (void) setStyle: (int) styleId {
	[dataStream setStyle: styleId];
}

- (int) style {
	return [dataStream style];
}

- (void) setImmediateStyleHint: (unsigned) hint
					   toValue: (int) value {
	[dataStream setImmediateStyleHint: hint
							  toValue: value];
}

- (void) clearImmediateStyleHint: (unsigned) hint {
	[dataStream clearImmediateStyleHint: hint];
}

- (void) setCustomAttributes: (NSDictionary*) customAttributes {
	[dataStream setCustomAttributes: customAttributes];
}

#pragma mark Hyperlinks

- (void) setHyperlink: (unsigned int) value {
	[dataStream setHyperlink: value];
}

- (void) clearHyperlink {
	[dataStream clearHyperlink];
}


@end
