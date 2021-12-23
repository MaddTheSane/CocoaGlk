//
//  MultiWinSwift.swift
//  multiWinSwift
//
//  Created by C.W. Betts on 12/19/21.
//

import Foundation
import GlkView

/* The story and status windows. */
private var mainwin1: winid_t? = nil
private var mainwin2: winid_t? = nil
private var statuswin: winid_t? = nil

/// Key windows don't get stored in a global variable; we'll find them
/// by iterating over the list and looking for this rock value.
private let KEYWINROCK: glui32 = 97

/// For the two main windows, we keep a flag saying whether that window
/// has a line input request pending. (Because if it does, we need to
/// cancel the line input before printing to that window.)
private var inputpending1 = false, inputpending2 = false
/// When we cancel line input, we should remember how many characters
/// had been typed. This lets us restart the input with those characters
/// already in place. 
private var already1: glui32 = 0, already2: glui32 = 0;

/// There's a three-second timer which can be on or off.
private var timer_on = false;

/// This is a utility function. Given a main window, it finds the
/// "other" main window (if both actually exist) and cancels line
/// input in that other window (if input is pending.) It does not
/// set the output stream to point there, however. If there is only
/// one main window, this returns `nil`.
private func printToOtherWindow(_ win: winid_t) -> winid_t? {
	var otherwin: winid_t? = nil
	if win == mainwin1 {
		if let mainwin2 = mainwin2 {
			otherwin = mainwin2
			var ev = event_t()
			glk_cancel_line_event(mainwin2, &ev)
			if ev.type == evtype_LineInput {
				already2 = ev.val1
			}
			inputpending2 = false
		}
	} else if win == mainwin2 {
		if let mainwin1 = mainwin1 {
			otherwin = mainwin1
			var ev = event_t()
			glk_cancel_line_event(mainwin1, &ev)
			if ev.type == evtype_LineInput {
				already1 = ev.val1
			}
			inputpending1 = false
		}
	}
	
	return otherwin
}

/// The `glk_main()` function is called by the Glk system; it's the main entry
/// point for your program.
func GlkMain() {
	var commandBuffer1 = [CChar](repeating: 0, count: 256)
	var commandBuffer2 = [CChar](repeating: 0, count: 256)
	
	/* Open the main windows. */
	mainwin1 = glk_window_open(nil, 0, 0, glui32(wintype_TextBuffer), 1);
	if mainwin1 == nil {
		/* It's possible that the main window failed to open. There's
		 nothing we can do without it, so exit. */
		return
	}
	
	/* Open a second window: a text grid, above the main window, five
	 lines high. It is possible that this will fail also, but we accept
	 that. */
	statuswin = glk_window_open(mainwin1,
								glui32(winmethod_Above | winmethod_Fixed),
								5, glui32(wintype_TextGrid), 0);
	
	/* And a third window, a second story window below the main one. */
	mainwin2 = glk_window_open(mainwin1,
							   glui32(winmethod_Below | winmethod_Proportional),
							   50, glui32(wintype_TextBuffer), 0);
	
	/* We're going to be switching from one window to another all the
	 time. So we'll be setting the output stream on a case-by-case
	 basis. Every function that prints must set the output stream
	 first. (Contrast model.c, where the output stream is always the
	 main window, and every function that changes that must set it
	 back afterwards.) */
		 
	glk_set_window(mainwin1)
	var str = #"""
MultiWinSwift
An Interactive Sample Glk Program writtin in Swift
By C.W. Betts.
Ported from Multiwin by Andrew Plotkin.
Release 1.
Type "help" for a list of commands.

"""#
	glkPutString(str)
		 
	glk_set_window(mainwin2)
	str = #"""
Note that the upper left-hand window accepts character input. Hit ‘h’ to split the window horizontally, ‘v’ to split the window vertically, ‘c’ to close a window, and any other key (including special keys) to display key codes. All new windows accept these same keys as well.

This bottom window accepts normal line input.

"""#
	
	glkPutString(str)
	
	if statuswin != nil {
		/* For fun, let's open a fourth window now, splitting the status
		 window. */
		let keywin = glk_window_open(statuswin,
									 glui32(winmethod_Left | winmethod_Proportional),
									 66, glui32(wintype_TextGrid), KEYWINROCK);
		if keywin != nil {
			glk_request_char_event(keywin);
		}
	}
	
	/* Draw the key window now, since we don't draw it every input (as
	 we do the status window. */
	drawKeyWins()

	while true {
		var doneLoop = false
		var whichWin: winid_t? = nil
		var ev = event_t()
		
		drawStatusWindow()
		/* We're not redrawing the key windows every command. */

		
		/* Either main window, or both, could already have line input
		 pending. If so, leave that window alone. If there is no
		 input pending on a window, set a line input request, but
		 keep around any characters that were in the buffer already. */
		
		if (mainwin1 != nil && !inputpending1) {
			glk_set_window(mainwin1)
			glkPutString("\n>")
			/* We request up to 255 characters. The buffer can hold 256,
			 but we are going to stick a null character at the end, so
			 we have to leave room for that. Note that the Glk library
			 does *not* put on that null character. */
			glk_request_line_event(mainwin1, &commandBuffer1, 255, already1)
			inputpending1 = true;
		}
		
		if (mainwin2 != nil && !inputpending2) {
			glk_set_window(mainwin2)
			glkPutString("\n>")
			/* See above. */
			glk_request_line_event(mainwin2, &commandBuffer2, 255, already2)
			inputpending2 = true
		}

		while (!doneLoop) {
			/* Grab an event. */
			glk_select(&ev)
			var wasFirst: Bool? = nil

			switch ev.type {
				
			case glui32(evtype_LineInput):
				/* If the event comes from one main window or the other,
					we mark that window as no longer having line input
					pending. We also set commandbuf to point to the
					appropriate buffer. Then we leave the event loop. */
				if (mainwin1 != nil && ev.win == mainwin1) {
					whichWin = mainwin1
					inputpending1 = false
					wasFirst = true
					doneLoop = true
				}
				else if (mainwin2 != nil && ev.win == mainwin2) {
					whichWin = mainwin2
					inputpending2 = false
					wasFirst = false
					doneLoop = true
				}

			case glui32(evtype_CharInput):
				/* It's a key event, from one of the keywins. We
					call a subroutine rather than exiting the
					event loop (although I could have done it
					that way too.) */
				performKey(ev.win, ev.val1)
				
			case glui32(evtype_Timer):
				/* It's a timer event. This does exit from the event
					loop, since we're going to interrupt input in
					mainwin1 and then re-print the prompt. */
				whichWin = nil
				wasFirst = nil
				doneLoop = true
				
			case glui32(evtype_Arrange):
				/* Windows have changed size, so we have to redraw the
				 status window and key window. But we stay in the
				 event loop. */
				drawStatusWindow()
				drawKeyWins()
				
			default:
				break
			}
			
			guard let wasFirst = wasFirst else {
				/* It was a timer event. */
				performTimer()
				continue
			}
			
			
			/* We deviate from multiwin here to do better Swift String handling */
			var cmd: String
			
			/* The line we have received in commandbuf is not null-terminated.
				We handle that first. */
			let len = ev.val1; /* Will be between 0 and 255, inclusive. */
			if wasFirst {
				commandBuffer1[Int(len)] = 0
				cmd = String(cString: commandBuffer1, encoding: .isoLatin1) ?? ""
			} else {
				commandBuffer2[Int(len)] = 0
				cmd = String(cString: commandBuffer2, encoding: .isoLatin1) ?? ""
			}
			
			/* Then squash to lower-case. */
			cmd = cmd.lowercased()
			/* Then trim whitespace before and after. */
			cmd = cmd.trimmingCharacters(in: .whitespaces)
			
			/* cmd now points to a nice null-terminated string. We'll do the
				simplest possible parsing. */
			switch cmd {
			case "":
				glk_set_window(whichWin)
				glkPutString("Excuse me?\n")
				
			case "help":
				verbHelp(whichWin!)
				
			case "yada":
				verbYada(whichWin!)
				
			case "both":
				verbBoth(whichWin!)
				
			case "clear":
				verbClear(whichWin!)
				
			case "page":
				verbPage(whichWin!)
				
			case "pageboth":
				verbPageBoth(whichWin!)
				
			case "timer":
				verbTimer(whichWin!)
				
			case "untimer":
				verbUntimer(whichWin!)

			case "chars":
				verbChars(whichWin!)
				
			case "jump":
				verbJump(whichWin!)

			case "quit":
				verbQuit(whichWin!)
				
			default:
				glk_set_window(whichWin)
				glkPutString("I don’t understand the command “\(cmd)”…\n")
			}
			
			if (whichWin == mainwin1) {
				already1 = 0;
			} else if (whichWin == mainwin2) {
				already2 = 0;
			}
		}
	}
}

private func verbJump(_ win: winid_t) {
	glk_set_window(win);
	
	glkPutString("You jump on the fruit, spotlessly.\n");
}

private func verbHelp(_ win: winid_t) {
	glk_set_window(win);
	
	glkPutString("This model only understands the following commands:\n");
	glkPutString("HELP: Display this list.\n");
	glkPutString("JUMP: Print a short message.\n");
	glkPutString("YADA: Print a long paragraph.\n");
	glkPutString("BOTH: Print a short message in both main windows.\n");
	glkPutString("CLEAR: Clear one window.\n");
	glkPutString("PAGE: Print thirty lines, demonstrating paging.\n");
	glkPutString("PAGEBOTH: Print thirty lines in each window.\n");
	glkPutString("TIMER: Turn on a timer, which ticks in the upper ");
	glkPutString("main window every three seconds.\n");
	glkPutString("UNTIMER: Turns off the timer.\n");
	glkPutString("CHARS: Prints the entire Latin-1 character set.\n");
	glkPutString("QUIT: Quit and exit.\n");
}


/// React to character input in a key window.
private func performKey(_ win: winid_t, _ key: glui32) {
	var keyName: String
	
	switch key {
	case GlkKeyCodeKeyLowerH, GlkKeyCodeKeyLowerH:
		/* Open a new keywindow. */
		let loc: glui32
		if key == GlkKeyCodeKeyLowerH {
			loc = glui32(winmethod_Right | winmethod_Proportional)
		} else {
			loc = glui32(winmethod_Below | winmethod_Proportional)
		}
		
		/* Since the new window has rock value KEYWINROCK, the
		 drawKeyWins() routine will redraw it. */
		if let newwin = glk_window_open(win, loc, 50, glui32(wintype_TextGrid), KEYWINROCK) {
			/* Request character input. In this program, only keywins
			 get char input, so the CharInput events always call
			 perform_key() -- and so the new window will respond
			 to keys just as this one does. */
			glk_request_char_event(newwin)
			/* We now have to redraw the keywins, because any or all of
			 them could have changed size when we opened newwin.
			 glk_window_open() does not generate Arrange events; we
			 have to do the redrawing manually. */
			drawKeyWins()
		}
		/* Re-request character input for this window, so that future
		 keys are accepted. */
		glk_request_char_event(win)
		return;
		
	case GlkKeyCodeKeyLowerC:
		/* Close this keywindow. */
		glk_window_close(win, nil)
		/* Again, any key windows could have changed size. Also the
		 status window could have (if this was the last key window). */
		drawKeyWins()
		drawStatusWindow()
		return

		/* Print a string naming the key that was just hit. */

	case GlkKeyCodeSpace:
		keyName = "space"
		
	case GlkKeyCodeLeft:
		keyName = "left"

	case GlkKeyCodeRight:
		keyName = "right"

	case GlkKeyCodeUp:
		keyName = "up"

	case GlkKeyCodeDown:
		keyName = "down"

	case GlkKeyCodeReturn:
		keyName = "return"

	case GlkKeyCodeDelete:
		keyName = "delete"

	case GlkKeyCodeEscape:
		keyName = "escape"

	case GlkKeyCodeTab:
		keyName = "tab"

	case GlkKeyCodePageUp:
		keyName = "page up"

	case GlkKeyCodePageDown:
		keyName = "page down"

	case GlkKeyCodeHome:
		keyName = "home"

	case GlkKeyCodeEnd:
		keyName = "end"
		
	case GlkKeyCodeFunction12 ... GlkKeyCodeFunction1:
		keyName = "function key"

	case 0 ..< 32:
		let atChar = UInt8(GlkKeyCodeKeyAt + key)
		let atString = String(Character(UnicodeScalar(atChar)))
		keyName = "ctrl-\(atString)"
		
	case 32 ..< 256:
		let isoLat1Dat = Data([UInt8(key)])
		keyName = String(data: isoLat1Dat, encoding: .isoLatin1) ?? "?"
		
	default:
		keyName = "unknown key"
	}
	
	let buf = "Key: \(keyName)"
	var len = buf.count
	
	var width: glui32 = 0, height: glui32 = 0

	/* Print the string centered in this window. */
	glk_set_window(win)
	glk_window_get_size(win, &width, &height)
	glk_window_move_cursor(win, 0, height/2)
	for _ in 0 ..< width {
		glk_put_char(UInt8(GlkKeyCodeSpace))
	}

	width /= 2
	len /= 2
	
	if (width > len) {
		width = width-UInt32(len)
	} else {
		width = 0
	}

	glk_window_move_cursor(win, width, height/2)
	glkPutString(buf)
	
	/* Re-request character input for this window, so that future
	 keys are accepted. */
	glk_request_char_event(win)
}

private func drawStatusWindow() {
	/* It is possible that the window was not successfully
		created. If that's the case, don't try to draw it. */
	guard let statuswin = statuswin else {
		return
	}

	glk_set_window(statuswin)
	glk_window_clear(statuswin)
	
	var width: glui32 = 0, height: glui32 = 0
	glk_window_get_size(statuswin, &width, &height)

	/* Draw a decorative compass rose in the center. */
	width /= 2
	if width > 0 {
		width -= 1
	}
	height /= 2
	if height > 0 {
		height -= 1
	}
	glk_window_move_cursor(statuswin, width, height+0)
	glkPutString(#"\|/"#)
	glk_window_move_cursor(statuswin, width, height+1)
	glkPutString("-*-")
	glk_window_move_cursor(statuswin, width, height+2)
	glkPutString("/|\\")
}

struct GlkWindowIterator: IteratorProtocol, Sequence {
	typealias Element = (win: winid_t, rock: glui32)
	private var prevElement: winid_t? = nil
	
	mutating func next() -> (win: winid_t, rock: glui32)? {
		var rock: glui32 = 0
		guard let curWin = glk_window_iterate(prevElement, &rock) else {
			return nil
		}
		prevElement = curWin
		
		return (curWin, rock)
	}
}

let upperO = "O".first!.asciiValue!

/// This draws some corner decorations in *every* key window -- the
/// one created at startup, and any later ones. It finds them all
/// with `glk_window_iterate`.
private func drawKeyWins() {
	let winIter = GlkWindowIterator()
	
	for (win, rock) in winIter {
		guard rock == KEYWINROCK else {
			continue
		}
		var width: glui32 = 0, height: glui32 = 0
		glk_set_window(win)
		glk_window_clear(win)
		glk_window_get_size(win, &width, &height)
		glk_window_move_cursor(win, 0, 0)
		glk_put_char(upperO)
		glk_window_move_cursor(win, width-1, 0)
		glk_put_char(upperO)
		glk_window_move_cursor(win, 0, height-1)
		glk_put_char(upperO)
		glk_window_move_cursor(win, width-1, height-1)
		glk_put_char(upperO)
	}
}

/// React to a timer event. This just prints "Tick" in `mainwin1`, but it
/// first has to cancel line input if any is pending.
private func performTimer() {
	guard let mainwin1 = mainwin1 else {
		return
	}

	var ev = event_t()
	
	if inputpending1 {
		glk_cancel_line_event(mainwin1, &ev);
		if ev.type == evtype_LineInput {
			already1 = ev.val1
		}
		inputpending1 = false
	}
	
	glk_set_window(mainwin1)
	glkPutString("Tick.\n")
}

/// Print every character, or rather try to.
private func verbChars(_ win: winid_t) {
	glk_set_window(win);
	
	for ix in 0 ... UInt8.max {
		glkPutString("\(String(ix)): ")
		glk_put_char(ix)
		glk_put_char("\n".first!.asciiValue!)
	}
}

private func verbQuit(_ win: winid_t) -> Never {
	glk_set_window(win);
	
	glkPutString("Thanks for playing.\n")
	glk_exit()
	/* glk_exit() actually stops the process; it does not return. */
}

/// This is a goofy (and overly ornate) way to print a long paragraph.
/// It just shows off line wrapping in the Glk implementation.
///
/// In this Swift version, we'll be writing to a Swift string, than write the whole string to the Glk window using
/// `glkPutString`.
private func verbYada(_ win: winid_t) {
	let wordCapList = ["Ga", "Bo", "Wa", "Mu", "Bi", "Fo", "Za", "Mo", "Ra", "Po",
					   "Ha", "Ni", "Na"]
	let wordList = ["figgle", "wob", "shim", "fleb", "moobosh", "fonk", "wabble",
					"gazoon", "ting", "floo", "zonk", "loof", "lob"]
	let NUMWORDS = wordCapList.count
	
	glk_set_window(win);
	var ourStr = String()
	ourStr.reserveCapacity(800)
	var first = true
	var jx = 0
	var wstep = 1
	var wcount1 = 0
	var wcount2 = 0
	
	for ix in 0 ..< 85 {
		if ix > 0 {
			ourStr += " "
		}
		
		if first {
			ourStr += wordCapList[(ix / 17) % wordCapList.count]
			first = false
		}
		
		ourStr += wordList[jx]
		jx = (jx + wstep) % NUMWORDS
		wcount1 += 1
		if wcount1 >= NUMWORDS {
			wcount1 = 0
			wstep += 1
			wcount2 += 1
			if wcount2 >= NUMWORDS - 2 {
				wcount2 = 0
				wstep = 1
			}
		}
		
		if (ix % 17) == 16 {
			ourStr += "."
			first = true
		}
	}
	ourStr += "\n"
	glkPutString(ourStr)
}

/// Turn on the timer. The timer prints a tick in mainwin1 every three
/// seconds.
private func verbTimer(_ win: winid_t) {
	glk_set_window(win)
	
	if timer_on {
		glkPutString("The timer is already running.\n")
		return
	}
	
	guard glk_gestalt(glui32(gestalt_Timer), 0) == 1 else {
		glkPutString("Your Glk library does not support timer events.\n");
		return
	}
	glkPutString("A timer starts running in the upper window.\n")
	glk_request_timer_events(3000) /* Every three seconds. */
	timer_on = true

}

/// Turn off the timer.
private func verbUntimer(_ win: winid_t) {
	glk_set_window(win);
	
	guard timer_on else {
		glkPutString("The timer is not currently running.\n")
		return
	}
	
	glkPutString("The timer stops running.\n")
	glk_request_timer_events(0)
	timer_on = false
}

/// Clear a window.
private func verbClear(_ win: winid_t) {
	glk_window_clear(win)
}

/// Print some text in both windows. This uses `printToOtherWindow()` to
/// find the other window and prepare it for printing.
private func verbBoth(_ win: winid_t) {
	glk_set_window(win);
	glkPutString("Something happens in this window.\n");
	
	if let otherwin = printToOtherWindow(win) {
		glk_set_window(otherwin);
		glkPutString("Something happens in the other window.\n");
	}
}


/// Print thirty lines.
private func verbPage(_ win: winid_t) {
	glk_set_window(win)
	
	for ix in 0 ..< 30 {
		glkPutString("\(ix)\n")
	}
}

/// Print thirty lines in both windows. This gets fancy by printing
/// to each window alternately, without setting the output stream,
/// by using `glk_put_string_stream()` instead of `glk_put_string()`.
/// There's no particular difference; this is just a demonstration.
private func verbPageBoth(_ win: winid_t) {
	let str = glk_window_get_stream(win)
	let otherstr: strid_t?
	if let otherwin = printToOtherWindow(win) {
		otherstr = glk_window_get_stream(otherwin)
	} else {
		otherstr = nil
	}
	
	for ix in 0 ..< 30 {
		let buf = "\(ix)\n"
		glkPutStringStream(str!, buf)
		if let otherstr = otherstr {
			glkPutStringStream(otherstr, buf)
		}
	}
}
