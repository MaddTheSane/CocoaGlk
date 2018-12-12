//
//  GlkView-iOS.m
//  GlkView-iOS
//
//  Created by C.W. Betts on 12/11/18.
//

#include <unistd.h>
#include <tgmath.h>

#import "GlkView.h"
#import "glk.h"

#import "GlkWindow.h"
#import "GlkPairWindow.h"
#import "GlkTextWindow.h"
#import "GlkTextGridWindow.h"
#import "GlkGraphicsWindow.h"
#import "GlkArrangeEvent.h"
#import "GlkFileRef.h"
#import "GlkHub.h"
#import "GlkFileStream.h"

@implementation GlkView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (bycopy nonnull NSString *)cancelLineEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	return @"";
}

- (void)clientHasFinished {
	
}

- (void)clientHasStarted:(pid_t)processId {
	
}

- (nullable NSObject<GlkFileRef> *)fileRefWithName:(in bycopy nonnull NSString *)name {
	return nil;
}

- (bycopy nullable NSArray<NSString *> *)fileTypesForUsage:(in bycopy nonnull NSString *)usage {
	return nil;
}

- (out byref nonnull id<GlkImageSource>)imageSource {
	return nil;
}

- (byref nonnull NSObject<GlkStream> *)inputStream {
	return nil;
}

- (void)logMessage:(in bycopy nonnull NSString *)message {
	
}

- (void)logMessage:(in bycopy nonnull NSString *)message withPriority:(int)priority {
	
}

- (glui32)measureStyle:(glui32)styl hint:(glui32)hint inWindow:(glui32)windowId {
	return 0;
}

- (bycopy nullable NSObject<GlkEvent> *)nextEvent {
	return nil;
}

- (void)performOperationsFromBuffer:(in bycopy nonnull GlkBuffer *)buffer {
	
}

- (void)promptForFilesForUsage:(in bycopy nonnull NSString *)usage forWriting:(BOOL)writing handler:(in byref nonnull NSObject<GlkFilePrompt> *)handler {
	
}

- (void)promptForFilesOfType:(in bycopy nonnull NSArray<NSString *> *)filetypes forWriting:(BOOL)writing handler:(in byref nonnull NSObject<GlkFilePrompt> *)handler {
	
}

- (void)setEventListener:(in byref nullable NSObject<GlkEventListener> *)listener {
	
}

- (void)setFileTypes:(in bycopy nonnull NSArray<NSString *> *)extensions forUsage:(in bycopy nonnull NSString *)usage {
	
}

- (void)setImageSource:(in byref nonnull id<GlkImageSource>)newSource {
	
}

- (void)showError:(in bycopy nonnull NSString *)error {
	
}

- (void)showWarning:(in bycopy nonnull NSString *)warning {
	
}

- (GlkCocoaSize)sizeForImageResource:(glui32)imageId {
	return CGSizeMake(0, 0);
}

- (GlkSize)sizeForWindowIdentifier:(unsigned int)windowId {
	GlkSize tmp;
	tmp.height=0;
	tmp.width=0;
	return tmp;
}

- (byref nullable NSObject<GlkStream> *)streamForKey:(in bycopy nonnull NSString *)key {
	return nil;
}

- (byref nullable NSObject<GlkStream> *)streamForWindowIdentifier:(unsigned int)windowId {
	return nil;
}

- (nullable NSObject<GlkFileRef> *)tempFileRef {
	return nil;
}

- (void)willSelect {
	
}

- (void)arrangeWindow:(glui32)identifier method:(glui32)method size:(glui32)size keyWindow:(glui32)keyIdentifier {
	
}

- (void)breakFlowInWindowWithIdentifier:(unsigned int)identifier {
	
}

- (void)cancelCharEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)cancelHyperlinkEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)cancelMouseEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)clearHyperlinkOnStream:(unsigned int)streamIdentifier {
	
}

- (void)clearStyleHint:(glui32)hint forStyle:(glui32)style windowType:(glui32)wintype {
	
}

- (void)clearStyleHint:(glui32)hint inStream:(glui32)streamIdentifier {
	
}

- (void)clearWindowIdentifier:(glui32)identifier {
	
}

- (void)clearWindowIdentifier:(glui32)identifier withBackgroundColour:(in bycopy UIColor *)bgColour {
	
}

- (void)closeStreamIdentifier:(unsigned int)streamIdentifier {
	
}

- (void)closeWindowIdentifier:(glui32)identifier {
	
}

- (void)createBlankWindowWithIdentifier:(glui32)identifier {
	
}

- (void)createGraphicsWindowWithIdentifier:(glui32)identifier {
	
}

- (void)createPairWindowWithIdentifier:(glui32)identifier keyWindow:(glui32)keyIdentifier leftWindow:(glui32)leftIdentifier rightWindow:(glui32)rightIdentifier method:(glui32)method size:(glui32)size {
	
}

- (void)createTextGridWindowWithIdentifier:(glui32)identifier {
	
}

- (void)createTextWindowWithIdentifier:(glui32)identifer {
	
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier alignment:(unsigned int)alignment {
	
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier alignment:(unsigned int)alignment size:(GlkCocoaSize)imageSize {
	
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier atPosition:(GlkPoint)position {
	
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier inRect:(GlkRect)imageRect {
	
}

- (void)fillAreaInWindowWithIdentifier:(unsigned int)identifier withColour:(in bycopy UIColor *)color rectangle:(GlkRect)windowArea {
	
}

- (void)moveCursorInWindow:(glui32)identifier toXposition:(int)xpos yPosition:(int)ypos {
	
}

- (void)putChar:(unichar)ch toStream:(unsigned int)streamIdentifier {
	
}

- (void)putData:(in bycopy NSData *)data toStream:(unsigned int)streamIdentifier {
	
}

- (void)putString:(in bycopy NSString *)string toStream:(unsigned int)streamIdentifier {
	
}

- (void)registerStream:(in byref NSObject<GlkStream> *)stream forIdentifier:(unsigned int)streamIdentifier {
	
}

- (void)registerStreamForWindow:(unsigned int)windowIdentifier forIdentifier:(unsigned int)streamIdentifier {
	
}

- (void)requestCharEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)requestHyperlinkEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)requestLineEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)requestMouseEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)setCustomAttributes:(NSDictionary *)attributes inStream:(glui32)streamIdentifier {
	
}

- (void)setHyperlink:(unsigned int)value onStream:(unsigned int)streamIdentifier {
	
}

- (void)setInputLine:(in bycopy NSString *)inputLine forWindowIdentifier:(unsigned int)windowIdentifier {
	
}

- (void)setRootWindow:(glui32)identifier {
	
}

- (void)setStyle:(unsigned int)style onStream:(unsigned int)streamIdentifier {
	
}

- (void)setStyleHint:(glui32)hint forStyle:(glui32)style toValue:(glsi32)value windowType:(glui32)wintype {
	
}

- (void)setStyleHint:(glui32)hint toValue:(glsi32)value inStream:(glui32)streamIdentifier {
	
}

- (void)unregisterStreamIdentifier:(unsigned int)streamIdentifier {
	
}

- (void)queueEvent:(GlkEvent *)evt {
	
}

@end
