//
//  SoundHandler.h
//  Spatterlight
//
//  Created by Administrator on 2021-01-24.
//

#import <Foundation/Foundation.h>

@class GlkSoundChannel, GlkView, SoundHandler;

typedef NS_ENUM(NSInteger, kBlorbSoundFormatType) {
    NONE,
    giblorb_ID_MOD,
    giblorb_ID_OGG,
    giblorb_ID_FORM,
    giblorb_ID_AIFF,
    giblorb_ID_MP3,
    giblorb_ID_WAVE,
    giblorb_ID_MIDI,
};

#define FREE 1
#define BUSY 2

#define MAXSND 32

NS_ASSUME_NONNULL_BEGIN

@interface SoundFile : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (void)resolveBookmark;

@property (copy, nullable) NSData *bookmark;
@property (copy, nullable) NSURL *URL;
@property (weak) SoundHandler *handler;

@end;


@interface SoundResource : NSObject

- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset length:(NSUInteger)length;

-(BOOL)load;

@property (copy, nullable) NSData *data;
@property (strong, nullable) SoundFile *soundFile;
@property (copy) NSString *filename;
@property NSUInteger offset;
@property NSUInteger length;
@property kBlorbSoundFormatType type;

@end


@interface SoundHandler : NSObject

@property (strong) NSMutableDictionary <NSNumber *, SoundResource *> *resources;
@property (strong) NSMutableDictionary *sfbplayers;
@property (strong) NSMutableDictionary <NSNumber *, GlkSoundChannel *> *glkchannels;
@property (strong) NSMutableDictionary <NSString *, SoundFile *> *files;
@property (strong, nullable) GlkSoundChannel *music_channel;
@property NSUInteger restored_music_channel_id;
@property NSInteger lastsoundresno;

@property (weak) GlkView *glkctl;

- (kBlorbSoundFormatType)load_sound_resource:(unsigned int)snd length:(NSUInteger *)len data:(char * _Nonnull * _Nonnull)buf;

- (void)restartAll;
- (void)stopAllAndCleanUp;

- (int)handleNewSoundChannel:(int)volume;
- (void)handleDeleteChannel:(int)channel;
- (BOOL)handleFindSoundNumber:(int)resno;
- (void)handleLoadSoundNumber:(int)resno
                         from:(NSString *)path
                       offset:(NSUInteger)offset
                       length:(NSUInteger)length;
- (void)handleSetVolume:(int)volume
                channel:(int)channel
               duration:(int)duration
                 notify:(int)notify;
- (void)handlePlaySoundOnChannel:(int)channel repeats:(int)repeats notify:(int)notify;
- (void)handleStopSoundOnChannel:(int)channel;
- (void)handlePauseOnChannel:(int)channel;
- (void)handleUnpauseOnChannel:(int)channel;

- (void)handleVolumeNotification:(unsigned int)notify;
- (void)handleSoundNotification:(unsigned int)notify withSound:(unsigned int)sound;

@end

NS_ASSUME_NONNULL_END
