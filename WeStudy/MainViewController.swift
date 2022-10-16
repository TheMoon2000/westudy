//
//  MainViewController.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Foundation
import Cocoa
import IOKit.hid
import SwiftyJSON

let PERIOD = 5.0

class MainViewController: NSViewController {

    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var userStatus: NSTextField!
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var topBG: NSView!
    @IBOutlet weak var bottomBG: NSView!
    
    var k: Keylogger!
    
    var roomCode: String!
    var friendsData = [(key: String, value: JSON)]()
    
    var history = [DataPoint]()
    var keypressCount = 0
    
    /// The code for the last key.
    var lastKey = 0
    
    /// How many times the `lastKey` is pressed.
    var lastKeyCount = 0
    
    /// Whether the mouse is interacted with in the last `PERIOD` seconds.
    var mouseTouched = false
    
    var currentTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupKeyListener()
        setupMouseListener()
        
        Timer.scheduledTimer(withTimeInterval: PERIOD, repeats: true) { timer in
            self.recordHistoryAndUpload()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = NSNib(nibNamed: NSNib.Name("FriendCell"), bundle: .main)
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"))
        tableView.selectionHighlightStyle = .none
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.fetch()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.userStatus.stringValue == "Learning" || self.userStatus.stringValue == "Working" {
                self.currentTime += 1
            }
            self.timer.stringValue = String(format: "%02d:%02d:%02d", self.currentTime / 3600, (self.currentTime % 3600) / 60, self.currentTime % 60)
        }
        
        view.wantsLayer = true
        
        topBG.wantsLayer = true
        topBG.layer?.backgroundColor = Colors.themeLight.cgColor
        
        bottomBG.wantsLayer = true
        bottomBG.layer?.backgroundColor = Colors.themeLight.cgColor
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
        
        let datapoint = DataPoint(timestamp: Int(Date().timeIntervalSince1970),
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
        urlRequest.setValue(LocalStorage.current.token!, forHTTPHeaderField: "token")
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            
            guard error == nil, let data = data else {
                print(error!)
                return
            }
            
            let json = JSON.init(parseJSON: String(data: data, encoding: .utf8)!)
            DispatchQueue.main.async {
                self.userStatus.stringValue = json["status"].string ?? "Unknown"
            }
        }
        
        task.resume()
    }
    
    func fetch() {
        var urlRequest = URLRequest(url: URL.with(API_Name: "/data/get_status")!)
        urlRequest.setValue(LocalStorage.current.token!, forHTTPHeaderField: "token")
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            
            guard error == nil, let data = data else {
                print(error!)
                return
            }
            
            let json = JSON(parseJSON: String(data: data, encoding: .utf8)!)["data"].dictionaryValue
            self.friendsData = json.sorted(by: { (a, b) in a.key < b.key })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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


extension MainViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.friendsData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as! FriendCell
        cell.friendName.stringValue = friendsData[row].key
        cell.status.stringValue = friendsData[row].value.array?.last?["status"].string ?? "Unknown"
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 56
    }
    
}
