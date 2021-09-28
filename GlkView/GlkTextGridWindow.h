//
//  GlkTextGridWindow.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 20/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GlkView/GlkWindow.h>
#import <GlkView/GlkTextWindow.h>

@interface GlkTextGridWindow : GlkTextWindow {
	/// The amount of line input that we have accepted so far
	int lineInputLength;
	
	/// Current character width/height
	int width,height;
	/// Current cursor position. Top left is 0,0.
	int xpos,ypos;
	
	/// The next input line to display
	NSString* nextInputLine;
}

@end
