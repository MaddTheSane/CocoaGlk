//
//  MultiWinSwift-BridgingHeader.h
//  CocoaGlk
//
//  Created by C.W. Betts on 12/20/21.
//

#ifndef MultiWinSwift_BridgingHeader_h
#define MultiWinSwift_BridgingHeader_h

#include <GlkView/glk.h>
#include <CoreFoundation/CFBase.h>

/// Swift helper enum for Glk character values
CF_ENUM(glui32) {
	GlkKeyCodeLeft = keycode_Left,
	GlkKeyCodeRight = keycode_Right,
	GlkKeyCodeUp = keycode_Up,
	GlkKeyCodeDown = keycode_Down,
	GlkKeyCodeReturn = keycode_Return,
	GlkKeyCodeDelete = keycode_Delete,
	GlkKeyCodeEscape = keycode_Escape,
	GlkKeyCodeTab = keycode_Tab,
	GlkKeyCodePageUp = keycode_PageUp,
	GlkKeyCodePageDown = keycode_PageDown,
	GlkKeyCodeHome = keycode_Home,
	GlkKeyCodeEnd = keycode_End,
	GlkKeyCodeFunction1 = keycode_Func1,
	GlkKeyCodeFunction2 = keycode_Func2,
	GlkKeyCodeFunction3 = keycode_Func3,
	GlkKeyCodeFunction4 = keycode_Func4,
	GlkKeyCodeFunction5 = keycode_Func5,
	GlkKeyCodeFunction6 = keycode_Func6,
	GlkKeyCodeFunction7 = keycode_Func7,
	GlkKeyCodeFunction8 = keycode_Func8,
	GlkKeyCodeFunction9 = keycode_Func9,
	GlkKeyCodeFunction10 = keycode_Func10,
	GlkKeyCodeFunction11 = keycode_Func11,
	GlkKeyCodeFunction12 = keycode_Func12,
	GlkKeyCodeKeyAt = '@',
	GlkKeyCodeKeyLowerH = 'h',
	GlkKeyCodeKeyLowerV = 'v',
	GlkKeyCodeKeyLowerC = 'c',
	GlkKeyCodeSpace = ' ',
};

#endif /* MultiWinSwift_BridgingHeader_h */
