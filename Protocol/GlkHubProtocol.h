//
//  GlkHubProtocol.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 17/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import "GlkSessionProtocol.h"

///
/// Methods used to communicate with the hub object used by the main Glk server process.
///
NS_SWIFT_NAME(GlkHubProtocol)
@protocol GlkHub <NSObject>

// Setting up the connection
- (byref id<GlkSession>) createNewSession;
- (byref id<GlkSession>) createNewSessionWithHubCookie: (in bycopy NSString*) hubCookie;
- (byref id<GlkSession>) createNewSessionWithHubCookie: (in bycopy NSString*) hubCookie
										 sessionCookie: (in bycopy NSString*) sessionCookie;

@end
