//
//  FriendCell.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/16.
//

import Cocoa

class FriendCell: NSTableCellView {
    
    @IBOutlet weak var friendName: NSTextField!
    @IBOutlet weak var status: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
