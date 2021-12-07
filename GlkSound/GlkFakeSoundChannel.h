//
//  GlkFakeSoundChannel.h
//  GlkSound
//
//  Created by C.W. Betts on 12/6/21.
//

#import <Foundation/Foundation.h>
#import <GlkView/GlkSoundChannelProtocol.h>

@class GlkSoundHandler;

NS_ASSUME_NONNULL_BEGIN

@interface GlkFakeSoundChannel : NSObject <GlkSoundChannel>

- (instancetype)initWithSoundChannel:(int)chan handler:(GlkSoundHandler*)handler;
@end

NS_ASSUME_NONNULL_END
