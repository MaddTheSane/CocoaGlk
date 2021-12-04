#import <Foundation/Foundation.h>
#import <GlkView/glk.h>

@class GlkSoundHandler, GlkMIDIChannel;

#define FADE_GRANULARITY 100
#define GLK_MAXVOLUME 0x10000
#define MIX_MAX_VOLUME 1.0f

NS_SWIFT_NAME(GlkSoundChannel.Status)
typedef NS_ENUM(NSInteger, GlkSoundChannelStatus) {
	GlkSoundChannelStatusIdle,
	GlkSoundChannelStatusSound
};

@interface GlkSoundChannel : NSObject <NSSecureCoding> {
	glui32 loop;
	glui32 notify;
	glui32 paused;

	glui32 resid; /* for notifies */

    NSString *mimeString;

    /* for volume fades */
	glui32 volume_notify;
	glui32 volume_timeout;
    CGFloat target_volume;
    CGFloat volume;
    CGFloat volume_delta;
    NSTimer *timer;
}

@property GlkSoundChannelStatus status;
@property glui32 name;
@property (weak) GlkSoundHandler *handler;

- (instancetype)initWithHandler:(GlkSoundHandler *)handler name:(glui32)name volume:(glui32)vol;
- (void)setVolume:(glui32)avol duration:(glui32)duration notify:(glui32)notify;
- (void)play:(glui32)snd repeats:(glui32)areps notify:(glui32)anot;
- (void)stop;
- (void)pause;
- (void)unpause;
- (void)cleanup;

- (void)copyValues:(GlkSoundChannel *)otherChannel;

- (void)restartInternal;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void) encodeWithCoder:(NSCoder *)encoder;

@end
