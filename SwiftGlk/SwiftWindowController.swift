//
//  SwiftWindowController.swift
//  SwiftGlk
//
//  Created by C.W. Betts on 3/5/18.
//

import Cocoa
import GlkView.GlkView
import GlkSound

class SwiftWindowController: NSWindowController, GlkViewDelegate {
	/// The view in which the actual action takes place
	@IBOutlet weak var glkView: GlkView!
	
	/// The statusbar text
	@IBOutlet weak var status: NSTextField!
	
	let soundHandler = GlkSoundHandler()
	
	convenience init() {
		self.init(windowNibName: NSNib.Name("SwiftGlk"))
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		self.windowFrameAutosaveName = NSWindow.FrameAutosaveName("SwiftGlkWindow")
		
		// Set the status
		status.stringValue = NSLocalizedString("Waiting for game...", comment: "Waiting for game...")
		
		glkView.soundHandler = soundHandler
		soundHandler.glkctl = glkView
		
		// We're the view delegate
		glkView.delegate = self
	}
	
	// = GlkView delegate methods =
	
	func taskHasStarted() {
		showStatusText(NSLocalizedString("Running...", comment: "Running..."))
	}
	
	func taskHasFinished() {
		showStatusText(NSLocalizedString("Finished", comment: "Finished"))
	}
	
	func taskHasCrashed() {
		self.status.attributedStringValue = NSAttributedString(string: NSLocalizedString("Crashed!", comment: "Crashed!"), attributes: [.foregroundColor: NSColor.systemRed])
	}

	func showStatusText(_ status: String) {
		self.status.stringValue = status
	}
}
