//
//  GlkView-iOS.h
//  GlkView-iOS
//
//  Created by C.W. Betts on 12/11/18.
//

#import "GlkViewDefinitions.h"
#import <UIKit/UIKit.h>
#import <GlkView/GlkSessionProtocol.h>
#import <GlkView/GlkWindow.h>
#import <GlkView/GlkEvent.h>
#import <GlkView/GlkPreferences.h>
#import <GlkView/GlkStyle.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlkView : UIView <GlkSession, GlkBuffer, GlkEventReceiver>

- (void) automateStream: (NSObject<GlkStream>*) stream
			  forString: (NSString*) string;
@end

NS_ASSUME_NONNULL_END
