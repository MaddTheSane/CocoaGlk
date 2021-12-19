//
//  GlkSoundHandlerProtocol.h
//  GlkSound
//
//  Created by C.W. Betts on 12/2/21.
//

#import <Foundation/Foundation.h>
#include <GlkView/glk.h>
#import <GlkView/GlkSoundChannelProtocol.h>
#import <GlkView/GlkSoundSourceProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// Methods used to communicate with the sound handler object used by the main Glk server process.
NS_SWIFT_NAME(GlkSoundHandlerProtocol)
@protocol GlkSoundHandler <NSObject>

/// Creates a new sound channel. See the \c GlkSoundChannel protocol for more information
/// \param vol The volume of the newly-created channel.
- (nullable byref id<GlkSoundChannel>) createSoundChannelWithVolume: (glui32) vol NS_RETURNS_NOT_RETAINED;

/// Loads/unloads the sound specified by \c snd .
///
/// The sound handler may also do nothing with this information.
/// \param snd the sound index to load/unload.
/// \param hint \c 0 to unload \c snd , \c 1 to load.
- (oneway void) loadHintForSound: (glui32) snd flag: (glui32) hint;

- (nullable byref id<GlkSoundSource>) soundSource;
- (void) setSoundSource:(nullable byref id<GlkSoundSource>)source;
/// Where we get our sound data from.
@property (nonatomic, strong, nullable) id<GlkSoundSource> soundSource;

@end

NS_ASSUME_NONNULL_END
