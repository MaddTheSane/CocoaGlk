//
//  AppDelegate.swift
//  SwiftGlk
//
//  Created by C.W. Betts on 3/5/18.
//

import Cocoa
import GlkView.GlkHub

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GlkHubDelegate {
	var winController: SwiftWindowController?
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Set up the hub
		GlkHub.shared.delegate = self
		
		GlkHub.shared.setKeychainHubCookie()
		GlkHub.shared.hubName = "SwiftGlk"
		
		// Start another task, this time using the launch facility
		let control = SwiftWindowController()
		control.showWindow(self)
		winController = control
		control.glkView.launchClientApplication(Bundle.main.path(forResource: "glulxe-client", ofType: nil)!, withArguments: nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func createAnonymousSession() -> GlkSession? {
		return winController?.glkView
	}
}
