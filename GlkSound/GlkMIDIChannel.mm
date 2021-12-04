#import "GlkMIDIChannel.h"
#import "GlkSoundHandler.h"
#import "GlkMIDIPlayer.h"

@interface GlkMIDIChannel () {

@private
    GlkMIDIPlayer    *_player;        // The player instance
}

@end

@implementation GlkMIDIChannel

- (instancetype)initWithHandler:(GlkSoundHandler*)handler name:(glui32)channelname volume:(glui32)vol
{
	if (self = [super initWithHandler:handler name:channelname volume:vol]) {
	}
    
    return self;
}

- (void)play:(glui32)snd repeats:(glui32)areps notify:(glui32)anot
{
    self.status = CHANNEL_SOUND;

    char *buf = nil;
    size_t len = 0;
	GlkSoundBlorbFormatType type;

    /* stop previous noise */
    if (_player) {
        [_player stop];
    }
    
    if (areps == 0 || snd == -1)
        return;
    
    /* load sound resource into memory */
    type = [self.handler load_sound_resource:snd length:&len data:&buf];

    if (type != GlkSoundBlorbFormatMIDI)
        return;

    notify = anot;
    resid = snd;
    loop = areps;

    _player = [[GlkMIDIPlayer alloc] initWithData:[NSData dataWithBytes:buf length:len]];

    [_player setVolume:volume];

    if (areps != -1) {
        GlkMIDIChannel __weak *weakSelf = self;
        GlkSoundHandler *blockHandler = self.handler;
        NSInteger blocknotify = notify;
        NSInteger blockresid = resid;
        [_player addCallback:(^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                GlkMIDIChannel *strongSelf = weakSelf;
                if (strongSelf && --strongSelf->loop < 1) {
                    strongSelf.status = CHANNEL_IDLE;
                    if (blocknotify)
                        [blockHandler handleSoundNotification:blocknotify withSound:blockresid];
                }
            });
        })];
    }

   [_player loop:areps];

       if (!paused)
           [_player play];
}

- (void)stop
{
    paused = NO;
    if (_player) {
        [_player stop];
    }
    [self cleanup];
}

- (void)pause
{
    paused = YES;
    if (_player)
        [_player pause];
}

- (void)unpause
{
    paused = NO;
    if (!_player)
        [self play:resid repeats:loop notify:notify];
    else
        [_player play];
}

- (void)setVolume {
    if (!_player)
        return;
    [_player setVolume:volume];
}

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    self = [super initWithCoder:decoder];

    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

@end
