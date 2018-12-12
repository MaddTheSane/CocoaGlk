//
//  GlkTextView-iOS.h
//  GlkView-iOS
//
//  Created by C.W. Betts on 12/11/18.
//

#import <UIKit/UIKit.h>
#import <GlkView/GlkTypesetter.h>

NS_ASSUME_NONNULL_BEGIN

///
/// Class that implements our custom extensions to the text view (mainly character input and image drawing)
///
@interface GlkTextView : UITextView<GlkCustomTextLayout>

// Character input
/// Any characters sent to this window that can be handled by Glk will be passed to the superview
- (void) requestCharacterInput;
/// Cancels the previous
- (void) cancelCharacterInput;

@end

NS_ASSUME_NONNULL_END
