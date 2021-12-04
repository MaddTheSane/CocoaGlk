//
//  GlkSoundHandler.h
//  Spatterlight
//
//  Created by Administrator on 2021-01-24.
//

#import <Foundation/Foundation.h>
#import <GlkView/glk.h>
#import <GlkView/GlkEvent.h>

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

@interface GlkSoundFile : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (void)resolveBookmark;

@property (copy, nullable) NSData *bookmark;
@property (copy, nullable) NSURL *URL;
@property (weak) GlkSoundHandler *handler;

@end;


@interface GlkSoundResource : NSObject

- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset length:(NSUInteger)length;

-(BOOL)load;

@property (copy, nullable) NSData *data;
@property (strong, nullable) GlkSoundFile *soundFile;
@property (copy) NSString *filename;
@property NSUInteger offset;
@property NSUInteger length;
@property GlkSoundBlorbFormatType type;

+ (GlkSoundBlorbFormatType)detectSoundFormatFromData:(NSData*)data;

@end


@interface GlkSoundHandler : NSObject

@property (strong) NSMutableDictionary <NSNumber *, GlkSoundResource *> *resources;
@property (strong) NSMutableDictionary *sfbplayers;
@property (strong) NSMutableDictionary <NSNumber *, GlkSoundChannel *> *glkchannels;
@property (strong) NSMutableDictionary <NSString *, GlkSoundFile *> *files;
@property (strong, nullable) GlkSoundChannel *music_channel;
@property NSUInteger restored_music_channel_id;
@property glui32 lastsoundresno;

@property (weak) id<GlkEventReceiver> glkctl;

-(GlkSoundBlorbFormatType)loadSoundResourceFromSound:(glui32)snd data:(NSData * _Nullable __autoreleasing * _Nonnull)buf;
- (GlkSoundBlorbFormatType)load_sound_resource:(unsigned int)snd length:(NSUInteger *)len data:(char * _Nonnull * _Nonnull)buf;

- (void)restartAll;
- (void)stopAllAndCleanUp;

- (int)handleNewSoundChannel:(glui32)volume;
- (void)handleDeleteChannel:(glui32)channel;
- (BOOL)handleFindSoundNumber:(glui32)resno;
- (void)handleLoadSoundNumber:(glui32)resno
                         from:(NSString *)path
                       offset:(NSUInteger)offset
                       length:(NSUInteger)length;
- (void)handleSetVolume:(glui32)volume
                channel:(glui32)channel
               duration:(glui32)duration
                 notify:(glui32)notify;
- (void)handlePlaySoundOnChannel:(glui32)channel repeats:(glui32)repeats notify:(glui32)notify;
- (void)handleStopSoundOnChannel:(glui32)channel;
- (void)handlePauseOnChannel:(glui32)channel;
- (void)handleUnpauseOnChannel:(glui32)channel;

- (void)handleVolumeNotification:(glui32)notify;
- (void)handleSoundNotification:(glui32)notify withSound:(glui32)sound;

@end

NS_ASSUME_NONNULL_END
