//
//  GlkEvent.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 22/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GlkView/GlkSessionProtocol.h>

///
/// Generic Glk event class
///
@interface GlkEvent : NSObject<NSCoding, GlkEvent> {
	// Event parameters
	unsigned type;
	unsigned windowId;
	unsigned val1;
	unsigned val2;
	
	// 'Out-of-band' data
	/// When a line event is requested, this contains the string that eventually ends up in the buffer
	NSString* lineInput;
}

- (instancetype) initWithType: (unsigned) type
			 windowIdentifier: (unsigned) windowId;
- (instancetype) initWithType: (unsigned) type
			 windowIdentifier: (unsigned) windowId
						 val1: (unsigned) val1;
- (instancetype) initWithType: (unsigned) type
			 windowIdentifier: (unsigned) windowId
						 val1: (unsigned) val1
						 val2: (unsigned) val2;

@property (copy) NSString *lineInput;

@end

///
/// Protocol used to send events from objects like windows to a target
///
@protocol GlkEventReceiver <NSObject>

/// Request that an event be processed
- (void) queueEvent: (GlkEvent*) evt;

@end
