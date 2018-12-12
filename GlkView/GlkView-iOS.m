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
	<#code#>
}

- (void)clientHasStarted:(pid_t)processId {
	<#code#>
}

- (nullable NSObject<GlkFileRef> *)fileRefWithName:(in bycopy nonnull NSString *)name {
	return nil;
}

- (bycopy nullable NSArray<NSString *> *)fileTypesForUsage:(in bycopy nonnull NSString *)usage {
	return nil;
}

- (out byref nonnull id<GlkImageSource>)imageSource {
	<#code#>
}

- (byref nonnull NSObject<GlkStream> *)inputStream {
	<#code#>
}

- (void)logMessage:(in bycopy nonnull NSString *)message {
	<#code#>
}

- (void)logMessage:(in bycopy nonnull NSString *)message withPriority:(int)priority {
	<#code#>
}

- (glui32)measureStyle:(glui32)styl hint:(glui32)hint inWindow:(glui32)windowId {
	return 0;
}

- (bycopy nullable NSObject<GlkEvent> *)nextEvent {
	return nil;
}

- (void)performOperationsFromBuffer:(in bycopy nonnull GlkBuffer *)buffer {
	<#code#>
}

- (void)promptForFilesForUsage:(in bycopy nonnull NSString *)usage forWriting:(BOOL)writing handler:(in byref nonnull NSObject<GlkFilePrompt> *)handler {
	<#code#>
}

- (void)promptForFilesOfType:(in bycopy nonnull NSArray<NSString *> *)filetypes forWriting:(BOOL)writing handler:(in byref nonnull NSObject<GlkFilePrompt> *)handler {
	<#code#>
}

- (void)setEventListener:(in byref nullable NSObject<GlkEventListener> *)listener {
	<#code#>
}

- (void)setFileTypes:(in bycopy nonnull NSArray<NSString *> *)extensions forUsage:(in bycopy nonnull NSString *)usage {
	<#code#>
}

- (void)setImageSource:(in byref nonnull id<GlkImageSource>)newSource {
	<#code#>
}

- (void)showError:(in bycopy nonnull NSString *)error {
	<#code#>
}

- (void)showWarning:(in bycopy nonnull NSString *)warning {
	<#code#>
}

- (GlkCocoaSize)sizeForImageResource:(glui32)imageId {
	return CGSizeMake(0, 0);
}

- (GlkSize)sizeForWindowIdentifier:(unsigned int)windowId {
	<#code#>
}

- (byref nullable NSObject<GlkStream> *)streamForKey:(in bycopy nonnull NSString *)key {
	<#code#>
}

- (byref nullable NSObject<GlkStream> *)streamForWindowIdentifier:(unsigned int)windowId {
	<#code#>
}

- (nullable NSObject<GlkFileRef> *)tempFileRef {
	<#code#>
}

- (void)willSelect {
	<#code#>
}

- (void)arrangeWindow:(glui32)identifier method:(glui32)method size:(glui32)size keyWindow:(glui32)keyIdentifier {
	<#code#>
}

- (void)breakFlowInWindowWithIdentifier:(unsigned int)identifier {
	<#code#>
}

- (void)cancelCharEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)cancelHyperlinkEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)cancelMouseEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)clearHyperlinkOnStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)clearStyleHint:(glui32)hint forStyle:(glui32)style windowType:(glui32)wintype {
	<#code#>
}

- (void)clearStyleHint:(glui32)hint inStream:(glui32)streamIdentifier {
	<#code#>
}

- (void)clearWindowIdentifier:(glui32)identifier {
	<#code#>
}

- (void)clearWindowIdentifier:(glui32)identifier withBackgroundColour:(in bycopy UIColor *)bgColour {
	<#code#>
}

- (void)closeStreamIdentifier:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)closeWindowIdentifier:(glui32)identifier {
	<#code#>
}

- (void)createBlankWindowWithIdentifier:(glui32)identifier {
	<#code#>
}

- (void)createGraphicsWindowWithIdentifier:(glui32)identifier {
	<#code#>
}

- (void)createPairWindowWithIdentifier:(glui32)identifier keyWindow:(glui32)keyIdentifier leftWindow:(glui32)leftIdentifier rightWindow:(glui32)rightIdentifier method:(glui32)method size:(glui32)size {
	<#code#>
}

- (void)createTextGridWindowWithIdentifier:(glui32)identifier {
	<#code#>
}

- (void)createTextWindowWithIdentifier:(glui32)identifer {
	<#code#>
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier alignment:(unsigned int)alignment {
	<#code#>
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier alignment:(unsigned int)alignment size:(GlkCocoaSize)imageSize {
	<#code#>
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier atPosition:(GlkPoint)position {
	<#code#>
}

- (void)drawImageWithIdentifier:(unsigned int)imageIdentifier inWindowWithIdentifier:(unsigned int)windowIdentifier inRect:(GlkRect)imageRect {
	<#code#>
}

- (void)fillAreaInWindowWithIdentifier:(unsigned int)identifier withColour:(in bycopy UIColor *)color rectangle:(GlkRect)windowArea {
	<#code#>
}

- (void)moveCursorInWindow:(glui32)identifier toXposition:(int)xpos yPosition:(int)ypos {
	<#code#>
}

- (void)putChar:(unichar)ch toStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)putData:(in bycopy NSData *)data toStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)putString:(in bycopy NSString *)string toStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)registerStream:(in byref NSObject<GlkStream> *)stream forIdentifier:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)registerStreamForWindow:(unsigned int)windowIdentifier forIdentifier:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)requestCharEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)requestHyperlinkEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)requestLineEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)requestMouseEventsForWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)setCustomAttributes:(NSDictionary *)attributes inStream:(glui32)streamIdentifier {
	<#code#>
}

- (void)setHyperlink:(unsigned int)value onStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)setInputLine:(in bycopy NSString *)inputLine forWindowIdentifier:(unsigned int)windowIdentifier {
	<#code#>
}

- (void)setRootWindow:(glui32)identifier {
	<#code#>
}

- (void)setStyle:(unsigned int)style onStream:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)setStyleHint:(glui32)hint forStyle:(glui32)style toValue:(glsi32)value windowType:(glui32)wintype {
	<#code#>
}

- (void)setStyleHint:(glui32)hint toValue:(glsi32)value inStream:(glui32)streamIdentifier {
	<#code#>
}

- (void)unregisterStreamIdentifier:(unsigned int)streamIdentifier {
	<#code#>
}

- (void)queueEvent:(GlkEvent *)evt {
	<#code#>
}

@end
