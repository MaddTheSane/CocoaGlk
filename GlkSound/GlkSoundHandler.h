//
//  GlkSoundHandler.h
//  Spatterlight
//
//  Created by Administrator on 2021-01-24.
//

#import <Foundation/Foundation.h>
#import <GlkView/glk.h>
#import <GlkView/GlkEvent.h>
#import <GlkView/GlkSoundHandlerProtocol.h>

@class GlkSoundChannel, GlkView, GlkSoundHandler;

typedef NS_ENUM(NSInteger, GlkSoundBlorbFormatType) {
	GlkSoundBlorbFormatNone,
    GlkSoundBlorbFormatMod,
	GlkSoundBlorbFormatOggVorbis,
	GlkSoundBlorbFormatFORM,
	GlkSoundBlorbFormatAIFF,
	GlkSoundBlorbFormatMP3,
	GlkSoundBlorbFormatWave,
	GlkSoundBlorbFormatMIDI,
};

#define FREE 1
#define BUSY 2

#define MAXSND 32

NS_ASSUME_NONNULL_BEGIN

@interface GlkSoundResource : NSObject

- (instancetype)initWithData:(NSData*)dat;

-(BOOL)load;

@property (copy, nullable) NSData *data;
@property GlkSoundBlorbFormatType type;

+ (GlkSoundBlorbFormatType)detectSoundFormatFromData:(NSData*)data;

@end


@interface GlkSoundHandler : NSObject <GlkSoundHandler>

@property (strong) NSMutableDictionary <NSNumber *, GlkSoundResource *> *resources;
@property (strong) NSMutableDictionary <NSNumber *, GlkSoundChannel *> *glkchannels;
@property (strong, nullable) GlkSoundChannel *music_channel;
@property NSUInteger restored_music_channel_id;
@property glui32 lastsoundresno;

@property (weak) id<GlkEventReceiver> glkctl;

- (GlkSoundBlorbFormatType)loadSoundResourceFromSound:(glui32)snd data:(NSData * _Nullable __autoreleasing * _Nonnull)buf;
- (GlkSoundBlorbFormatType)load_sound_resource:(unsigned int)snd length:(NSUInteger *)len data:(char * _Nonnull * _Nonnull)buf;
+ (NSString*)MIMETypeFromFormatType:(GlkSoundBlorbFormatType)format;

- (void)restartAll;
- (void)stopAllAndCleanUp;

- (int)handleNewSoundChannel:(glui32)volume;
- (void)handleDeleteChannel:(int)channel;
- (BOOL)handleFindSoundNumber:(glui32)resno;
- (void)handleSetVolume:(glui32)volume
                channel:(int)channel
               duration:(glui32)duration
                 notify:(glui32)notify;
- (void)handlePlaySoundOnChannel:(int)channel repeats:(glui32)repeats notify:(glui32)notify;
- (void)handleStopSoundOnChannel:(int)channel;
- (void)handlePauseOnChannel:(int)channel;
- (void)handleUnpauseOnChannel:(int)channel;

- (void)handleVolumeNotification:(glui32)notify;
- (void)handleSoundNotification:(glui32)notify withSound:(glui32)sound;

@end

NS_ASSUME_NONNULL_END
