//
//  MainViewController.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Foundation
import Cocoa
import IOKit.hid

let PERIOD = 5.0

class MainViewController: NSViewController {

    var k: Keylogger!
    
    var history = [DataPoint]()
    var keypressCount = 0
    
    /// The code for the last key.
    var lastKey = 0
    
    /// How many times the `lastKey` is pressed.
    var lastKeyCount = 0
    
    /// Whether the mouse is interacted with in the last `PERIOD` seconds.
    var mouseTouched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupKeyListener()
        setupMouseListener()
        
        Timer.scheduledTimer(withTimeInterval: PERIOD, repeats: true) { timer in
            self.recordHistoryAndUpload()
        }
    }
    
    func setupMouseListener() {
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .leftMouseDragged, .scrollWheel]) { event in
            self.mouseTouched = true
        }
    }
    
    func setupKeyListener() {
        grantPermissions()
        
        let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
            
            let elem: IOHIDElement = IOHIDValueGetElement(device );
            if (IOHIDElementGetUsagePage(elem) != 0x07) {
                return
            }
            let scancode = IOHIDElementGetUsage(elem);
            if (scancode < 4 || scancode > 231) {
                return
            }
            let pressed = IOHIDValueGetIntegerValue(device);
            
            let nf = Notification(name: .keypress, object: [pressed, scancode], userInfo: nil)
            NotificationCenter.default.post(nf)
        }
        k = Keylogger(listener: Handle_IOHIDInputValueCallback)
        k.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyPressed(_:)), name: .keypress, object: nil)
        
    }
    
    func getSafariActiveTab() -> (String?, String?) {
        let scriptObject = NSAppleScript(source: """
            tell application "Safari" to return {name, URL} of current tab of front window
        """)!
        var error: NSDictionary?
        let output = scriptObject.executeAndReturnError(&error)
        if error == nil {
            return (output.atIndex(1)!.stringValue, output.atIndex(2)!.stringValue)
        } else {
            return (nil, nil)
        }
    }
    
    func getChromeActiveTab() -> (String?, String?) {
        let scriptObject = NSAppleScript(source: """
            tell application "Google Chrome" to return {title, URL} of active tab of front window
        """)!
        var error: NSDictionary?
        let output = scriptObject.executeAndReturnError(&error)
        if error == nil {
            return (output.atIndex(1)!.stringValue, output.atIndex(2)!.stringValue)
        } else {
            print(error)
            return (nil, nil)
        }
    }
    
    func getChromiumActiveTab() -> (String?, String?) {
        let scriptObject = NSAppleScript(source: """
            tell application "Chromium" to return {title, URL} of active tab of front window
        """)!
        var error: NSDictionary?
        let output = scriptObject.executeAndReturnError(&error)
        if error == nil {
            return (output.atIndex(1)!.stringValue, output.atIndex(2)!.stringValue)
        } else {
            print(error)
            return (nil, nil)
        }
    }
    
    func getFirefoxActiveTab() -> (String?, String?) {
        let scriptObject = NSAppleScript(source: """
            tell application "Firefox" to get name of front window
        """)!
        var error: NSDictionary?
        let output = scriptObject.executeAndReturnError(&error)
        if error == nil {
            return (output.stringValue!, nil)
        } else {
            print(error)
            return (nil, nil)
        }
    }
    
    func recordHistoryAndUpload() {
        let allAppNames = Set(NSWorkspace.shared.runningApplications
                                .filter { $0.activationPolicy == .regular }
                                .map { $0.bundleIdentifier ?? "" }
        )
        let activeAppName = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        
        var activeTabName, activeTabURL: String?
        switch activeAppName.lowercased() {
        case "com.apple.safari":
            (activeTabName, activeTabURL) = getSafariActiveTab()
        case "com.google.chrome":
            (activeTabName, activeTabURL) = getChromeActiveTab()
        case "com.mozilla.firefox":
            (activeTabName, activeTabURL) = getFirefoxActiveTab()
        default:
            break
        }
        
        let datapoint = DataPoint(timestamp: Date(),
                                  mouseTouched: mouseTouched,
                                  keypressCount: keypressCount,
                                  activeAppName: activeAppName,
                                  openedAppNames: allAppNames.filter { $0 != "" },
                                  activeTabName: activeTabName,
                                  activeTabURL: activeTabURL,
                                  isPlayingVideo: false)
        history.append(datapoint)
        
        keypressCount = 0
        mouseTouched = false
        
        var urlRequest = URLRequest(url: URL.with(API_Name: "/data/update_status")!)
        urlRequest.httpBody = try! JSONEncoder().encode(datapoint)
        urlRequest.setValue("", forHTTPHeaderField: "token")
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            
            guard error == nil, let data = data else {
                print(error)
                return
            }
            
            print(String(data: data, encoding: .utf8))
        }
        
        task.resume()
    }
    
    @objc func onKeyPressed(_ notification: Notification) {
        let obj = Array(notification.object as! NSArray)
        let pressed = obj[0] as! Int
        let code = obj[1] as! Int
        
        if pressed == 1 {
            if code != lastKey || lastKeyCount == 1 {
                lastKey = code
                lastKeyCount += 1
                keypressCount += 1
            } else if code == lastKey {
                lastKeyCount += 1
            }
        }
        
        
    }
    
}
