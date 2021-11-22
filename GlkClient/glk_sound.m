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
	UndefinedFunction();
	return 0;
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
	UndefinedFunction();
	return 0;
}

void glk_sound_load_hint(glui32 snd, glui32 flag) {
	UndefinedFunction();
}
