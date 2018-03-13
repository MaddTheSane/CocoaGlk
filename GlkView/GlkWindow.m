//
//  GlkWindow.m
//  CocoaGlk
//
//  Created by Andrew Hunter on 19/03/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import "GlkWindow.h"

@implementation GlkWindow

// = Initialisation =

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
	if (self) {
		border = 4;
		scaleFactor = 1.0;
	}
    
	return self;
}

- (void) dealloc {
	[styles release]; styles = nil;
	[preferences release]; preferences = nil;
	
	[immediateStyle release]; immediateStyle = nil;
	[customAttributes release]; customAttributes = nil;
	
	[super dealloc];
}

// = Drawing =

- (void)drawRect:(NSRect)rect {
	[[self backgroundColour] set];
	NSRectFill(rect);
}

- (BOOL) isOpaque {
	return YES;
}

// = Window metadata =

@synthesize closed;
@synthesize glkIdentifier=windowIdentifier;

// = The parent window =

@synthesize parent=parentWindow;

// = Layout =

- (void) layoutInRect: (NSRect) parentRect {
	[self setFrame: parentRect];
	
	GlkSize newSize = [self glkSize];
	if (newSize.width != lastSize.width || newSize.height != lastSize.height) {
		[containingView requestClientSync];
	}
	lastSize = [self glkSize];
}

- (CGFloat) widthForFixedSize: (unsigned) size {
	return size;
}

- (CGFloat) heightForFixedSize: (unsigned) size {
	return size;
}

@synthesize border;

- (NSRect) contentRect {
	return NSInsetRect([self bounds], border, border);
}

- (GlkSize) glkSize {
	NSRect contentRect = [self contentRect];
	GlkSize res;
	
	res.width = (int)contentRect.size.width;
	res.height = (int)contentRect.size.height;
	
	return res;
}

@synthesize scaleFactor;

// = Styles =

@synthesize forceFixed;

- (NSColor*) backgroundColour {
	return [[self style: style_Normal] backColour];
}

- (NSFont*) proportionalFont {
	if (forceFixed) {
		return [self fixedFont];
	} else {
		return [[self attributes: style_Normal] objectForKey: NSFontAttributeName];
	}
}

- (NSFont*) fixedFont {
	return [[self attributes: style_Preformatted] objectForKey: NSFontAttributeName];
}

- (NSDictionary*) currentTextAttributes {
	NSDictionary* res = [self attributes: style];
	
	if (linkObject != nil) {
		NSMutableDictionary* linkRes = [res mutableCopy];
		
		[linkRes setObject: linkObject
					forKey: NSLinkAttributeName];
		
		return [linkRes autorelease];
	}
	
	return res;
}

- (CGFloat) leading {
	return 0;
}

- (CGFloat) lineHeight {
    NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
    
	return [layoutManager defaultLineHeightForFont: [[self currentTextAttributes] objectForKey: NSFontAttributeName]];
}

- (void) setStyles: (NSDictionary*) newStyles {
	[styles release];
	styles = [[NSDictionary alloc] initWithDictionary: newStyles
											copyItems: YES];
}

- (GlkStyle*) style: (unsigned) glkStyle {
	// If there aren't any styles yet, get the default styles from the preferences
	if (!styles) {
		if (!preferences) preferences = [[GlkPreferences sharedPreferences] retain];
		[self setStyles: [preferences styles]];
	}
	
	// Get the result from the styles object (use a default if we can't find a suitable style)
	GlkStyle* res = [styles objectForKey: @(glkStyle)];	
	if (!res) res = [GlkStyle style];
	
	if (forceFixed && [res proportional]) [res setProportional: NO];
	if (forceFixed && glkStyle != style_Normal) [res setSize: [[self style: style_Normal] size]];
	
	return res;
}

- (NSDictionary*) attributes: (unsigned) glkStyle {
	if (!preferences) preferences = [[GlkPreferences sharedPreferences] retain];
	
	GlkStyle* sty;
	if (!immediateStyle) {
		// Use the standard glk style if no immediate style is overriding it
		sty = [self style: glkStyle];
	} else {
		// The immediate style overrides any standard Glk style
		sty = immediateStyle;
	}
	
	if (customAttributes) {
		// Merge in the custom attributes if they're set
		NSMutableDictionary* res = [[[sty attributesWithPreferences: preferences
														scaleFactor: scaleFactor] mutableCopy] autorelease];
		[res addEntriesFromDictionary: customAttributes];
		
		return res;
	} else {
		// Just use the standard attributes for this style
		return [sty attributesWithPreferences: preferences
								  scaleFactor: scaleFactor];
	}
}

- (void) setPreferences: (GlkPreferences*) prefs {
	[preferences release];
	preferences = [prefs retain];
}

- (void) reformat {
	// Blank window just needs laying out again
	[self layoutInRect: [self frame]];
}

- (void) setImmediateStyleHint: (glui32) hint
					   toValue: (glsi32) value {
	// Create the immediate style if it doesn't already exist
	if (!immediateStyle) {
		immediateStyle = [[self style: style] copy];
		if (!immediateStyle) immediateStyle = [[GlkStyle style] copy];
	} else {
		immediateStyle = [[immediateStyle autorelease] copy];
	}
	
	// Set the style hint in the immediate style
	[immediateStyle setHint: hint
					toValue: value];
}

- (void) clearImmediateStyleHint: (glui32) hint {
	// Create the immediate style if it doesn't already exist
	if (!immediateStyle) {
		immediateStyle = [[self style: style] copy];
		if (!immediateStyle) immediateStyle = [[GlkStyle style] copy];
	} else {
		immediateStyle = [[immediateStyle autorelease] copy];
	}
	
	// Get the default style
	GlkStyle* defaultStyle = [self style: style];
	if (!defaultStyle) defaultStyle = [GlkStyle style];
	
	// Set the style hint in the immediate style
	[immediateStyle setHint: hint
			   toMatchStyle: defaultStyle];
}

- (void) setCustomAttributes: (NSDictionary*) newCustomAttributes {
	// Dispose of the old custom attributes
	[customAttributes release];
	
	// Set the new attribtues from the dictionary
	customAttributes = [[NSDictionary alloc] initWithDictionary: newCustomAttributes
													  copyItems: YES];
}

// = Cursor positioning =

- (void) moveCursorToXposition: (int) xpos
					 yPosition: (int) ypos {
	NSLog(@"Warning: attempt to move cursor in a window that doesn't support it");
}


// = Window control =

- (void) taskFinished {
	// This window never liked the subtask anyway and is happy it's dead
}

- (void) clearWindow {
	// We can't get any clearer
}

@synthesize eventTarget=target;

- (void) requestCharInput {
	if (lineInput) {
		NSLog(@"Oops: client requested char input while line input was pending");
		[self cancelLineInput];
	}
	charInput = YES;
	[[self window] invalidateCursorRectsForView: self];
}

- (void) requestLineInput {
	if (charInput) {
		NSLog(@"Oops: client requested line input while char input was pending");
		[self cancelCharInput];
	}
	lineInput = YES;
	[[self window] invalidateCursorRectsForView: self];
}

- (BOOL) waitingForLineInput {
	return lineInput;
}

- (BOOL) waitingForCharInput {
	return charInput;
}

- (BOOL) waitingForKeyboardInput {
	return charInput || lineInput || [self needsPaging];
}

- (BOOL) waitingForUserKeyboardInput {
	// This differs in that we ignore the case where the window needs paging
	return charInput || lineInput;
}

- (NSResponder*) windowResponder {
	return self;
}

- (void) setInputLine: (NSString*) inputLine {
	// As we don't support line input, there's nothing to do here
}

- (void) forceLineInput: (NSString*) forcedInput {
	// Can't deal with line input events, but character input events are easy
	if (charInput) {
		// Generate a character input event
		GlkEvent* glkEvent = [[GlkEvent alloc] initWithType: evtype_CharInput
										   windowIdentifier: [self glkIdentifier]
													   val1: [[self class] keycodeForString: forcedInput]
													   val2: 0];		
		[self cancelCharInput];
		[target queueEvent: [glkEvent autorelease]];
	}
}

- (void) requestMouseInput {
	mouseInput = YES;
	[[self window] invalidateCursorRectsForView: self];
}

- (void) requestHyperlinkInput {
	hyperlinkInput = YES;
	[[self window] invalidateCursorRectsForView: self];
}

- (void) cancelCharInput {
	charInput = NO;
	[[self window] invalidateCursorRectsForView: self];
}

- (NSString*) cancelLineInput {
	lineInput = NO;
	[[self window] invalidateCursorRectsForView: self];
	
	return @"";
}

- (void) cancelMouseInput {
	mouseInput = NO;
	[[self window] invalidateCursorRectsForView: self];
}

- (void) cancelHyperlinkInput {
	hyperlinkInput = NO;
	[[self window] invalidateCursorRectsForView: self];
}

- (void) fixInputStatus {
	// Nothing to do for these windows
}

// = Standard mouse and input handlers =

- (BOOL)acceptsFirstResponder {
	// Note that we can't handle line input events by default, so we only accept if we have character events
	if (charInput) {
		return YES;
	} else {
		return NO;
	}
}

- (void) postFocusNotification {
}

- (BOOL)becomeFirstResponder {
	if ([super becomeFirstResponder]) {
		[[NSRunLoop currentRunLoop] performSelector: @selector(postFocusNotification)
											 target: self
										   argument: nil
											  order: 32
											  modes: [NSArray arrayWithObject: NSDefaultRunLoopMode]];
		return YES;
	}
	
	return NO;
}

- (BOOL)resignFirstResponder {
	[self postFocusNotification];
	
	if ([super resignFirstResponder]) {
		return YES;
	}
	
	return NO;
}

+ (unsigned) keycodeForString: (NSString*) string {
	glui32 chr = keycode_Unknown;						// The Glk character
	
	if ([string length] <= 0) return chr;
	
	unichar inChar = [string characterAtIndex: 0];
	switch (inChar) {
		case '\n':
		case '\r':
			chr = keycode_Return;
			break;
		case '\t':
			chr = keycode_Tab;
			break;
			
		case NSUpArrowFunctionKey:
			chr = keycode_Up;
			break;
		case NSDownArrowFunctionKey:
			chr = keycode_Down;
			break;
		case NSLeftArrowFunctionKey:
			chr = keycode_Left;
			break;
		case NSRightArrowFunctionKey:
			chr = keycode_Right;
			break;
			
		case NSPageDownFunctionKey:
			chr = keycode_PageDown;
			break;
		case NSPageUpFunctionKey:
			chr = keycode_PageUp;
			break;
			
		case NSHomeFunctionKey:
			chr = keycode_Home;
			break;
			
		case NSEndFunctionKey:
			chr = keycode_End;
			break;
			
		case '\e':
			chr = keycode_Escape;
			break;
	}
	
	if (chr == keycode_Unknown) {
		NSData* latin1 = [string dataUsingEncoding: NSISOLatin1StringEncoding
							  allowLossyConversion: YES];
		
		if ([latin1 length] > 0) {
			chr = ((unsigned char*)[latin1 bytes])[0];
		}
	}
	
	return chr;
}

+ (unsigned) keycodeForEvent: (NSEvent*) evt {
	return [[self class] keycodeForString: [evt characters]];
}

- (void) keyDown: (NSEvent*) evt {
	if ([containingView morePromptsPending]) {
		[containingView pageAll];
	} else if (!charInput) {
		//NSBeep();
	} else if ([[evt characters] length] >= 1) {
		GlkEvent* glkEvent = [[GlkEvent alloc] initWithType: evtype_CharInput
										   windowIdentifier: [self glkIdentifier]
													   val1: [[self class] keycodeForEvent: evt]
													   val2: 0];
		
		[self cancelCharInput];
		[target queueEvent: [glkEvent autorelease]];
	}
}

- (void) updateCaretPosition {
}

- (NSInteger) inputPos {
	// Default is 0 (not managing a text view)
	return 0;
}

- (void) bufferIsFlushing {
	// Default action is to catch flies
}

- (void) bufferHasFlushed {
	// The horrible taste of flies fails to wake us up
}

// = Streaming =

// Control

- (void) closeStream {
	// Nothing to do really
}

- (void) setPosition: (in int) position
		  relativeTo: (in enum GlkSeekMode) seekMode {
	// No effect
}

- (unsigned long long) getPosition {
	// Spec isn't really clear on what do for window streams. We just say the position is always 0
	return 0;
}

// Writing

- (void) putChar: (in unichar) ch {
	unichar buf[1];
	
	buf[0] = ch;
	
	[self putString: [NSString stringWithCharacters: buf
											 length: 1]];
}

- (void) putString: (in bycopy NSString*) string {
	// We're blank: nothing to do
}

- (void) putBuffer: (in bycopy NSData*) buffer {
	// Assume that buffers are in ISO Latin-1 format
	NSString* string = [[[NSString alloc] initWithBytes: [buffer bytes]
												 length: [buffer length]
											   encoding: NSISOLatin1StringEncoding] autorelease];

	// The view won't automate data events automatically
	[containingView automateStream: self
						 forString: string];
	
	// Put the string
	[self putString: string];
}

// = Reading =

- (unichar) getChar {
	return 0;
}

- (bycopy NSString*) getLineWithLength: (NSInteger) len {
	return nil;
}

- (bycopy NSData*) getBufferWithLength: (NSUInteger) length {
	return nil;
}

// = Styles =

- (void) setStyle: (int) styleId {
	style = styleId;

	if (immediateStyle) {
		[immediateStyle release];
		immediateStyle = nil;
	}
}

@synthesize style;

// = Cursor rects =

- (void)resetCursorRects {
	if (lineInput || charInput) {
		[self addCursorRect: [self bounds]
					 cursor: [NSCursor IBeamCursor]];
	} else if (mouseInput) {
		[self addCursorRect: [self bounds]
					 cursor: [NSCursor crosshairCursor]];
	} else {
	}
}


// = The containing view =

@synthesize containingView;

// = Paging =

- (BOOL) needsPaging {
	// By default, windows have no paging
	return NO;
}

- (void) page {
	
}

// = Hyperlinks =

- (void) setHyperlink: (unsigned int) value {
	[linkObject release];
	linkObject = [[NSNumber alloc] initWithUnsignedInt: value];
}

- (void) clearHyperlink {
	[linkObject release];
	linkObject = nil;
}

// = Accessibility =

- (NSArray*) accessibilityAttributeNames {
    // Attribtues that we support
    static NSArray* attributes = NULL;
    
    // Generate the attribute list if it's not already present
    if (!attributes) {
        // Copy the attributes supported by a standard view
        NSMutableArray* newAttributes = [[super accessibilityAttributeNames] mutableCopy];
        
        // We supply the children for this item (for navigating the window structure)
        [newAttributes addObject: NSAccessibilityChildrenAttribute];
        [newAttributes addObject: NSAccessibilityDescriptionAttribute];
        
        // Finalise the attributes
        attributes = [newAttributes copy];
        [newAttributes release];
    }
    
    // Return the attributes
    return attributes;
}

- (id) accessibilityAttributeValue:(NSString *)attribute {
    // Action depends on the attribute
    if ([attribute isEqualToString: NSAccessibilityChildrenAttribute]) {
        // No children by default
        return [NSArray array];
    }
    
    if ([attribute isEqualToString: NSAccessibilityDescriptionAttribute]) {
        return [NSString stringWithFormat: @"GLK window%@%@", lineInput?@", waiting for commands":@"", charInput?@", waiting for a key press":@""];
    }
    
    // Otherwise, use the standard behaviour for a view
    return [super accessibilityAttributeValue: attribute];
}

@end
