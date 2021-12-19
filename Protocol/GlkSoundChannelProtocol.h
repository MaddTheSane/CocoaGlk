//
//  GlkSoundChannelProtocol.h
//  GlkView
//
//  Created by C.W. Betts on 12/4/21.
//

#import <Foundation/Foundation.h>
#include <GlkView/glk.h>

NS_ASSUME_NONNULL_BEGIN

/// Methods used to communicate with the sound channel objects returned by the main Glk server process.
NS_SWIFT_NAME(GlkSoundChannelProtocol)
@protocol GlkSoundChannel <NSObject>

/// Stops the sound channel.
- (oneway void) stop;
/// Pauses the sound channel.
- (oneway void) pause;
/// Resumes the current channel.
- (oneway void) unpause;
/// Close and cleans up the sound channel. Trying to access the channel after this is called is undefined.
- (oneway void) close;
/// Sets the volume of the channel, optionally ramping up or down over time.
/// \param vol The new volume, from \e 0 to \e 0x10000 .
/// \param dur The duration, in milliseconds, over which the volume is changed. If \e 0 then the change is instantaneous.
/// \param noti The notification object sent at the end of the volume change, if any.
- (oneway void) setVolume: (glui32) vol duration: (glui32) dur notification: (glui32) noti;
/// Play the specified sound a selected number of times.
/// \param sound The sound index to play.
/// \param repeat The number of times the sound repeats. This must be greater than \e 0 in order to play any sound.
/// \param noti The notification object sent after the sound has played, if any.
/// \returns \c YES if playback was successful, \c NO otherwise.
- (BOOL) playSound: (glui32) sound countOfRepeats: (glui32) repeat notification: (glui32) noti;

@end

NS_ASSUME_NONNULL_END
