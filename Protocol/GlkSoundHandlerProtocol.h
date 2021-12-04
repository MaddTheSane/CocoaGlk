//
//  GlkSoundHandlerProtocol.h
//  GlkSound
//
//  Created by C.W. Betts on 12/2/21.
//

#import <Foundation/Foundation.h>
#include <GlkView/glk.h>
#import <GlkView/GlkSoundChannelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlkSoundHandlerProtocol)
@protocol GlkSoundHandler <NSObject>

- (nullable byref id<GlkSoundChannel>) createSoundChannel NS_RETURNS_NOT_RETAINED;

- (oneway void)loadHintForSound: (glui32) snd flag: (glui32) hint;

@end

NS_ASSUME_NONNULL_END
