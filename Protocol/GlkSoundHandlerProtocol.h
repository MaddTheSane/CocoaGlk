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

NS_SWIFT_NAME(GlkSoundHandlerProtocol)
@protocol GlkSoundHandler <NSObject>

- (nullable byref id<GlkSoundChannel>) createSoundChannelWithVolume: (glui32) vol NS_RETURNS_NOT_RETAINED;

- (oneway void)loadHintForSound: (glui32) snd flag: (glui32) hint;

- (nullable byref id<GlkSoundSource>) soundSource;
- (void) setSoundSource:(nullable byref id<GlkSoundSource>)source;
@property (weak, nullable) id<GlkSoundSource> soundSource;

@end

NS_ASSUME_NONNULL_END
