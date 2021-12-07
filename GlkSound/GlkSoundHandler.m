//
//  GlkSoundHandler.mm
//  Spatterlight
//
//  Created by Administrator on 2021-01-24.
//

#import "GlkSoundHandler.h"

#import "GlkSoundChannel.h"
#import "GlkMIDIChannel.h"
#import "GlkFakeSoundChannel.h"
#import <GlkView/GlkEvent.h>
#import <GlkView/GlkView.h>

#define SDL_CHANNELS 64
#define MAX_SOUND_RESOURCES 500

@implementation GlkSoundResource

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype)initWithData:(NSData *)dat {
    if (self = [super init]) {
        _data = [dat copy];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _data = [decoder decodeObjectOfClass:[NSData class] forKey:@"data"];
        _type = (GlkSoundBlorbFormatType)[decoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_data forKey:@"data"];
    [encoder encodeInteger:(NSInteger)_type forKey:@"type"];
}

-(BOOL)load {
    if (!_type) {
        _type = [self detect_sound_format];
        if (!_type) {
            NSLog(@"Unknown format");
            return NO;
        }
    }

    return YES;
}

+ (GlkSoundBlorbFormatType)detectSoundFormatFromData:(NSData*)_data
{
    const char *buf = (const char *)_data.bytes;
    const NSUInteger _length = _data.length;
    char str[30];
    if (_length > 29)
    {
        strncpy(str, buf, 29);
        str[29]='\0';
    } else {
        strncpy(str, buf, _length);
        str[_length - 1]='\0';
    }
    /* AIFF */
    if (_length > 4 && !memcmp(buf, "FORM", 4))
        return GlkSoundBlorbFormatFORM;

    /* WAVE */
    if (_length > 4 && !memcmp(buf, "WAVE", 4))
        return GlkSoundBlorbFormatWave;

    if (_length > 4 && !memcmp(buf, "RIFF", 4))
        return GlkSoundBlorbFormatWave;

    /* midi */
    if (_length > 4 && !memcmp(buf, "MThd", 4))
        return GlkSoundBlorbFormatMIDI;

    /* s3m */
    if (_length > 0x30 && !memcmp(buf + 0x2c, "SCRM", 4))
        return GlkSoundBlorbFormatMod;

    /* XM */
    if (_length > 20 && !memcmp(buf, "Extended Module: ", 17))
        return GlkSoundBlorbFormatMod;

    /* MOD */
    if (_length > 1084)
    {
        char resname[5];
        memcpy(resname, (buf) + 1080, 4);
        resname[4] = '\0';
        if (!strncmp(resname+1, "CHN", 3) ||        /* 4CHN, 6CHN, 8CHN */
            !strncmp(resname+2, "CN", 2) ||         /* 16CN, 32CN */
            !strncmp(resname, "M.K.", 4) || !strncmp(resname, "M!K!", 4) ||
            !strncmp(resname, "FLT4", 4) || !strncmp(resname, "CD81", 4) ||
            !strncmp(resname, "OKTA", 4) || !strncmp(resname, "    ", 4))
            return GlkSoundBlorbFormatMod;
    }

    /* ogg */
    if (_length > 4 && !memcmp(buf, "OggS", 4))
        return GlkSoundBlorbFormatOggVorbis;

    return GlkSoundBlorbFormatMP3;
}

- (GlkSoundBlorbFormatType)detect_sound_format
{
	return [[self class] detectSoundFormatFromData:_data];
}

@end

@implementation GlkSoundHandler {
    NSMutableDictionary <NSNumber *, GlkFakeSoundChannel *> *fakeGlkChannels;
}

@synthesize soundSource;

- (instancetype)init {
    self = [super init];
    if (self) {
        _resources = [NSMutableDictionary new];
        _glkchannels = [NSMutableDictionary new];
        fakeGlkChannels = [NSMutableDictionary new];
        _lastsoundresno = -1;
    }
    return self;
}

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
    _resources = [decoder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"resources"];
    _restored_music_channel_id = (NSUInteger)[decoder decodeIntForKey:@"music_channel"];
    _glkchannels = [decoder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"gchannels"];
    _lastsoundresno = [decoder decodeIntForKey:@"lastsoundresno"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_resources forKey:@"resources"];
    [encoder encodeInteger:(NSInteger)_music_channel.name forKey:@"music_channel"];
    [encoder encodeObject:_glkchannels forKey:@"gchannels"];
    [encoder encodeInteger:_lastsoundresno forKey:@"lastsoundresno"];
}

- (BOOL)soundIsLoaded:(NSInteger)soundId {
    GlkSoundResource *resource = _resources[@(soundId)];
    if (resource)
        return (resource.data != nil);
    return NO;
}

#pragma mark Glk request calls from GlkController

- (BOOL)handleFindSoundNumber:(glui32)resno {
    BOOL result = [self soundIsLoaded:resno];

    if (!result) {
        [_resources[@(resno)] load];
        result = [self soundIsLoaded:resno];
    }
    if (!result)
        _lastsoundresno = -1;
    else
        _lastsoundresno = resno;

    return result;
}

- (int)handleNewSoundChannel:(glui32)volume {
	int i;
    for (i = 0; i < MAXSND; i++)
    if (_glkchannels[@(i)] == nil)
        break;

    if (i == MAXSND)
        return -1;

    _glkchannels[@(i)] = [[GlkSoundChannel alloc] initWithHandler:self
                                                             name:i
                                                           volume:volume];
    return i;
}

- (void)handleDeleteChannel:(int)channel {
    if (_glkchannels[@(channel)]) {
        _glkchannels[@(channel)] = nil;
        fakeGlkChannels[@(channel)] = nil;
    }
}

- (void)handleSetVolume:(glui32)volume channel:(int)channel duration:(glui32)duration notify:(glui32)notify {
    GlkSoundChannel *glkchan = _glkchannels[@(channel)];
    if (glkchan) {
        [glkchan setVolume:volume duration:duration notification:notify];
    }
}

- (void)handlePlaySoundOnChannel:(int)channel repeats:(glui32)repeats notify:(glui32)notify {
    if (_lastsoundresno != -1) {
        GlkSoundChannel *glkchan = _glkchannels[@(channel)];
        if (glkchan) {
            if (_resources[@(_lastsoundresno)].type == GlkSoundBlorbFormatMIDI) {
                if (![glkchan isKindOfClass:[GlkMIDIChannel class]]) {
                    _glkchannels[@(channel)] = [[GlkMIDIChannel alloc] initWithHandler:self
                                                                               name:channel volume:0x10000];
                    [glkchan copyValues:_glkchannels[@(channel)]];
                    glkchan = _glkchannels[@(channel)];
                }
            } else if ([glkchan isKindOfClass:[GlkMIDIChannel class]]) {
                _glkchannels[@(channel)] = [[GlkSoundChannel alloc] initWithHandler:self
                                                                           name:channel volume:0x10000];
                [glkchan copyValues:_glkchannels[@(channel)]];
                glkchan = _glkchannels[@(channel)];
            }

            [glkchan playSound:_lastsoundresno countOfRepeats:repeats notification:notify];
        }
    }
}

- (void)handleStopSoundOnChannel:(int)channel {
    GlkSoundChannel *glkchan = _glkchannels[@(channel)];
    if (glkchan) {
        [glkchan stop];
    }
}

- (void)handlePauseOnChannel:(int)channel {
    GlkSoundChannel *glkchan = _glkchannels[@(channel)];
    if (glkchan) {
        [glkchan pause];
    }
}

- (void)handleUnpauseOnChannel:(int)channel {
    GlkSoundChannel *glkchan = _glkchannels[@(channel)];
    if (glkchan) {
        [glkchan unpause];
    }
}

- (void)restartAll {
    for (GlkSoundChannel *chan in _glkchannels.allValues) {
        chan.handler = self;
        [chan restartInternal];
    }
}

- (void)stopAllAndCleanUp {
    if (!_glkchannels.count)
        return;
    for (GlkSoundChannel* chan in _glkchannels.allValues) {
        [chan stop];
    }
}

#pragma mark Called from GlkSoundChannel

- (void)handleVolumeNotification:(unsigned int)notify {
    GlkEvent *gev = [[GlkEvent alloc] initWithType:evtype_VolumeNotify windowIdentifier:0 val1: notify];
    [_glkctl queueEvent:gev];
}

- (void)handleSoundNotification:(glui32)notify withSound:(glui32)sound {
	GlkEvent *gev = [[GlkEvent alloc] initWithType:evtype_SoundNotify windowIdentifier:0 val1: notify val2: sound];
    [_glkctl queueEvent:gev];
}

-(GlkSoundBlorbFormatType)loadSoundResourceFromSound:(glui32)snd data:(NSData *__autoreleasing*)buf {

    GlkSoundBlorbFormatType type = 	GlkSoundBlorbFormatNone;
    GlkSoundResource *resource = _resources[@(snd)];
    
    if (!resource) {
        NSData *dat = [self.soundSource dataForSoundResource:snd];
        if (dat) {
            resource = [[GlkSoundResource alloc] initWithData:dat];
            [resource load];
            _resources[@(snd)] = resource;
        }
    }

    if (resource)
    {
        if (!resource.data)
        {
            [resource load];
            if (!resource.data)
                return GlkSoundBlorbFormatNone;
        }
        *buf = resource.data;
        type = resource.type;
    }

    return type;
}

-(GlkSoundBlorbFormatType)load_sound_resource:(glui32)snd length:(NSUInteger *)len data:(char **)buf {
	NSData *outDat = nil;
	GlkSoundBlorbFormatType type = [self loadSoundResourceFromSound:snd data:&outDat];
	if (type != GlkSoundBlorbFormatNone) {
		*len = outDat.length;
		*buf = (char *)outDat.bytes;
	}
	
	return type;
}

- (byref nullable id<GlkSoundChannel>)createSoundChannelWithVolume:(glui32)vol {
    int chan = [self handleNewSoundChannel:vol];
    if (chan == -1) {
        return nil;
    }
    GlkFakeSoundChannel *fakeChan = [[GlkFakeSoundChannel alloc] initWithSoundChannel:chan handler:self];
    fakeGlkChannels[@(chan)] = fakeChan;
    return fakeChan;
}

- (oneway void)loadHintForSound:(glui32)snd flag:(glui32)hint {
    if (hint == 0) {
        [_resources removeObjectForKey:@(snd)];
    } else {
        NSData *dat = [self.soundSource dataForSoundResource:snd];
        if (dat) {
            GlkSoundResource *soundRsrc = [[GlkSoundResource alloc] initWithData:dat];
            [soundRsrc load];
            _resources[@(snd)] = soundRsrc;
        }
    }
}

+ (NSString *)MIMETypeFromFormatType:(GlkSoundBlorbFormatType)format {
    NSString *mimeString;
    switch (format)
    {
        case GlkSoundBlorbFormatFORM:
        case GlkSoundBlorbFormatAIFF:
            mimeString = @"aiff";
            break;
        case GlkSoundBlorbFormatWave:
            mimeString = @"wav";
            break;
        case GlkSoundBlorbFormatOggVorbis:
            mimeString = @"ogg-vorbis";
            break;
        case GlkSoundBlorbFormatMP3:
            mimeString = @"mp3";
            break;
        case GlkSoundBlorbFormatMod:
            mimeString = @"mod";
            break;
        case GlkSoundBlorbFormatMIDI:
            mimeString = @"midi";
            break;
            
        default:
            NSLog(@"schannel_play_ext: unknown resource type (%ld).", format);
            return nil;
    }

    return [NSString stringWithFormat:@"audio/%@", mimeString];
}

@end
