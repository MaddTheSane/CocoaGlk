//
//  main.swift
//  multiWinSwift
//
//  Created by C.W. Betts on 12/19/21.
//

import Foundation
import GlkView.glk
import GlkClient.cocoaglk

cocoaglk_start(CommandLine.argc, unsafeBitCast(CommandLine.unsafeArgv, to: UnsafeMutablePointer<UnsafePointer<CChar>?>.self));
GlkMain();
cocoaglk_flushbuffer("About to finish");
glk_exit();


