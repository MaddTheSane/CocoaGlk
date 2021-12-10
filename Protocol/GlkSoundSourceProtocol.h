//
//  GlkSoundSourceProtocol.h
//  GlkView
//
//  Created by C.W. Betts on 12/4/21.
//

#import <Foundation/Foundation.h>
#include <GlkView/glk.h>

NS_ASSUME_NONNULL_BEGIN

///
/// When we have sound resources, we need to be able to ask the client what they are. The client can provide
/// an object of this type to provide sound data in many of the formats that SFBAudioEngine can
/// understand.
///
/// By default, we use the \c gi_blorb_* functions to get sound resources. glk doesn't have a means for getting
/// images from other sources by default.
///
NS_SWIFT_NAME(GlkSoundSourceProtocol)
@protocol GlkSoundSource <NSObject>

/// Retrieve the sound data for a specified resource
- (nullable bycopy NSData*) dataForSoundResource: (glui32) sound;

@end

NS_ASSUME_NONNULL_END
