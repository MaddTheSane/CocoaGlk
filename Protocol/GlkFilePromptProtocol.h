//
//  GlkFilePromptProtocol.h
//  CocoaGlk
//
//  Created by Andrew Hunter on 28/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GlkFileRefProtocol.h"

///
/// Protocol used to get the results after we've requested a file prompt
///
@protocol GlkFilePrompt <NSObject>

/// Called when the user chooses a file
- (void) promptedFileRef: (in byref NSObject<GlkFileRef>*) fref;
/// Called when the user gives up on us
- (void) promptCancelled;

@end
