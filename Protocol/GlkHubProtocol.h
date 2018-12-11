//
//  GlkHubProtocol.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 17/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GlkSessionProtocol.h"

///
/// Methods used to communicate with the hub object used by the main Glk server process.
///
NS_SWIFT_NAME(GlkHubProtocol)
@protocol GlkHub <NSObject>

// Setting up the connection
- (nullable byref NSObject<GlkSession>*) createNewSession;
- (nullable byref NSObject<GlkSession>*) createNewSessionWithHubCookie: (nullable in bycopy NSString*) hubCookie;
- (nullable byref NSObject<GlkSession>*) createNewSessionWithHubCookie: (nullable in bycopy NSString*) hubCookie
														 sessionCookie: (nullable in bycopy NSString*) sessionCookie;

@end
