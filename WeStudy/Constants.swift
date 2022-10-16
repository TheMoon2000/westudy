//
//  Constants.swift
//  Room
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa
import IOKit.hid

let API_BASE = "http://35.162.191.139/api"

enum Colors {
    static let theme = NSColor(named: "Theme")!
}

func grantPermissions() {
    if !IOHIDRequestAccess(kIOHIDRequestTypeListenEvent) {
        print("Not granted input monitoring")
    } else {
        print("Granted input monitoring")
    }
    if !IOHIDRequestAccess(kIOHIDRequestTypePostEvent) {
        print("Not granted accessibility")
    } else {
        print("Granted accessibility")
    }
    
    
}

extension String {
    /// URL encoded string.
    var encoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self
    }
    
    /// URL decoded string.
    var decoded: String {
        return self.removingPercentEncoding ?? self
    }
}

extension Notification.Name {
    static let keypress = Notification.Name.init(rawValue: "keypress")
}


extension URL {
    
    /**
     Custom URL formatter.
     
     - Parameters:
        - API_Name: The API name.
        - parameters: The url parameters in the form of a Swift native dictionary.
     
     - Returns: An optional URL object (URL?) formed from the provided information.
     */
    
    static func with(API_Name: String, parameters: [String: String] = [:]) -> URL? {
        if (parameters.isEmpty) {
            return URL(string: API_BASE + API_Name)
        }
        let formattedParameters = parameters.map {
            return $0.key.encoded + "=" + $0.value.encoded
        }
        return URL(string: "\(API_BASE + API_Name)?" + formattedParameters.joined(separator: "&"))
    }
}

class KeyPressManager {
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    
    init() {
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone));
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }
    
    func addListener(callback: (UInt32) -> Void) {
        
        let call: IOHIDValueCallback = { context, result, sender, device in
            let elem: IOHIDElement = IOHIDValueGetElement(device);
            let scancode = IOHIDElementGetUsage(elem);
            print(scancode)
            if (scancode < 4 || scancode > 231) {
                return
            }
//            callback(scancode)
        }
        
        IOHIDManagerRegisterInputValueCallback(self.manager, call, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
}

struct DataPoint: Codable, CustomStringConvertible {
    let timestamp: Date
    let mouseTouched: Bool
    let keypressCount: Int
    let activeAppName: String
    let openedAppNames: [String]
    let activeTabName: String?
    let activeTabURL: String?
    let isPlayingVideo: Bool
    
    var description: String {
        return String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
    }
}
