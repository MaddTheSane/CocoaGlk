//
//  glk_sound.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 16/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#include "glk.h"
#import "glk_client.h"
#import "cocoaglk.h"
#include "gi_blorb.h"
#import <GlkView/GlkSoundChannelProtocol.h>
#import <GlkSound/GlkSound.h>

static schanid_t cocoaglk_firstschanid = NULL;
static BOOL soundSourceSet = NO;

//
// Tells the session object where to get its image from
//
void cocoaglk_set_sound_source(id<GlkSoundSource> soundSource) {
	soundSourceSet = YES;
	if (soundSource != nil) {
		[cocoaglk_session setSoundSource: soundSource];
	}
}

struct glk_schannel_struct {
#define GlkSoundRefKey 'FSND'
	/// Used while sanity fleeble blurgle blorp
	unsigned int key;
	
	/// The fileref rock
	glui32 rock;
	/// The volume specified for this sound channel when it was created
	glui32 volume;
	
	/// The actual channel object
	__strong id<GlkSoundChannel> channelref;
	
	/// Annoying gi_dispa rock
	gidispatch_rock_t giRock;
	
	/// The next fref in the list
	schanid_t next;
	/// The last fref in the list
	schanid_t last;
};


/// Check if \c ref is a 'valid' schanid
static BOOL cocoaglk_schanid_sane(schanid_t ref) {
	if (ref == NULL) return NO;
	if (ref->key != GlkSoundRefKey) return NO;
	
	// Programmer is a spoon type problems
	if (ref->last && ref == cocoaglk_firstschanid) {
		NSLog(@"Oops: schan has a previous schan but is marked as the first");
		return NO;
	}
	
	if (!ref->last && ref != cocoaglk_firstschanid) {
		NSLog(@"Oops: schan has no previous schan but is not the first");
		return NO;
	}
	
	return YES;
}

schanid_t glk_schannel_create(glui32 rock) {
	schanid_t result = glk_schannel_create_ext(rock, GLK_MAXVOLUME);
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_create(%u) = %p", rock, result);
#endif

	return result;
}

schanid_t glk_schannel_create_ext(glui32 rock, glui32 volume) {
	id<GlkSoundChannel> chan = [cocoaglk_session.soundHandler createSoundChannel];
	if (!chan) {
		return NULL;
	}
	schanid_t res = malloc(sizeof(struct glk_schannel_struct));
	
	res->key = GlkSoundRefKey;
	res->rock = rock;
	res->volume = volume;
	
	res->channelref = [chan retain];
	
	res->next = cocoaglk_firstschanid;
	res->last = NULL;
	if (cocoaglk_firstschanid) cocoaglk_firstschanid->last = res;
	cocoaglk_firstschanid = res;
	
	if (cocoaglk_register) {
		res->giRock = cocoaglk_register(res, gidisp_Class_Schannel);
	}

#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_create_ext(%u, %u) = %p", rock, volume, res);
#endif
		
	return res;
}

void glk_schannel_destroy(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_destroy called with an invalid schanid");
		return;
	}
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_destroy(%p)", chan);
#endif
	
	// Unregister the filereg
	if (cocoaglk_unregister) {
		cocoaglk_unregister(chan, gidisp_Class_Schannel, chan->giRock);
	}
	
	// Finish it off
	if (chan->last) chan->last->next = chan->next;
	if (chan->next) chan->next->last = chan->last;
	if (chan == cocoaglk_firstschanid) cocoaglk_firstschanid = chan->next;
	
	chan->last = NULL;
	chan->next = NULL;
	
	[chan->channelref close];
	[chan->channelref release];

	free(chan);
}

schanid_t glk_schannel_iterate(schanid_t chan, glui32 *rockptr) {
	schanid_t res = NULL;
	
	if (chan == NULL) {
		res = cocoaglk_firstschanid;
	} else {
		if (!cocoaglk_schanid_sane(chan)) {
			cocoaglk_error("glk_schannel_iterate called with an invalid frefid");
			return NULL;
		}
		
		res = chan->next;
	}
	
	if (res && !cocoaglk_schanid_sane(res)) {
		cocoaglk_error("glk_schannel_iterate moved to an invalid frefid");
		return NULL;
	}
	
	if (res && rockptr) *rockptr = res->rock;
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_iterate(%p, %p=%u) = %p", chan, rockptr, rockptr?*rockptr:0, res);
#endif
	
	return res;
}

glui32 glk_schannel_get_rock(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_get_rock called with an invalid schanid");
		return 0;
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_get_rock(%p) = %u", chan, chan->rock);
#endif
	
	return chan->rock;
}

glui32 glk_schannel_play(schanid_t chan, glui32 snd) {
	glui32 result = glk_schannel_play_ext(chan, snd, 1, 0);
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_play(%p, %u) = %u", chan, snd, result);
#endif

	return result;
}

glui32 glk_schannel_play_ext(schanid_t chan, glui32 snd, glui32 repeats,
							 glui32 notify) {
	if (!soundSourceSet) {
		cocoaglk_set_sound_source([[[GlkBlorbSoundSource alloc] init] autorelease]);
	}
	
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_play or glk_schannel_play_ext called with an invalid schanid");
		return 0;
	}
	
	glui32 returnVal = 0;
	
	id<GlkSoundSource> soundSrc = [cocoaglk_session soundSource];
	if (soundSrc) {
		NSData *dat = [soundSrc dataForSoundResource: snd];
		if (dat) {
			returnVal = [chan->channelref playSoundData: dat countOfRepeats: repeats notification: notify] ? 1 : 0;
		}
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_play_ext(%p, %u, %u, %u) = %u", chan, snd, repeats, notify, returnVal);
#endif

	return returnVal;
}

void glk_schannel_stop(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_stop called with an invalid schanid");
		return;
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_stop(%p)", chan);
#endif

	[chan->channelref stop];
}

void glk_schannel_pause(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_pause called with an invalid schanid");
		return;
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_pause(%p)", chan);
#endif

	[chan->channelref pause];
}

void glk_schannel_unpause(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_unpause called with an invalid schanid");
		return;
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_unpause(%p)", chan);
#endif

	[chan->channelref unpause];
}

void glk_schannel_set_volume(schanid_t chan, glui32 vol) {
	glk_schannel_set_volume_ext(chan, vol, 0, 0);
}

void glk_schannel_set_volume_ext(schanid_t chan, glui32 vol,
								 glui32 duration, glui32 notify) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_set_volume or glk_schannel_set_volume_ext called with an invalid schanid");
		return;
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_set_volume_ext(%p, %u, %u, %u)", chan, vol, duration, notify);
#endif

	[chan->channelref setVolume: vol duration: duration notification: notify];
}

glui32 glk_schannel_play_multi(schanid_t *chanarray, glui32 chancount,
							   glui32 *sndarray, glui32 soundcount, glui32 notify) {
	glui32 i;
	glui32 successes = 0;

	for (i = 0; i < chancount; i++)
	{
		successes += glk_schannel_play_ext(chanarray[i], sndarray[i], 1, notify);
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_schannel_play_multi(%p, %u, %p, %u, %u) = %u", chanarray, chancount, sndarray, soundcount, notify, successes);
#endif

	return successes;
}

void glk_sound_load_hint(glui32 snd, glui32 flag) {
	if (!soundSourceSet) {
		cocoaglk_set_sound_source([[[GlkBlorbSoundSource alloc] init] autorelease]);
	}
	
#if COCOAGLK_TRACE
	NSLog(@"TRACE: glk_sound_load_hint(%u, %u)", snd, flag);
#endif

	[cocoaglk_session.soundHandler loadHintForSound:snd flag:flag];
}

@implementation GlkBlorbSoundSource

- (id) init {
	self = [super init];
	
	if (self) {
		if (giblorb_get_resource_map() == NULL) {
			[self release];
			return nil;
		}
	}
	
	return self;
}

- (bycopy NSData*) dataForSoundResource: (glui32) sound {
	// Attempt to load the sound from the blorb resources
	giblorb_result_t res;
	giblorb_err_t    erm;
	
	erm = giblorb_load_resource(giblorb_get_resource_map(), giblorb_method_Memory, &res, giblorb_ID_Snd, sound);
	
	if (erm != giblorb_err_None) return nil;
	
	// Create the image data
	NSData* imgData = [NSData dataWithBytes: res.data.ptr
									 length: res.length];
	
	// Discard the sound loaded from memory
	giblorb_unload_chunk(giblorb_get_resource_map(), res.chunknum);
	
	// Return the result
	return imgData;
}

@end
