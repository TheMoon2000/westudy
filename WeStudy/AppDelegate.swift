//
//  AppDelegate.swift
//  Room
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    @IBOutlet weak var menu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        statusItem = NSStatusBar.system.statusItem(withLength: 70)
        statusItem?.menu = menu
        statusItem?.title = "WeStudy"
    }
    
    func addFriend() {
        let alert = NSAlert()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

