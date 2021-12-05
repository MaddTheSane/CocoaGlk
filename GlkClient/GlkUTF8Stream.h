//
//  GlkUTF8Stream.h
//  GlkClient
//
//  Created by C.W. Betts on 12/5/21.
//

#import <Foundation/Foundation.h>

#import <GlkView/GlkStreamProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlkUTF8Stream : NSObject <GlkStream>

- (instancetype) initWithStream: (id<GlkStream>) dataStream;

@end

NS_ASSUME_NONNULL_END
