//
//  SwiftHelpers.swift
//  multiWinSwift
//
//  Created by C.W. Betts on 12/19/21.
//

import Foundation
import GlkView

/// Converts a Swift `String` to eitner ISO Latin 1 or UTF-32, as the native encoding of
/// Glk is ISO Latin 1 so a simple call to `glk_put_string` could be messed up by a
/// UTF-8-encoded string.
///
/// If `str` can't be represented in ISO Latin 1, it is converted to UTF-32 and
/// `glk_put_string_uni` is called instead.
func glkPutString(_ str: String) {
	if var strVal = str.data(using: .isoLatin1) {
		strVal.append(contentsOf: [0])// NULL termination
		strVal.withUnsafeMutableBytes { umbrd in
			let pre1 = umbrd.bindMemory(to: CChar.self)
			glk_put_string(pre1.baseAddress)
		}
		return
	} else {
		var strDat = str.data(using: .utf32LittleEndian, allowLossyConversion: true)!
		strDat.append(contentsOf: [0,0,0,0])// NULL termination
		strDat.withUnsafeMutableBytes { umrd in
			let pre1 = umrd.bindMemory(to: glui32.self)
			glk_put_string_uni(pre1.baseAddress)
		}
	}
}


/// Converts a Swift `String` to eitner ISO Latin 1 or UTF-32, as the native encoding of
/// Glk is ISO Latin 1 so a simple call to `glk_put_string_stream` could be messed up by a
/// UTF-8-encoded string.
///
/// If `str` can't be represented in ISO Latin 1, it is converted to UTF-32 and
/// `glk_put_string_stream_uni` is called instead.
func glkPutStringStream(_ strID: strid_t, _ str: String) {
	if var strVal = str.data(using: .isoLatin1) {
		strVal.append(contentsOf: [0])// NULL termination
		strVal.withUnsafeMutableBytes { umbrd in
			let pre1 = umbrd.bindMemory(to: CChar.self)
			glk_put_string_stream(strID, pre1.baseAddress)
		}
		return
	} else {
		var strDat = str.data(using: .utf32LittleEndian, allowLossyConversion: true)!
		strDat.append(contentsOf: [0,0,0,0])// NULL termination
		strDat.withUnsafeMutableBytes { umrd in
			let pre1 = umrd.bindMemory(to: glui32.self)
			glk_put_string_stream_uni(strID, pre1.baseAddress)
		}
	}
}
