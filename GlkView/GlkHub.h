//
//  GlkHub.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 16/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkHubProtocol.h>
@protocol GlkHubDelegate;

NS_ASSUME_NONNULL_BEGIN

///
/// The hub is the first point that a client connects to the Glk server application.
///
///	The hub should be named, unless you want any random Glk application connecting. No hubs are available until a name has been
///		set.
///	Setting a hub cookie increases security, but you must communicate it to the client tasks somehow. Using a keychain cookie is
///		one way around this.
///	Always set the hub name after the cookie if you are using cookies.
///
/// Client tasks by default connect to the hub named CocoaGlk.
///
@interface GlkHub : NSObject<GlkHub> {
	// Hub data
	/// Name of the hub
	NSString* hubName;
	/// Hub cookie (clients must know this to connect)
	NSString* cookie;
	
	/// The delegate (used to create anonymous sessions)
	id<GlkHubDelegate> delegate;
	
	/// Sessions waiting for a connection (maps cookies to sessions)
	NSMutableDictionary* waitingSessions;
	
	// The connection
	/// The point at which the clients can connect to us
	NSConnection* connection;
}

// The shared hub

/// Creating your own hub is liable to be hairy and unsupported. You only need one per task anyway.
@property (class, readonly, retain) GlkHub *sharedGlkHub;

// Naming
/// The name of this GlkHub. Setting calls resetConnection.
@property (nonatomic, copy) NSString *hubName;
/// Auto-generates a name based on the process name
- (void) useProcessHubName;

// Security
/// Clients must know this in order to connect to the hub. \c nil by default.
@property (copy, nullable) NSString *hubCookie;
/// Auto-generates a cookie. Not cryptographically secure (yet).
- (void) setRandomHubCookie;
/// Auto-generates (if no cookie exists yet) and stores the hub cookie in the keychain.
- (void) setKeychainHubCookie;

// The connection
/// Starts listening for connections if we're not already
- (void) resetConnection;

// Registering sessions for later consumption
/// Registers a session with the given cookie. A client can request this specific session object (exactly one, though)
- (void) registerSession: (NSObject<GlkSession>*) session
			  withCookie: (NSString*) sessionCookie;
/// Unregisters a session previously registered with \c registerSession:withCookie:
- (void) unregisterSession: (NSObject<GlkSession>*)session;

// The delegate
@property (retain, nullable) id<GlkHubDelegate> delegate;

@end

// Hub delegate functions
@protocol GlkHubDelegate <NSObject>

/// Usually should return a GlkView. Called when a task starts with no session cookie
- (nullable NSObject<GlkSession>*) createAnonymousSession;

@end

NS_ASSUME_NONNULL_END
