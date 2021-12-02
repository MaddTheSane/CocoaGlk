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

struct glk_schannel_struct {
#define GlkSoundRefKey 'FSND'
	/// Used while sanity fleeble blurgle blorp
	unsigned int key;
	
	/// The fileref rock
	glui32 rock;
	/// The usage specified for this sound channel when it was created
	glui32 usage;
	
	/// The actual fileref object
//	__strong id<GlkFileRef> fileref;
	
	/// Annoying gi_dispa rock
	gidispatch_rock_t giRock;
	
	/// The next fref in the list
	schanid_t next;
	/// The last fref in the list
	schanid_t last;
};

#define GLK_MAXVOLUME 0x10000


schanid_t glk_schannel_create(glui32 rock) {
	return glk_schannel_create_ext(rock, GLK_MAXVOLUME);
}

schanid_t glk_schannel_create_ext(glui32 rock, glui32 volume) {
	UndefinedFunction();
	return NULL;
}

void glk_schannel_destroy(schanid_t chan) {
	UndefinedFunction();
}

schanid_t glk_schannel_iterate(schanid_t chan, glui32 *rockptr) {
	UndefinedFunction();
	return NULL;
}

glui32 glk_schannel_get_rock(schanid_t chan) {
	UndefinedFunction();
	return 0;
}

glui32 glk_schannel_play(schanid_t chan, glui32 snd) {
	return glk_schannel_play_ext(chan, snd, 1, 0);
}

glui32 glk_schannel_play_ext(schanid_t chan, glui32 snd, glui32 repeats,
							 glui32 notify) {
	UndefinedFunction();
	return 0;
}

void glk_schannel_stop(schanid_t chan) {
	UndefinedFunction();
}

void glk_schannel_pause(schanid_t chan) {
	UndefinedFunction();
}

void glk_schannel_unpause(schanid_t chan) {
	UndefinedFunction();
}

void glk_schannel_set_volume(schanid_t chan, glui32 vol) {
	glk_schannel_set_volume_ext(chan, vol, 0, 0);
}

void glk_schannel_set_volume_ext(schanid_t chan, glui32 vol,
								 glui32 duration, glui32 notify) {
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
