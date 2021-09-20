//
//  GlkArrangeEvent.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 22/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <GlkView/GlkViewDefinitions.h>
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import <GlkView/GlkEvent.h>
#import <GlkView/GlkWindow.h>

@interface GlkArrangeEvent : GlkEvent

- (instancetype) initWithGlkWindow: (GlkWindow*) window;

@end
