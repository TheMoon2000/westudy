//
//  Constants.swift
//  Room
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa
import CommonCrypto
import IOKit.hid

let API_BASE = "http://35.162.191.139/api"

enum Colors {
    static let theme = NSColor(named: "Theme")!
    static let themeLight = NSColor(named: "Theme-light")!
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
    let timestamp: Int
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

struct LoginCredentials: Codable {
    let username: String
    let password_hash: String
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
