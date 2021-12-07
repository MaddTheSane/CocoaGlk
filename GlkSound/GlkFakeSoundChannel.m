//
//  GlkFakeSoundChannel.m
//  GlkSound
//
//  Created by C.W. Betts on 12/6/21.
//

#import "GlkFakeSoundChannel.h"
#import "GlkSoundHandler.h"

@implementation GlkFakeSoundChannel {
	int channel;
	__weak GlkSoundHandler *_handler;
}

- (instancetype)initWithSoundChannel:(int)chan handler:(GlkSoundHandler*)handler {
	if (self = [super init]) {
		channel = chan;
		_handler = handler;
	}
	return self;
}

- (oneway void)close {
	[_handler handleDeleteChannel:channel];
}

- (oneway void)pause {
	[_handler handlePauseOnChannel:channel];
}

- (BOOL)playSound:(glui32)sound countOfRepeats:(glui32)repeat notification:(glui32)noti {
	if (![_handler handleFindSoundNumber:sound]) {
		return NO;
	}
	[_handler handlePlaySoundOnChannel:channel repeats:repeat notify:noti];
	// I guess it worked...
	return YES;
}

- (oneway void)setVolume:(glui32)vol duration:(glui32)dur notification:(glui32)noti {
	[_handler handleSetVolume:vol channel:channel duration:dur notify:noti];
}

- (oneway void)stop {
	[_handler handleStopSoundOnChannel:channel];
}

- (oneway void)unpause {
	[_handler handleUnpauseOnChannel:channel];
}

@end
