//
//  main.m
//  glkmain
//
//  Created by C.W. Betts on 10/11/21.
//

#import <Cocoa/Cocoa.h>

#include <stdlib.h>

#include <GlkView/glk.h>
#include <GlkClient/cocoaglk.h>
#include <GlkClient/glkstart.h>

static int inittime = FALSE;

static glkunix_startup_t removeCocoaGlkArgs(int argc, const char** argv);
static void cleanupGlkArgs(glkunix_startup_t *startdata);

int main(int argc, const char** argv) {
	glkunix_startup_t startdata;
	// Get everything running
	cocoaglk_start(argc, argv);
	
	/* Now some argument-parsing. This is probably going to hurt. */
	startdata = removeCocoaGlkArgs(argc, argv);

	/* sleep to give us time to attach a debugger */
	char *cugelwait = getenv("CUGELWAIT");
	if (cugelwait) {
		int cugelwaittime = atoi(cugelwait);
		if (cugelwaittime && cugelwaittime < 60) {
			sleep(cugelwaittime);
		}
	}
	
//	win_hello();

	inittime = TRUE;

	if (!glkunix_startup_code(&startdata)) {
		cleanupGlkArgs(&startdata);
		return 1;
	}
	inittime = FALSE;
	
	glk_main();
	cocoaglk_flushbuffer("About to finish");

	cleanupGlkArgs(&startdata);
	glk_exit();

	return 0;
}

glkunix_startup_t removeCocoaGlkArgs(int argc, const char** argv) {
	glkunix_startup_t startdata;
	startdata.argc = argc;
	startdata.argv = calloc(argc, sizeof(char*));
	startdata.argv[0] = strdup(argv[0]);
	int argpos = 1;
	for (int i = 1; i < argc-1; i++) {
		if (strcmp(argv[i], "-hubname") == 0 || strcmp(argv[i], "-hubcookie") == 0 || strcmp(argv[i], "-sessioncookie") == 0) {
			// Skip this parameter... and the next.
			i++;
			continue;
		}
		startdata.argv[argpos++] = strdup(argv[i]);
	}
	startdata.argc = argpos - 1;

	return startdata;
}

void cleanupGlkArgs(glkunix_startup_t *startdata) {
	for (int i = 0; i < startdata->argc; i++) {
		free(startdata->argv[i]);
	}
	free(startdata->argv);
}
