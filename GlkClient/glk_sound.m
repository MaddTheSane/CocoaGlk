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
#import <GlkSound/GlkSound.h>

static schanid_t cocoaglk_firstschanid = NULL;

struct glk_schannel_struct {
#define GlkSoundRefKey 'FSND'
	/// Used while sanity fleeble blurgle blorp
	unsigned int key;
	
	/// The fileref rock
	glui32 rock;
	/// The volume specified for this sound channel when it was created
	glui32 volume;
	
	/// The actual fileref object
	__strong id<GlkSoundDataSource> fileref;
	
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
		NSLog(@"Oops: fref has a previous fref but is marked as the first");
		return NO;
	}
	
	if (!ref->last && ref != cocoaglk_firstschanid) {
		NSLog(@"Oops: fref has no previous fref but is not the first");
		return NO;
	}
	
	return YES;
}

schanid_t glk_schannel_create(glui32 rock) {
	return glk_schannel_create_ext(rock, GLK_MAXVOLUME);
}

schanid_t glk_schannel_create_ext(glui32 rock, glui32 volume) {
	schanid_t res = malloc(sizeof(struct glk_schannel_struct));
	
	res->key = GlkSoundRefKey;
	res->rock = rock;
	res->volume = volume;
	
	res->fileref = nil;
	
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
	NSLog(@"TRACE: glk_schannel_destroy(%p)", res);
#endif
	[chan->fileref release];
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
	return chan->rock;
}

glui32 glk_schannel_play(schanid_t chan, glui32 snd) {
	return glk_schannel_play_ext(chan, snd, 1, 0);
}

glui32 glk_schannel_play_ext(schanid_t chan, glui32 snd, glui32 repeats,
							 glui32 notify) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_play or glk_schannel_play_ext called with an invalid schanid");
		return 0;
	}
	UndefinedFunction();
	return 0;
}

void glk_schannel_stop(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_stop called with an invalid schanid");
		return;
	}
	UndefinedFunction();
}

void glk_schannel_pause(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_pause called with an invalid schanid");
		return;
	}
	UndefinedFunction();
}

void glk_schannel_unpause(schanid_t chan) {
	if (!cocoaglk_schanid_sane(chan)) {
		cocoaglk_error("glk_schannel_unpause called with an invalid schanid");
		return;
	}
	UndefinedFunction();
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
	UndefinedFunction();
}

glui32 glk_schannel_play_multi(schanid_t *chanarray, glui32 chancount,
							   glui32 *sndarray, glui32 soundcount, glui32 notify) {
	glui32 i;
	glui32 successes = 0;

	for (i = 0; i < chancount; i++)
	{
		successes += glk_schannel_play_ext(chanarray[i], sndarray[i], 1, notify);
	}

	return successes;
}

void glk_sound_load_hint(glui32 snd, glui32 flag) {
	UndefinedFunction();
}
