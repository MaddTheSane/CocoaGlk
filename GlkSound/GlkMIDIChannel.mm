#import "GlkMIDIChannel.h"
#import "GlkSoundHandler.h"
#import "GlkMIDIPlayer.h"

@interface GlkMIDIChannel () {

@private
    GlkMIDIPlayer    *_player;        // The player instance
}

@end

@implementation GlkMIDIChannel

- (instancetype)initWithHandler:(GlkSoundHandler*)handler name:(int)channelname volume:(glui32)vol
{
	if (self = [super initWithHandler:handler name:channelname volume:vol]) {
	}
    
    return self;
}

- (BOOL)playSound:(glui32)snd countOfRepeats:(glui32)areps notification:(glui32)anot
{
    self.status = GlkSoundChannelStatusSound;

    NSData *dat = nil;
	GlkSoundBlorbFormatType type;

    /* stop previous noise */
    if (_player) {
        [_player stop];
    }
    
    if (areps == 0 || snd == -1)
        return NO;
    
    /* load sound resource into memory */
    type = [self.handler loadSoundResourceFromSound:snd data:&dat];

    if (type != GlkSoundBlorbFormatMIDI)
        return NO;

    notify = anot;
    resid = snd;
    loop = areps;

    _player = [[GlkMIDIPlayer alloc] initWithData:dat];

    [_player setVolume:volume];

    if (areps != -1) {
        GlkMIDIChannel __weak *weakSelf = self;
        GlkSoundHandler *blockHandler = self.handler;
        glui32 blocknotify = notify;
        glui32 blockresid = resid;
        [_player addCallback:(^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                GlkMIDIChannel *strongSelf = weakSelf;
                if (strongSelf && --strongSelf->loop < 1) {
                    strongSelf.status = GlkSoundChannelStatusIdle;
                    if (blocknotify)
                        [blockHandler handleSoundNotification:blocknotify withSound:blockresid];
                }
            });
        })];
    }

   [_player loop:areps];

       if (!paused)
           [_player play];
    return YES;
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
        [self playSound:resid countOfRepeats:loop notification:notify];
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
