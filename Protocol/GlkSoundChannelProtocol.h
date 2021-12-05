//
//  GlkSoundChannelProtocol.h
//  GlkView
//
//  Created by C.W. Betts on 12/4/21.
//

#import <Foundation/Foundation.h>
#include <GlkView/glk.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlkSoundChannelProtocol)
@protocol GlkSoundChannel <NSObject>

- (oneway void) stop;
- (oneway void) pause;
- (oneway void) unpause;
- (oneway void) close;
- (oneway void) setVolume: (glui32) vol duration: (glui32) dur notification: (glui32) noti;
- (BOOL) playSound: (glui32) sound countOfRepeats: (glui32) repeat notification: (glui32) noti;

@end

NS_ASSUME_NONNULL_END
