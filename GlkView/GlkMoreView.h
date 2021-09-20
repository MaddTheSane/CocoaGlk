//
//  GlkMoreView.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 09/10/2006.
//  Copyright 2006 Andrew Hunter. All rights reserved.
//

#import <GlkView/GlkViewDefinitions.h>
#if defined(COCOAGLK_IPHONE)
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif


@interface GlkMoreView : GlkSuperView {
	GlkSuperImage* moreImage;
}

@end
