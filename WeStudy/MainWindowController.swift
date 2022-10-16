//
//  MainWindowController.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/16.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func addFriend(sender: Any) {
        let popover = NSPopover()
//        popover.show(relativeTo: sender.frame, of: sender, preferredEdge: .maxY)
        print(popover)
    }
}
