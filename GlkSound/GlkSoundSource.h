//
//  GlkSoundSource.h
//  GlkSound
//
//  Created by C.W. Betts on 12/4/21.
//

#import <Foundation/Foundation.h>
#import <GlkView/glk.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlkSoundResourceProtocol)
@protocol GlkSoundResource <NSObject>

-(BOOL)load;

- (bycopy nullable NSData*)data;
- (bycopy nullable NSString*)filename;
@property (readonly) NSUInteger offset;
@property (readonly) NSUInteger length;
@property (readonly) enum GlkSoundBlorbFormatType : NSInteger type;


@end


@protocol GlkSoundSource <NSObject>

/// Retrieve the image data for a specified resource
- (byref nullable id<GlkSoundResource>) dataForSoundResource: (glui32) image;

@end

NS_ASSUME_NONNULL_END
