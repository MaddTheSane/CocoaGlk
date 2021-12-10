//
//  GlkViewDefinitions.h
//  CocoaGlk
//
//  Created by C.W. Betts on 12/11/18.
//

#ifndef GlkViewDefinitions_h
#define GlkViewDefinitions_h

#include <TargetConditionals.h>
#if TARGET_OS_IPHONE
#define COCOAGLK_IPHONE 1
#endif

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

#ifdef COCOAGLK_IPHONE
#import <UIKit/UIKit.h>
#define GlkColor UIColor
#define GlkFont UIFont
#define GlkSuperImage UIImage
#define GlkSuperView UIView
#define GlkRectFill UIRectFill
#else
#import <AppKit/AppKit.h>
#define GlkColor NSColor
#define GlkFont NSFont
#define GlkSuperImage NSImage
#define GlkSuperView NSView
#define GlkRectFill NSRectFill
#endif

#endif /* GlkViewDefinitions_h */
